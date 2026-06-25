-- 1. أضف عمود parent_product_id
ALTER TABLE products ADD COLUMN IF NOT EXISTS parent_product_id UUID REFERENCES products(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_products_parent ON products(parent_product_id);

-- 2. حدّث الـ CHECK constraint يسمح بـ outfit_child
ALTER TABLE products DROP CONSTRAINT IF EXISTS products_category_check;
ALTER TABLE products ADD CONSTRAINT products_category_check CHECK (length(category) > 0);
