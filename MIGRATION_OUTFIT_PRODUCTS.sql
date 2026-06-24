-- Migration: Store outfit product data directly in outfit_items
-- Run this in Supabase SQL Editor — copy ALL of this and run at once

-- 1. Add product data columns to outfit_items
ALTER TABLE outfit_items ADD COLUMN IF NOT EXISTS product_name TEXT;
ALTER TABLE outfit_items ADD COLUMN IF NOT EXISTS product_name_ar TEXT;
ALTER TABLE outfit_items ADD COLUMN IF NOT EXISTS product_price NUMERIC DEFAULT 0;
ALTER TABLE outfit_items ADD COLUMN IF NOT EXISTS product_sale_price NUMERIC;
ALTER TABLE outfit_items ADD COLUMN IF NOT EXISTS product_images JSONB DEFAULT '[]';
ALTER TABLE outfit_items ADD COLUMN IF NOT EXISTS product_variants JSONB DEFAULT '[]';
ALTER TABLE outfit_items ADD COLUMN IF NOT EXISTS sort_order INTEGER DEFAULT 0;

-- 2. Drop old unique constraint
ALTER TABLE outfit_items DROP CONSTRAINT IF EXISTS outfit_items_outfit_id_product_id_variant_id_key;

-- 3. Drop and recreate the view
DROP VIEW IF EXISTS outfits_with_items;

CREATE VIEW outfits_with_items AS
SELECT 
    o.*,
    (SELECT cloudinary_url FROM outfit_images 
     WHERE outfit_id = o.id AND is_primary = true LIMIT 1) AS primary_image,
    COALESCE(
        json_agg(
            json_build_object(
                'id', oi.id,
                'product_name', oi.product_name,
                'product_name_ar', oi.product_name_ar,
                'product_price', oi.product_price,
                'product_sale_price', oi.product_sale_price,
                'product_images', oi.product_images,
                'product_variants', oi.product_variants,
                'quantity', oi.quantity,
                'sort_order', oi.sort_order
            ) ORDER BY oi.sort_order
        ) FILTER (WHERE oi.id IS NOT NULL),
        '[]'
    ) AS items
FROM outfits o
LEFT JOIN outfit_items oi ON o.id = oi.outfit_id
GROUP BY o.id;

-- 4. Ensure RLS allows all operations
DROP POLICY IF EXISTS "Allow all outfit_items" ON outfit_items;
CREATE POLICY "Allow all outfit_items" ON outfit_items FOR ALL USING (true) WITH CHECK (true);

SELECT '✅ Migration complete' AS result;
