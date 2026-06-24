-- FIX: Recreate orders_full view with phone2 and notes
DROP VIEW IF EXISTS orders_full;
CREATE OR REPLACE VIEW orders_full AS
SELECT
  o.order_number,
  o.id,
  o.first_name || ' ' || o.last_name AS customer_name,
  o.phone,
  o.phone2,
  o.wilaya_name,
  o.commune,
  o.delivery_type,
  o.home_address,
  o.shipping_cost,
  o.subtotal,
  o.total,
  o.status,
  o.notes,
  o.created_at,
  json_agg(json_build_object(
    'product_name', oi.product_name,
    'product_image_url', oi.product_image_url,
    'size', oi.size,
    'color', oi.color,
    'quantity', oi.quantity,
    'unit_price', oi.unit_price,
    'line_total', oi.line_total
  )) AS items
FROM orders o
LEFT JOIN order_items oi ON oi.order_id = o.id
GROUP BY o.id
ORDER BY o.created_at DESC;

-- FIX: Add checkout_background to site_settings
INSERT INTO site_settings (key, value) VALUES ('checkout_background', 'https://res.cloudinary.com/dblanptpo/image/upload/q_auto/f_auto/v1781615968/puddoncitoz_pindown.io_1781615674_rz5u1y.gif')
ON CONFLICT (key) DO NOTHING;

-- Verify
SELECT key, value FROM site_settings WHERE key = 'checkout_background';
