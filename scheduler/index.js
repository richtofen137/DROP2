'use strict';
const cron = require('node-cron');
const { logger } = require('../middlewares/logger.middleware');
const { runMarketAnalysisJob } = require('./jobs/market-analysis.job');
const { runSeoUpdateJob } = require('./jobs/seo-update.job');
const { runSupplierSyncJob } = require('./jobs/supplier-sync.job');
const { runPricingUpdateJob } = require('./jobs/pricing-update.job');
const { runAnalyticsReportJob } = require('./jobs/analytics-report.job');
const { runCustomerServiceJob } = require('./jobs/customer-service.job');

function start() {
  // Analyse marché toutes les 6h
  cron.schedule('0 */6 * * *', runMarketAnalysisJob, { timezone: 'Europe/Paris' });

  // SEO update tous les jours à 2h
  cron.schedule('0 2 * * *', runSeoUpdateJob, { timezone: 'Europe/Paris' });

  // Sync fournisseurs toutes les 2h
  cron.schedule('0 */2 * * *', runSupplierSyncJob, { timezone: 'Europe/Paris' });

  // Pricing update toutes les 3h
  cron.schedule('0 */3 * * *', runPricingUpdateJob, { timezone: 'Europe/Paris' });

  // Rapport analytics quotidien à 3h
  cron.schedule('0 3 * * *', runAnalyticsReportJob, { timezone: 'Europe/Paris' });

  // SAV toutes les 15min
  cron.schedule('*/15 * * * *', runCustomerServiceJob, { timezone: 'Europe/Paris' });

  logger.info('⏰ Scheduler démarré : 6 jobs actifs');
}

module.exports = { start };
