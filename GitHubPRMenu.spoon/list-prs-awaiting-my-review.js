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

function getUnreadMentions() {
  const json = run('gh api notifications --jq "[.[] | select(.reason == \\"mention\\" and .unread == true)]"');
  const notifications = JSON.parse(json);
  return notifications.map(n => {
    const apiUrl = n.subject.url;
    const webUrl = apiUrl
      .replace('https://api.github.com/repos/', 'https://github.com/')
      .replace('/pulls/', '/pull/');
    return {
      id: n.id,
      title: n.subject.title,
      url: webUrl,
      repoName: n.repository.full_name,
      updatedAt: n.updated_at
    };
  });
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

  const mentions = getUnreadMentions();
  if (mentions.length > 0) {
    console.log('\nPRs where you were mentioned (unread):');
    for (const mention of mentions) {
      console.log(`- ${mention.title}`);
      console.log(`  Repo: ${mention.repoName}`);
      console.log(`  Updated: ${mention.updatedAt.split('T')[0]}`);
      console.log(`  URL: ${mention.url}`);
      console.log(`  NotificationID: ${mention.id}`);
    }
  } else {
    console.log('\nNo unread mention notifications.');
  }
}

main();

