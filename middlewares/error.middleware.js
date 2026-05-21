'use strict';
const { logger } = require('./logger.middleware');

function errorHandler(err, req, res, next) {
  const status = err.status || err.statusCode || 500;
  const message = err.message || 'Erreur interne du serveur';

  logger.error({
    message,
    stack: err.stack,
    method: req.method,
    url: req.originalUrl,
    body: req.body
  });

  res.status(status).json({
    success: false,
    error: message,
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
  });
}

module.exports = errorHandler;
