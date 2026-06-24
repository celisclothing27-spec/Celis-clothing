-- Add sort_order to product_variants to preserve size order
-- Run this in Supabase SQL Editor

ALTER TABLE product_variants ADD COLUMN IF NOT EXISTS sort_order integer DEFAULT 0;

-- Set sort_order for existing variants based on created_at
UPDATE product_variants SET sort_order = sub.row_num - 1
FROM (
  SELECT id, ROW_NUMBER() OVER (PARTITION BY product_id ORDER BY created_at, id) AS row_num
  FROM product_variants
) sub
WHERE product_variants.id = sub.id;
