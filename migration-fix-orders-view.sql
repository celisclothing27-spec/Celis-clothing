CREATE OR REPLACE VIEW orders_full AS
SELECT
  o.order_number,
  o.id,
  o.first_name || ' ' || o.last_name AS customer_name,
  o.first_name,
  o.last_name,
  o.phone,
  o.phone2,
  o.wilaya_code,
  o.wilaya_name,
  o.commune,
  o.delivery_type,
  o.home_address,
  o.shipping_cost,
  o.subtotal,
  o.total,
  o.notes,
  o.status,
  o.tracking_number,
  o.created_at,
  json_agg(json_build_object(
    'product', oi.product_name,
    'image', oi.product_image_url,
    'size', oi.size,
    'color', oi.color,
    'qty', oi.quantity,
    'price', oi.unit_price,
    'total', oi.line_total,
    'variant_id', oi.variant_id,
    'product_name', oi.product_name
  )) AS items
FROM orders o
LEFT JOIN order_items oi ON oi.order_id = o.id
GROUP BY o.id
ORDER BY o.created_at DESC;
