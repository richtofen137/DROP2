-- ============================================================
-- TABLE : products
-- ============================================================
CREATE TABLE IF NOT EXISTS products (
  id                INTEGER PRIMARY KEY AUTOINCREMENT,
  external_id       TEXT UNIQUE,
  name              TEXT NOT NULL,
  slug              TEXT UNIQUE NOT NULL,
  description       TEXT,
  short_description TEXT,
  category          TEXT,
  brand             TEXT,
  sku               TEXT UNIQUE,
  status            TEXT NOT NULL DEFAULT 'draft'
                      CHECK (status IN ('draft','published','archived')),
  supplier_id       INTEGER REFERENCES suppliers(id) ON DELETE SET NULL,
  cost_price        REAL NOT NULL DEFAULT 0,
  sale_price        REAL NOT NULL DEFAULT 0,
  stock_qty         INTEGER NOT NULL DEFAULT 0,
  weight_g          REAL,
  images_json       TEXT,
  tags_json         TEXT,
  is_trending       INTEGER NOT NULL DEFAULT 0,
  score_global      REAL DEFAULT 0,
  created_at        TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at        TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_products_status ON products(status);
CREATE INDEX IF NOT EXISTS idx_products_supplier ON products(supplier_id);
CREATE INDEX IF NOT EXISTS idx_products_trending ON products(is_trending, score_global DESC);
CREATE INDEX IF NOT EXISTS idx_products_slug ON products(slug);

-- ============================================================
-- TABLE : products_trends
-- ============================================================
CREATE TABLE IF NOT EXISTS products_trends (
  id               INTEGER PRIMARY KEY AUTOINCREMENT,
  product_id       INTEGER REFERENCES products(id) ON DELETE CASCADE,
  source           TEXT NOT NULL CHECK (source IN ('tiktok','google_trends','instagram','pinterest')),
  keyword          TEXT NOT NULL,
  score_viral      REAL NOT NULL DEFAULT 0 CHECK (score_viral BETWEEN 0 AND 100),
  score_demand     REAL NOT NULL DEFAULT 0 CHECK (score_demand BETWEEN 0 AND 100),
  score_competition REAL NOT NULL DEFAULT 0 CHECK (score_competition BETWEEN 0 AND 100),
  score_global     REAL NOT NULL DEFAULT 0 CHECK (score_global BETWEEN 0 AND 100),
  raw_data_json    TEXT,
  detected_at      TEXT NOT NULL DEFAULT (datetime('now')),
  expires_at       TEXT
);
CREATE INDEX IF NOT EXISTS idx_trends_score ON products_trends(score_global DESC);
CREATE INDEX IF NOT EXISTS idx_trends_source ON products_trends(source, detected_at DESC);
CREATE INDEX IF NOT EXISTS idx_trends_product ON products_trends(product_id);

-- ============================================================
-- TABLE : seo_data
-- ============================================================
CREATE TABLE IF NOT EXISTS seo_data (
  id               INTEGER PRIMARY KEY AUTOINCREMENT,
  product_id       INTEGER NOT NULL UNIQUE REFERENCES products(id) ON DELETE CASCADE,
  meta_title       TEXT,
  meta_description TEXT,
  alt_text         TEXT,
  slug             TEXT,
  h1               TEXT,
  full_description TEXT,
  short_description TEXT,
  keywords_json    TEXT,
  image_url        TEXT,
  sitemap_priority REAL DEFAULT 0.8,
  sitemap_changefreq TEXT DEFAULT 'weekly',
  ranking_data_json TEXT,
  generated_by     TEXT DEFAULT 'mistral-large-latest',
  generated_at     TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at       TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_seo_product ON seo_data(product_id);
CREATE INDEX IF NOT EXISTS idx_seo_updated ON seo_data(updated_at DESC);

-- ============================================================
-- TABLE : suppliers
-- ============================================================
CREATE TABLE IF NOT EXISTS suppliers (
  id               INTEGER PRIMARY KEY AUTOINCREMENT,
  name             TEXT NOT NULL UNIQUE,
  platform         TEXT NOT NULL CHECK (platform IN ('cjdropshipping','aliexpress','autods','zendrop','other')),
  api_base_url     TEXT,
  is_active        INTEGER NOT NULL DEFAULT 1,
  is_fallback      INTEGER NOT NULL DEFAULT 0,
  priority         INTEGER NOT NULL DEFAULT 1,
  reliability_score REAL DEFAULT 100,
  avg_delivery_days REAL DEFAULT 15,
  error_rate       REAL DEFAULT 0,
  total_orders     INTEGER DEFAULT 0,
  total_errors     INTEGER DEFAULT 0,
  credentials_json TEXT,
  webhook_url      TEXT,
  notes            TEXT,
  created_at       TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at       TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_suppliers_active ON suppliers(is_active, priority);
CREATE INDEX IF NOT EXISTS idx_suppliers_reliability ON suppliers(reliability_score DESC);

-- ============================================================
-- TABLE : supplier_products
-- ============================================================
CREATE TABLE IF NOT EXISTS supplier_products (
  id                  INTEGER PRIMARY KEY AUTOINCREMENT,
  supplier_id         INTEGER NOT NULL REFERENCES suppliers(id) ON DELETE CASCADE,
  product_id          INTEGER REFERENCES products(id) ON DELETE SET NULL,
  supplier_product_id TEXT NOT NULL,
  supplier_sku        TEXT,
  title               TEXT,
  cost_price          REAL NOT NULL DEFAULT 0,
  shipping_cost       REAL DEFAULT 0,
  stock_qty           INTEGER DEFAULT 0,
  stock_status        TEXT DEFAULT 'unknown' CHECK (stock_status IN ('in_stock','low_stock','out_of_stock','unknown')),
  avg_delivery_days   REAL DEFAULT 15,
  supplier_rating     REAL DEFAULT 0,
  variants_json       TEXT,
  last_synced_at      TEXT,
  created_at          TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at          TEXT NOT NULL DEFAULT (datetime('now')),
  UNIQUE(supplier_id, supplier_product_id)
);
CREATE INDEX IF NOT EXISTS idx_sp_supplier ON supplier_products(supplier_id);
CREATE INDEX IF NOT EXISTS idx_sp_product ON supplier_products(product_id);
CREATE INDEX IF NOT EXISTS idx_sp_stock ON supplier_products(stock_status);

-- ============================================================
-- TABLE : pricing_rules
-- ============================================================
CREATE TABLE IF NOT EXISTS pricing_rules (
  id                INTEGER PRIMARY KEY AUTOINCREMENT,
  name              TEXT NOT NULL,
  rule_type         TEXT NOT NULL CHECK (rule_type IN ('coefficient','fixed_margin','trending_boost','stagnant_promo','floor')),
  applies_to        TEXT NOT NULL DEFAULT 'all',
  coefficient       REAL,
  fixed_margin_pct  REAL,
  boost_pct         REAL,
  promo_pct         REAL,
  floor_price       REAL,
  stagnant_days     INTEGER DEFAULT 30,
  is_active         INTEGER NOT NULL DEFAULT 1,
  priority          INTEGER NOT NULL DEFAULT 1,
  created_at        TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at        TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_pricing_active ON pricing_rules(is_active, priority);

-- ============================================================
-- TABLE : competitors_prices
-- ============================================================
CREATE TABLE IF NOT EXISTS competitors_prices (
  id               INTEGER PRIMARY KEY AUTOINCREMENT,
  product_id       INTEGER REFERENCES products(id) ON DELETE CASCADE,
  platform         TEXT NOT NULL CHECK (platform IN ('amazon','ebay','cdiscount','shopify','other')),
  competitor_url   TEXT,
  competitor_name  TEXT,
  price            REAL NOT NULL,
  shipping_cost    REAL DEFAULT 0,
  total_price      REAL GENERATED ALWAYS AS (price + shipping_cost) STORED,
  currency         TEXT DEFAULT 'EUR',
  in_stock         INTEGER DEFAULT 1,
  scraped_at       TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_competitors_product ON competitors_prices(product_id, scraped_at DESC);
CREATE INDEX IF NOT EXISTS idx_competitors_platform ON competitors_prices(platform, scraped_at DESC);

-- ============================================================
-- TABLE : customers
-- ============================================================
CREATE TABLE IF NOT EXISTS customers (
  id               INTEGER PRIMARY KEY AUTOINCREMENT,
  email            TEXT NOT NULL UNIQUE,
  first_name       TEXT,
  last_name        TEXT,
  phone            TEXT,
  address_json     TEXT,
  total_orders     INTEGER DEFAULT 0,
  total_spent      REAL DEFAULT 0,
  ltv              REAL DEFAULT 0,
  acquisition_source TEXT,
  is_vip           INTEGER DEFAULT 0,
  last_order_at    TEXT,
  created_at       TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at       TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_customers_email ON customers(email);
CREATE INDEX IF NOT EXISTS idx_customers_ltv ON customers(ltv DESC);
CREATE INDEX IF NOT EXISTS idx_customers_vip ON customers(is_vip);

-- ============================================================
-- TABLE : orders
-- ============================================================
CREATE TABLE IF NOT EXISTS orders (
  id                    INTEGER PRIMARY KEY AUTOINCREMENT,
  order_ref             TEXT NOT NULL UNIQUE,
  customer_id           INTEGER NOT NULL REFERENCES customers(id) ON DELETE RESTRICT,
  supplier_id           INTEGER REFERENCES suppliers(id) ON DELETE SET NULL,
  supplier_order_id     TEXT,
  status                TEXT NOT NULL DEFAULT 'pending'
                          CHECK (status IN ('pending','confirmed','shipped','delivered','cancelled','refunded')),
  items_json            TEXT NOT NULL,
  subtotal              REAL NOT NULL DEFAULT 0,
  shipping_cost         REAL DEFAULT 0,
  tax                   REAL DEFAULT 0,
  total                 REAL NOT NULL DEFAULT 0,
  cost_total            REAL DEFAULT 0,
  margin                REAL DEFAULT 0,
  margin_pct            REAL DEFAULT 0,
  payment_method        TEXT,
  payment_status        TEXT DEFAULT 'pending' CHECK (payment_status IN ('pending','paid','failed','refunded')),
  tracking_number       TEXT,
  tracking_url          TEXT,
  shipped_at            TEXT,
  delivered_at          TEXT,
  notes                 TEXT,
  created_at            TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at            TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_orders_customer ON orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_orders_supplier ON orders(supplier_id);
CREATE INDEX IF NOT EXISTS idx_orders_date ON orders(created_at DESC);

-- ============================================================
-- TABLE : tickets
-- ============================================================
CREATE TABLE IF NOT EXISTS tickets (
  id               INTEGER PRIMARY KEY AUTOINCREMENT,
  ticket_ref       TEXT NOT NULL UNIQUE,
  customer_id      INTEGER REFERENCES customers(id) ON DELETE SET NULL,
  order_id         INTEGER REFERENCES orders(id) ON DELETE SET NULL,
  channel          TEXT DEFAULT 'email' CHECK (channel IN ('email','webhook','phone','chat')),
  subject          TEXT,
  body             TEXT NOT NULL,
  intent           TEXT,
  status           TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open','in_progress','resolved','escalated','closed')),
  priority         TEXT DEFAULT 'normal' CHECK (priority IN ('low','normal','high','urgent')),
  requires_human   INTEGER DEFAULT 0,
  ai_response      TEXT,
  ai_confidence    REAL,
  resolution_notes TEXT,
  opened_at        TEXT NOT NULL DEFAULT (datetime('now')),
  resolved_at      TEXT,
  updated_at       TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_tickets_status ON tickets(status, opened_at DESC);
CREATE INDEX IF NOT EXISTS idx_tickets_customer ON tickets(customer_id);
CREATE INDEX IF NOT EXISTS idx_tickets_intent ON tickets(intent);
CREATE INDEX IF NOT EXISTS idx_tickets_human ON tickets(requires_human, status);

-- ============================================================
-- TABLE : sales_analytics
-- ============================================================
CREATE TABLE IF NOT EXISTS sales_analytics (
  id               INTEGER PRIMARY KEY AUTOINCREMENT,
  period_type      TEXT NOT NULL CHECK (period_type IN ('daily','weekly','monthly')),
  period_date      TEXT NOT NULL,
  revenue          REAL DEFAULT 0,
  cost_total       REAL DEFAULT 0,
  gross_margin     REAL DEFAULT 0,
  gross_margin_pct REAL DEFAULT 0,
  orders_count     INTEGER DEFAULT 0,
  avg_order_value  REAL DEFAULT 0,
  new_customers    INTEGER DEFAULT 0,
  returning_customers INTEGER DEFAULT 0,
  top_products_json TEXT,
  top_categories_json TEXT,
  traffic_sources_json TEXT,
  refunds_count    INTEGER DEFAULT 0,
  refunds_amount   REAL DEFAULT 0,
  tickets_opened   INTEGER DEFAULT 0,
  tickets_resolved INTEGER DEFAULT 0,
  computed_at      TEXT NOT NULL DEFAULT (datetime('now')),
  UNIQUE(period_type, period_date)
);
CREATE INDEX IF NOT EXISTS idx_analytics_period ON sales_analytics(period_type, period_date DESC);

-- ============================================================
-- TABLE : cron_logs
-- ============================================================
CREATE TABLE IF NOT EXISTS cron_logs (
  id               INTEGER PRIMARY KEY AUTOINCREMENT,
  job_name         TEXT NOT NULL,
  status           TEXT NOT NULL CHECK (status IN ('started','success','failed','partial')),
  items_processed  INTEGER DEFAULT 0,
  items_failed     INTEGER DEFAULT 0,
  duration_ms      INTEGER,
  error_message    TEXT,
  payload_json     TEXT,
  started_at       TEXT NOT NULL DEFAULT (datetime('now')),
  finished_at      TEXT
);
CREATE INDEX IF NOT EXISTS idx_cron_job ON cron_logs(job_name, started_at DESC);
CREATE INDEX IF NOT EXISTS idx_cron_status ON cron_logs(status, started_at DESC);
