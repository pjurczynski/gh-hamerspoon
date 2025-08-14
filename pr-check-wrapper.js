#!/usr/bin/env node

// Wrapper script for GitHub PR checking that works from any directory
const { execSync } = require('child_process');
const path = require('path');

function run(cmd, options = {}) {
  return execSync(cmd, { encoding: 'utf8', ...options });
}

function getMyLogin() {
  return run('gh api user --jq .login').trim();
}

function getPrList(repo) {
  const repoArg = repo ? `--repo ${repo}` : '';
  try {
    const json = run(
      `gh pr list ${repoArg} --search 'review-requested:@me state:open' --json number,title,url,author,createdAt --limit 100`
    );
    return JSON.parse(json);
  } catch (error) {
    // If no repo specified and we're not in a git directory, 
    // try to get PRs from all repos you have access to
    if (!repo && error.message.includes('no git remotes found')) {
      console.error('Warning: Not in a git repository. Searching across all accessible repositories may be slow.');
      // For now, return empty array. In the future, we could implement a broader search
      return [];
    }
    throw error;
  }
}

function getPrReviewInfo(prNumber, repo) {
  const repoArg = repo ? `--repo ${repo}` : '';
  const json = run(`gh pr view ${prNumber} ${repoArg} --json latestReviews,reviewRequests`);
  return JSON.parse(json);
}

function main() {
  const repo = process.argv[2];
  const me = getMyLogin();
  const prs = getPrList(repo);
  const reRequested = [];
  const fresh = [];

  for (const pr of prs) {
    const { number, title, url, author, createdAt } = pr;
    const prInfo = getPrReviewInfo(number, repo);
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