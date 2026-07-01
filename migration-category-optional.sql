-- Make product category optional (nullable)
ALTER TABLE products ALTER COLUMN category DROP NOT NULL;

-- Add category column to outfits table (optional)
ALTER TABLE outfits ADD COLUMN IF NOT EXISTS category TEXT;

-- Verify
SELECT column_name, is_nullable FROM information_schema.columns
WHERE table_name = 'products' AND column_name = 'category';
SELECT column_name, is_nullable FROM information_schema.columns
WHERE table_name = 'outfits' AND column_name = 'category';
