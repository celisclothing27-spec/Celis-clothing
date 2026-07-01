-- ============================================
-- COMPREHENSIVE OUTFIT FIX
-- Run this in Supabase SQL Editor
-- ============================================

-- 1. Ensure outfit_products has all needed columns
ALTER TABLE outfit_products ADD COLUMN IF NOT EXISTS price INTEGER DEFAULT 0;
ALTER TABLE outfit_products ADD COLUMN IF NOT EXISTS category TEXT DEFAULT '';

-- 2. Ensure outfit_variants has color column
ALTER TABLE outfit_variants ADD COLUMN IF NOT EXISTS color TEXT DEFAULT '';

-- 3. Ensure outfit_variants has price column
ALTER TABLE outfit_variants ADD COLUMN IF NOT EXISTS price INTEGER DEFAULT 0;

-- 4. Disable RLS on all outfit tables (allow public read)
ALTER TABLE outfits DISABLE ROW LEVEL SECURITY;
ALTER TABLE outfit_images DISABLE ROW LEVEL SECURITY;
ALTER TABLE outfit_products DISABLE ROW LEVEL SECURITY;
ALTER TABLE outfit_variants DISABLE ROW LEVEL SECURITY;

-- 5. Verify data exists
DO $$
DECLARE
  prod_count INTEGER;
  var_count INTEGER;
BEGIN
  SELECT count(*) INTO prod_count FROM outfit_products;
  SELECT count(*) INTO var_count FROM outfit_variants;
  RAISE NOTICE 'outfit_products: % rows, outfit_variants: % rows', prod_count, var_count;
END $$;
