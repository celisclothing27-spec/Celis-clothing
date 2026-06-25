-- Fix outfit_items table to match code
-- The old schema used outfit_id/product_id/variant_id but code uses outfit_product_id/child_product_id/display_order

DROP TABLE IF EXISTS outfit_items;

CREATE TABLE outfit_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  outfit_product_id UUID REFERENCES products(id) ON DELETE CASCADE,
  child_product_id UUID REFERENCES products(id) ON DELETE CASCADE,
  display_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_outfit_items_outfit ON outfit_items(outfit_product_id);
CREATE INDEX idx_outfit_items_child ON outfit_items(child_product_id);

ALTER TABLE outfit_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public read outfit_items" ON outfit_items FOR SELECT USING (true);
CREATE POLICY "Admin manage outfit_items" ON outfit_items FOR ALL USING (true) WITH CHECK (true);
