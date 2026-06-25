-- Add parent_product_id to products table
-- This replaces the outfit_items table entirely

ALTER TABLE products ADD COLUMN IF NOT EXISTS parent_product_id UUID REFERENCES products(id) ON DELETE CASCADE;

CREATE INDEX IF NOT EXISTS idx_products_parent ON products(parent_product_id);
