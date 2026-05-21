'use strict';
const { logCronStart, logCronEnd } = require('../cron-logger');
const { logger } = require('../../middlewares/logger.middleware');

async function runPricingUpdateJob() {
  const cronId = logCronStart('pricing-update');
  const start = Date.now();
  try {
    const service = require('../../modules/pricing/pricing.service');
    const result = await service.runPricingUpdate();
    logCronEnd(cronId, { status: 'success', itemsProcessed: result.updated || 0, durationMs: Date.now() - start });
    logger.info(`[CRON] pricing-update : ${result.updated} prix mis à jour`);
  } catch (err) {
    logCronEnd(cronId, { status: 'failed', durationMs: Date.now() - start, errorMessage: err.message });
    logger.error('[CRON] pricing-update échec :', err.message);
  }
}

module.exports = { runPricingUpdateJob };
