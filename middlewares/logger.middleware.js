'use strict';
const winston = require('winston');
const morgan = require('morgan');
const path = require('path');
const fs = require('fs');

const logsDir = path.join(__dirname, '../logs');
if (!fs.existsSync(logsDir)) fs.mkdirSync(logsDir, { recursive: true });

const winstonLogger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json()
  ),
  transports: [
    new winston.transports.Console({
      format: winston.format.combine(
        winston.format.colorize(),
        winston.format.simple()
      )
    }),
    new winston.transports.File({ filename: path.join(logsDir, 'errors.log'), level: 'error' }),
    new winston.transports.File({ filename: path.join(logsDir, 'app.log') })
  ]
});

const httpLogger = morgan('combined', {
  stream: { write: (msg) => winstonLogger.info(msg.trim()) }
});

module.exports = { logger: winstonLogger, httpLogger };
