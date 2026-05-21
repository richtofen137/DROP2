-- Migration 003 : Analytics & cron logs
CREATE TABLE IF NOT EXISTS sales_analytics (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  period_type TEXT NOT NULL CHECK (period_type IN ('daily','weekly','monthly')),
  period_date TEXT NOT NULL,
  revenue REAL DEFAULT 0,
  cost_total REAL DEFAULT 0,
  gross_margin REAL DEFAULT 0,
  gross_margin_pct REAL DEFAULT 0,
  orders_count INTEGER DEFAULT 0,
  avg_order_value REAL DEFAULT 0,
  new_customers INTEGER DEFAULT 0,
  returning_customers INTEGER DEFAULT 0,
  top_products_json TEXT,
  top_categories_json TEXT,
  traffic_sources_json TEXT,
  refunds_count INTEGER DEFAULT 0,
  refunds_amount REAL DEFAULT 0,
  tickets_opened INTEGER DEFAULT 0,
  tickets_resolved INTEGER DEFAULT 0,
  computed_at TEXT NOT NULL DEFAULT (datetime('now')),
  UNIQUE(period_type, period_date)
);

CREATE TABLE IF NOT EXISTS cron_logs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  job_name TEXT NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('started','success','failed','partial')),
  items_processed INTEGER DEFAULT 0,
  items_failed INTEGER DEFAULT 0,
  duration_ms INTEGER,
  error_message TEXT,
  payload_json TEXT,
  started_at TEXT NOT NULL DEFAULT (datetime('now')),
  finished_at TEXT
);
