-- Add is_bestseller column to products (if not exists)
ALTER TABLE products ADD COLUMN IF NOT EXISTS is_bestseller BOOLEAN DEFAULT false;

-- Add is_bestseller column to outfits (if not exists)
ALTER TABLE outfits ADD COLUMN IF NOT EXISTS is_bestseller BOOLEAN DEFAULT false;

-- Verify
SELECT column_name FROM information_schema.columns
WHERE table_name = 'products' AND column_name = 'is_bestseller';
SELECT column_name FROM information_schema.columns
WHERE table_name = 'outfits' AND column_name = 'is_bestseller';
