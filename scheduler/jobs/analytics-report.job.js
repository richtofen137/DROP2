'use strict';
const { logCronStart, logCronEnd } = require('../cron-logger');
const { logger } = require('../../middlewares/logger.middleware');

async function runAnalyticsReportJob() {
  const cronId = logCronStart('analytics-report');
  const start = Date.now();
  try {
    const service = require('../../modules/analytics/analytics.service');
    const result = await service.generateDailyReport();
    logCronEnd(cronId, { status: 'success', durationMs: Date.now() - start, payloadJson: result });
    logger.info('[CRON] analytics-report : rapport quotidien généré');
  } catch (err) {
    logCronEnd(cronId, { status: 'failed', durationMs: Date.now() - start, errorMessage: err.message });
    logger.error('[CRON] analytics-report échec :', err.message);
  }
}

module.exports = { runAnalyticsReportJob };
