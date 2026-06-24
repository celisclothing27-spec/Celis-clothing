-- ============================================================
-- Migration: Add sort_order to product_variants
-- ============================================================

ALTER TABLE product_variants ADD COLUMN IF NOT EXISTS sort_order INTEGER DEFAULT 0;

-- Done! ✓
