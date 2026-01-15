#!/usr/bin/env node

const { execSync } = require('child_process');

function run(cmd) {
  return execSync(cmd, { encoding: 'utf8' });
}

function markNotificationAsRead(notificationId) {
  run(`gh api -X PATCH /notifications/threads/${notificationId}`);
}

const notificationId = process.argv[2];
if (!notificationId) {
  console.error('Usage: mark-notification-read.js <notification-id>');
  process.exit(1);
}

markNotificationAsRead(notificationId);
console.log(`Marked notification ${notificationId} as read`);
