'use strict';
const { logCronStart, logCronEnd } = require('../cron-logger');
const { logger } = require('../../middlewares/logger.middleware');

async function runSeoUpdateJob() {
  const cronId = logCronStart('seo-update');
  const start = Date.now();
  try {
    const service = require('../../modules/seo/seo.service');
    const result = await service.generatePendingSeo();
    logCronEnd(cronId, { status: 'success', itemsProcessed: result.generated || 0, durationMs: Date.now() - start });
    logger.info(`[CRON] seo-update : ${result.generated} fiches générées`);
  } catch (err) {
    logCronEnd(cronId, { status: 'failed', durationMs: Date.now() - start, errorMessage: err.message });
    logger.error('[CRON] seo-update échec :', err.message);
  }
}

module.exports = { runSeoUpdateJob };
