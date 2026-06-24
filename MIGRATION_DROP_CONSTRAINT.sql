-- ============================================================
-- Migration: Drop category check constraint from products
-- ============================================================

-- Drop the CHECK constraint that limits category values
ALTER TABLE products DROP CONSTRAINT IF EXISTS products_category_check;

-- Make category optional with default value
ALTER TABLE products ALTER COLUMN category DROP NOT NULL;
ALTER TABLE products ALTER COLUMN category SET DEFAULT 'accessories';

-- Done! Now you can use any category or leave it empty
-- ============================================================
