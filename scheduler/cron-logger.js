'use strict';
const { getDB } = require('../config/database');

function logCronStart(jobName) {
  const db = getDB();
  const result = db.prepare(
    `INSERT INTO cron_logs (job_name, status, started_at) VALUES (?, 'started', datetime('now'))`
  ).run(jobName);
  return result.lastInsertRowid;
}

function logCronEnd(id, { status, itemsProcessed = 0, itemsFailed = 0, durationMs = 0, errorMessage = null, payloadJson = null } = {}) {
  const db = getDB();
  db.prepare(`
    UPDATE cron_logs SET
      status = ?,
      items_processed = ?,
      items_failed = ?,
      duration_ms = ?,
      error_message = ?,
      payload_json = ?,
      finished_at = datetime('now')
    WHERE id = ?
  `).run(status, itemsProcessed, itemsFailed, durationMs, errorMessage, payloadJson ? JSON.stringify(payloadJson) : null, id);
}

module.exports = { logCronStart, logCronEnd };
