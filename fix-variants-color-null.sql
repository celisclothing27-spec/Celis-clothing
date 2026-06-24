-- Fix product_variants to allow NULL color (for size-only products)
-- Run this in Supabase SQL Editor

-- 1. Allow NULL in color column
ALTER TABLE product_variants ALTER COLUMN color DROP NOT NULL;

-- 2. Drop the old unique constraint (blocks size-only products)
ALTER TABLE product_variants DROP CONSTRAINT IF EXISTS product_variants_product_id_size_color_key;

-- 3. Allow multiple size-only variants (same product, different sizes, NULL color)
-- UNIQUE constraint only applies when color IS NOT NULL
CREATE UNIQUE INDEX IF NOT EXISTS idx_variants_unique_colored
ON product_variants(product_id, size, color)
WHERE color IS NOT NULL;

-- 4. For size-only (color=NULL), just prevent exact duplicates
CREATE UNIQUE INDEX IF NOT EXISTS idx_variants_unique_size_only
ON product_variants(product_id, size)
WHERE color IS NULL;
