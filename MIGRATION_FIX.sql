-- ============================================================
-- Fix 1: Set sort_order for existing variants
-- ============================================================
UPDATE product_variants SET sort_order = 0 WHERE sort_order IS NULL;

-- ============================================================
-- Fix 2: Add missing columns if any
-- ============================================================
ALTER TABLE product_variants ADD COLUMN IF NOT EXISTS sort_order INTEGER DEFAULT 0;
ALTER TABLE products ADD COLUMN IF NOT EXISTS size_guide_text TEXT;
ALTER TABLE products ADD COLUMN IF NOT EXISTS size_guide_images TEXT[];
