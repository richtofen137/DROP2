'use strict';
const { logCronStart, logCronEnd } = require('../cron-logger');
const { logger } = require('../../middlewares/logger.middleware');

async function runCustomerServiceJob() {
  const cronId = logCronStart('customer-service');
  const start = Date.now();
  try {
    const service = require('../../modules/customer-service/customer-service.service');
    const result = await service.processPendingTickets();
    logCronEnd(cronId, { status: 'success', itemsProcessed: result.processed || 0, durationMs: Date.now() - start });
    logger.info(`[CRON] customer-service : ${result.processed} tickets traités`);
  } catch (err) {
    logCronEnd(cronId, { status: 'failed', durationMs: Date.now() - start, errorMessage: err.message });
    logger.error('[CRON] customer-service échec :', err.message);
  }
}

module.exports = { runCustomerServiceJob };
