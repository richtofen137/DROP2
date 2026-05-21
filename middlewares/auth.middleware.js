'use strict';
const jwt = require('jsonwebtoken');

function authMiddleware(req, res, next) {
  const apiKey = req.headers['x-admin-key'];
  if (apiKey && apiKey === process.env.ADMIN_API_KEY) return next();

  const authHeader = req.headers.authorization;
  if (authHeader && authHeader.startsWith('Bearer ')) {
    try {
      const token = authHeader.slice(7);
      req.user = jwt.verify(token, process.env.JWT_SECRET);
      return next();
    } catch {
      return res.status(401).json({ error: 'Token JWT invalide ou expiré' });
    }
  }

  return res.status(401).json({ error: 'Authentification requise (X-Admin-Key ou Bearer JWT)' });
}

module.exports = authMiddleware;
