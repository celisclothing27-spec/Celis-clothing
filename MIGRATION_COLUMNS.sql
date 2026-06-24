-- ============================================================
-- Migration: Add missing columns to products table
-- ============================================================

-- Add size_guide columns (referenced in code but missing from schema)
ALTER TABLE products ADD COLUMN IF NOT EXISTS size_guide_text TEXT;
ALTER TABLE products ADD COLUMN IF NOT EXISTS size_guide_images TEXT[];

-- ============================================================
-- DONE! 
-- ✓ size_guide_text added
-- ✓ size_guide_images added (array for multiple images)
-- ============================================================
