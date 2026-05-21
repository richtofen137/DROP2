-- Migration 002 : Scoring & trends
CREATE TABLE IF NOT EXISTS products_trends (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  product_id INTEGER REFERENCES products(id) ON DELETE CASCADE,
  source TEXT NOT NULL CHECK (source IN ('tiktok','google_trends','instagram','pinterest')),
  keyword TEXT NOT NULL,
  score_viral REAL NOT NULL DEFAULT 0 CHECK (score_viral BETWEEN 0 AND 100),
  score_demand REAL NOT NULL DEFAULT 0 CHECK (score_demand BETWEEN 0 AND 100),
  score_competition REAL NOT NULL DEFAULT 0 CHECK (score_competition BETWEEN 0 AND 100),
  score_global REAL NOT NULL DEFAULT 0 CHECK (score_global BETWEEN 0 AND 100),
  raw_data_json TEXT,
  detected_at TEXT NOT NULL DEFAULT (datetime('now')),
  expires_at TEXT
);

CREATE TABLE IF NOT EXISTS pricing_rules (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  rule_type TEXT NOT NULL CHECK (rule_type IN ('coefficient','fixed_margin','trending_boost','stagnant_promo','floor')),
  applies_to TEXT NOT NULL DEFAULT 'all',
  coefficient REAL,
  fixed_margin_pct REAL,
  boost_pct REAL,
  promo_pct REAL,
  floor_price REAL,
  stagnant_days INTEGER DEFAULT 30,
  is_active INTEGER NOT NULL DEFAULT 1,
  priority INTEGER NOT NULL DEFAULT 1,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS supplier_products (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  supplier_id INTEGER NOT NULL REFERENCES suppliers(id) ON DELETE CASCADE,
  product_id INTEGER REFERENCES products(id) ON DELETE SET NULL,
  supplier_product_id TEXT NOT NULL,
  supplier_sku TEXT,
  title TEXT,
  cost_price REAL NOT NULL DEFAULT 0,
  shipping_cost REAL DEFAULT 0,
  stock_qty INTEGER DEFAULT 0,
  stock_status TEXT DEFAULT 'unknown' CHECK (stock_status IN ('in_stock','low_stock','out_of_stock','unknown')),
  avg_delivery_days REAL DEFAULT 15,
  supplier_rating REAL DEFAULT 0,
  variants_json TEXT,
  last_synced_at TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now')),
  UNIQUE(supplier_id, supplier_product_id)
);

CREATE TABLE IF NOT EXISTS competitors_prices (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  product_id INTEGER REFERENCES products(id) ON DELETE CASCADE,
  platform TEXT NOT NULL CHECK (platform IN ('amazon','ebay','cdiscount','shopify','other')),
  competitor_url TEXT,
  competitor_name TEXT,
  price REAL NOT NULL,
  shipping_cost REAL DEFAULT 0,
  total_price REAL GENERATED ALWAYS AS (price + shipping_cost) STORED,
  currency TEXT DEFAULT 'EUR',
  in_stock INTEGER DEFAULT 1,
  scraped_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS seo_data (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  product_id INTEGER NOT NULL UNIQUE REFERENCES products(id) ON DELETE CASCADE,
  meta_title TEXT,
  meta_description TEXT,
  alt_text TEXT,
  slug TEXT,
  h1 TEXT,
  full_description TEXT,
  short_description TEXT,
  keywords_json TEXT,
  image_url TEXT,
  sitemap_priority REAL DEFAULT 0.8,
  sitemap_changefreq TEXT DEFAULT 'weekly',
  ranking_data_json TEXT,
  generated_by TEXT DEFAULT 'mistral-large-latest',
  generated_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS tickets (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  ticket_ref TEXT NOT NULL UNIQUE,
  customer_id INTEGER REFERENCES customers(id) ON DELETE SET NULL,
  order_id INTEGER REFERENCES orders(id) ON DELETE SET NULL,
  channel TEXT DEFAULT 'email' CHECK (channel IN ('email','webhook','phone','chat')),
  subject TEXT,
  body TEXT NOT NULL,
  intent TEXT,
  status TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open','in_progress','resolved','escalated','closed')),
  priority TEXT DEFAULT 'normal' CHECK (priority IN ('low','normal','high','urgent')),
  requires_human INTEGER DEFAULT 0,
  ai_response TEXT,
  ai_confidence REAL,
  resolution_notes TEXT,
  opened_at TEXT NOT NULL DEFAULT (datetime('now')),
  resolved_at TEXT,
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);
