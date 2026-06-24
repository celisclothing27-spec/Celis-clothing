-- Add phone2 and notes columns to orders table
ALTER TABLE orders ADD COLUMN IF NOT EXISTS phone2 TEXT;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS notes TEXT;

-- Verify
SELECT column_name, data_type FROM information_schema.columns
WHERE table_name = 'orders' AND column_name IN ('phone2', 'notes');
