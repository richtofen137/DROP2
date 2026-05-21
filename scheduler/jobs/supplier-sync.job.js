'use strict';
const { logCronStart, logCronEnd } = require('../cron-logger');
const { logger } = require('../../middlewares/logger.middleware');

async function runSupplierSyncJob() {
  const cronId = logCronStart('supplier-sync');
  const start = Date.now();
  try {
    const service = require('../../modules/suppliers/suppliers.service');
    const result = await service.syncAllSuppliers();
    logCronEnd(cronId, { status: 'success', itemsProcessed: result.synced || 0, durationMs: Date.now() - start });
    logger.info(`[CRON] supplier-sync : ${result.synced} produits synchronisés`);
  } catch (err) {
    logCronEnd(cronId, { status: 'failed', durationMs: Date.now() - start, errorMessage: err.message });
    logger.error('[CRON] supplier-sync échec :', err.message);
  }
}

module.exports = { runSupplierSyncJob };
