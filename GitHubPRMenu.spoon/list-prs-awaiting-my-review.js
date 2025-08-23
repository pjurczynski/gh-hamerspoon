#!/usr/bin/env node

const { execSync } = require('child_process');

function run(cmd) {
  return execSync(cmd, { encoding: 'utf8' });
}

function getMyLogin() {
  return run('gh api user --jq .login').trim();
}

function getPrList() {
  const json = run(
    `gh search prs --review-requested=@me --state=open --json number,title,url,author,createdAt,repository --limit 100`
  );
  return JSON.parse(json);
}

function getPrReviewInfo(prNumber, repo) {
  const repoArg = repo ? `--repo ${repo}` : '';
  const json = run(`gh pr view ${prNumber} ${repoArg} --json latestReviews,reviewRequests`);
  return JSON.parse(json);
}

function main() {
  const me = getMyLogin();
  const prs = getPrList();
  const reRequested = [];
  const fresh = [];

  for (const pr of prs) {
    const { number, title, url, author, createdAt, repository } = pr;
    const prInfo = getPrReviewInfo(number, repository.nameWithOwner);
    const reviewed = (prInfo.latestReviews || []).some(r => r.author && r.author.login === me);
    const requested = (prInfo.reviewRequests || []).some(r => r.login === me);
    const prText = `- ${title}\n  Author: ${author.login}\n  Created: ${createdAt.split('T')[0]}\n  URL: ${url}\n`;
    if (reviewed && requested) {
      reRequested.push(prText);
    } else if (!reviewed && requested) {
      fresh.push(prText);
    }
  }

  if (reRequested.length > 0) {
    console.log('\nPRs where your review was re-requested:');
    for (const pr of reRequested) console.log(pr);
  } else {
    console.log('\nNo PRs with re-requested reviews.');
  }

  if (fresh.length > 0) {
    console.log('\nPRs where you have never reviewed (fresh):');
    for (const pr of fresh) console.log(pr);
  } else {
    console.log('\nNo fresh PRs awaiting your first review.');
  }
}

main();

