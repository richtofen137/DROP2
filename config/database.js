'use strict';
const Database = require('better-sqlite3');
const fs = require('fs');
const path = require('path');
const appLogger = require('../middlewares/logger.middleware');

const DB_PATH = process.env.DB_PATH || path.join(__dirname, '../db/autonomous-drop.sqlite');

let db;

function getDB() {
  if (!db) {
    db = new Database(DB_PATH);
    db.pragma('journal_mode = WAL');
    db.pragma('foreign_keys = ON');
  }
  return db;
}

function initDB() {
  const database = getDB();
  runMigrations(database);
  return database;
}

function runMigrations(database) {
  const migrationsDir = path.join(__dirname, '../db/migrations');
  if (!fs.existsSync(migrationsDir)) return;

  database.exec(`
    CREATE TABLE IF NOT EXISTS _migrations (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      filename TEXT NOT NULL UNIQUE,
      applied_at TEXT NOT NULL DEFAULT (datetime('now'))
    )
  `);

  const applied = new Set(
    database.prepare('SELECT filename FROM _migrations').all().map(r => r.filename)
  );

  const files = fs.readdirSync(migrationsDir)
    .filter(f => f.endsWith('.sql'))
    .sort();

  for (const file of files) {
    if (applied.has(file)) continue;
    const sql = fs.readFileSync(path.join(migrationsDir, file), 'utf8');
    database.exec(sql);
    database.prepare('INSERT INTO _migrations (filename) VALUES (?)').run(file);
    console.log(`✅ Migration appliquée : ${file}`);
  }
}

module.exports = { getDB, initDB, runMigrations };
