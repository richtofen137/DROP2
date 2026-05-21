'use strict';
require('dotenv').config();
require('express-async-errors');

const express = require('express');
const path = require('path');
const { initDB } = require('./config/database');
const logger = require('./middlewares/logger.middleware');
const errorHandler = require('./middlewares/error.middleware');
const rateLimiter = require('./middlewares/ratelimit.middleware');
const cacheMiddleware = require('./middlewares/cache.middleware');
const routes = require('./routes/index');
const scheduler = require('./scheduler/index');

const app = express();
const PORT = process.env.PORT || 3000;

// ── Body parsers ──────────────────────────────────
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// ── Static files ─────────────────────────────────
app.use(express.static(path.join(__dirname, 'public')));

// ── HTTP Logger (Morgan → Winston) ───────────────
app.use(logger.httpLogger);

// ── Rate Limiter ─────────────────────────────────
app.use('/api', rateLimiter);

// ── Cache GET non-critiques ───────────────────────
app.use('/api/v1/analytics', cacheMiddleware({ ttl: 300 }));
app.use('/api/v1/market', cacheMiddleware({ ttl: 600 }));

// ── Routes API ────────────────────────────────────
app.use('/api/v1', routes);

// ── Fallback SPA ─────────────────────────────────
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// ── Error Handler (doit être en dernier) ─────────
app.use(errorHandler);

// ── Démarrage ─────────────────────────────────────
async function start() {
  try {
    initDB();
    scheduler.start();
    app.listen(PORT, () => {
      console.log(`🚀 AutoDrop démarré sur http://localhost:${PORT}`);
    });
  } catch (err) {
    console.error('Erreur démarrage:', err);
    process.exit(1);
  }
}

start();

module.exports = app;
