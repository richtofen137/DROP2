'use strict';
const { logCronStart, logCronEnd } = require('../cron-logger');
const { logger } = require('../../middlewares/logger.middleware');

async function runMarketAnalysisJob() {
  const cronId = logCronStart('market-analysis');
  const start = Date.now();
  try {
    const service = require('../../modules/market-analysis/market-analysis.service');
    const result = await service.runFullAnalysis();
    logCronEnd(cronId, { status: 'success', itemsProcessed: result.detected || 0, durationMs: Date.now() - start });
    logger.info(`[CRON] market-analysis : ${result.detected} produits détectés`);
  } catch (err) {
    logCronEnd(cronId, { status: 'failed', durationMs: Date.now() - start, errorMessage: err.message });
    logger.error('[CRON] market-analysis échec :', err.message);
  }
}

module.exports = { runMarketAnalysisJob };
