-- Update products_with_stock view to include type column
-- Run this in Supabase SQL Editor

DROP VIEW IF EXISTS products_with_stock;

CREATE VIEW products_with_stock AS
SELECT
  p.id,
  p.name,
  p.category,
  p.type,
  p.base_price,
  p.sale_price,
  p.slug,
  p.is_active,
  COUNT(DISTINCT pv.id) AS variant_count,
  COALESCE(SUM(pv.stock), 0) AS total_stock,
  (SELECT cloudinary_url FROM product_images
   WHERE product_id = p.id AND is_primary = TRUE LIMIT 1) AS primary_image
FROM products p
LEFT JOIN product_variants pv ON pv.product_id = p.id
GROUP BY p.id
ORDER BY p.created_at DESC;

-- Verify
SELECT column_name FROM information_schema.columns 
WHERE table_name = 'products_with_stock' ORDER BY ordinal_position;
