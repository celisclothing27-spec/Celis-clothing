-- Run this in Supabase SQL Editor
-- This links existing outfit_child products to their parent outfit

-- Step 1: Check what we have
SELECT id, name, slug, category, parent_product_id, is_active
FROM products
WHERE category IN ('outfit', 'outfit_child')
ORDER BY created_at;

-- Step 2: If you see children with NULL parent_product_id,
-- you need to update them manually. Replace the IDs below:
-- UPDATE products
-- SET parent_product_id = 'PASTE_OUTFIT_ID_HERE'
-- WHERE name LIKE '% - A' AND category = 'outfit_child' AND parent_product_id IS NULL;

-- Step 3: Make sure children are active
UPDATE products
SET is_active = true
WHERE category = 'outfit_child';

-- Step 4: Ensure RLS allows reading
ALTER TABLE products DISABLE ROW LEVEL SECURITY;
ALTER TABLE product_variants DISABLE ROW LEVEL SECURITY;
ALTER TABLE product_images DISABLE ROW LEVEL SECURITY;
