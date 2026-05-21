'use strict';
const NodeCache = require('node-cache');

const caches = {};

function cacheMiddleware({ ttl = 300 } = {}) {
  if (!caches[ttl]) caches[ttl] = new NodeCache({ stdTTL: ttl });
  const cache = caches[ttl];

  return (req, res, next) => {
    if (req.method !== 'GET') return next();

    const key = req.originalUrl;
    const cached = cache.get(key);
    if (cached) return res.json(cached);

    const originalJson = res.json.bind(res);
    res.json = (data) => {
      cache.set(key, data);
      originalJson(data);
    };
    next();
  };
}

module.exports = cacheMiddleware;
