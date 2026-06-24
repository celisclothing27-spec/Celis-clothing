-- ============================================================
-- Migration: Make category optional in products table
-- ============================================================

-- Remove the NOT NULL and CHECK constraint on category
ALTER TABLE products ALTER COLUMN category DROP NOT NULL;
ALTER TABLE products ALTER COLUMN category SET DEFAULT 'accessories';

-- Done! Category is now optional
-- If empty, it will default to 'accessories'
-- ============================================================
