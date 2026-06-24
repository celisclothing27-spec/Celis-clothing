-- Add size_guide_text and size_guide_images columns to products table
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'products' AND column_name = 'size_guide_text') THEN
    ALTER TABLE products ADD COLUMN size_guide_text TEXT DEFAULT '';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'products' AND column_name = 'size_guide_images') THEN
    ALTER TABLE products ADD COLUMN size_guide_images JSONB DEFAULT '[]'::jsonb;
  END IF;
END $$;
