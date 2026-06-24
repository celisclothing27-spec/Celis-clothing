-- ============================================================
-- Complete Migration: Add ALL missing columns and tables
-- Compare: Your design vs Current database
-- ============================================================

-- ############################################################
-- 1. products — أعمدة مفقودة
-- ############################################################
ALTER TABLE products ADD COLUMN IF NOT EXISTS size_guide_text TEXT;
ALTER TABLE products ADD COLUMN IF NOT EXISTS size_guide_images TEXT[];

-- ############################################################
-- 2. orders — أعمدة مفقودة
-- ############################################################
ALTER TABLE orders ADD COLUMN IF NOT EXISTS phone2 TEXT;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS tracking_number TEXT;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS notes TEXT;

-- ############################################################
-- 3. site_settings — قيم مفقودة
-- ############################################################
INSERT INTO site_settings (key, value) VALUES
('hero_order_link', ''),
('zr_api_key', ''),
('zr_tenant_id', ''),
('admin_username', 'admin'),
('admin_password', 'Yun@2026'),
('zr_use_api_rates', 'false'),
('seo_title', ''),
('seo_description', ''),
('store_name', '')
ON CONFLICT (key) DO NOTHING;

-- ############################################################
-- 4. push_subscriptions — جدول جديد (مفقود)
-- ############################################################
CREATE TABLE IF NOT EXISTS push_subscriptions (
  id SERIAL PRIMARY KEY,
  endpoint TEXT NOT NULL UNIQUE,
  p256dh TEXT NOT NULL,
  auth TEXT NOT NULL,
  user_agent TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE push_subscriptions ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  CREATE POLICY "Public insert subscriptions"
    ON push_subscriptions FOR INSERT WITH CHECK (true);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE POLICY "Admin manage subscriptions"
    ON push_subscriptions FOR ALL USING (true) WITH CHECK (true);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- ############################################################
-- 5. product_variants — تأكد من sort_order
-- ############################################################
ALTER TABLE product_variants ADD COLUMN IF NOT EXISTS sort_order INTEGER DEFAULT 0;
UPDATE product_variants SET sort_order = 0 WHERE sort_order IS NULL;

-- ############################################################
-- 6. Fix categories constraint (make optional)
-- ############################################################
ALTER TABLE products DROP CONSTRAINT IF EXISTS products_category_check;
ALTER TABLE products ALTER COLUMN category DROP NOT NULL;
ALTER TABLE products ALTER COLUMN category SET DEFAULT 'accessories';

-- ############################################################
-- 7. Ensure all RLS policies exist
-- ############################################################

-- Categories policies
DO $$ BEGIN
  CREATE POLICY "Public read categories"
    ON categories FOR SELECT USING (true);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- Site content policies
DO $$ BEGIN
  CREATE POLICY "Public read site_content"
    ON site_content FOR SELECT USING (true);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE POLICY "Admin manage site_content"
    ON site_content FOR ALL USING (true) WITH CHECK (true);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- Homepage content policies
DO $$ BEGIN
  CREATE POLICY "Public read homepage content"
    ON homepage_content FOR SELECT USING (true);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE POLICY "Admin manage homepage content"
    ON homepage_content FOR ALL USING (true) WITH CHECK (true);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- ############################################################
-- DONE!
-- ============================================================
-- ✓ products: size_guide_text, size_guide_images added
-- ✓ orders: phone2, tracking_number, notes added
-- ✓ site_settings: hero_order_link, zr_api_key, etc. added
-- ✓ push_subscriptions: table created
-- ✓ product_variants: sort_order fixed
-- ✓ products: category constraint removed (now optional)
-- ✓ All RLS policies ensured
-- ============================================================
