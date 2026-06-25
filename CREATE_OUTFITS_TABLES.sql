-- ============================================
-- OUTFITS SYSTEM — جداول منفصلة تماما
-- شغل هذا في Supabase SQL Editor
-- ============================================

-- 1. جدول الأوتفيتات الأساسي
CREATE TABLE IF NOT EXISTS outfits (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  description TEXT DEFAULT '',
  base_price INTEGER NOT NULL DEFAULT 0,
  sale_price INTEGER,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 2. صور الأوتفيت (صورة رئيسية + صورة Size Guide)
CREATE TABLE IF NOT EXISTS outfit_images (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  outfit_id UUID REFERENCES outfits(id) ON DELETE CASCADE NOT NULL,
  cloudinary_url TEXT NOT NULL,
  cloudinary_public_id TEXT DEFAULT '',
  is_primary BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 3. منتجات الأوتفيت (Product A, Product B, إلخ)
CREATE TABLE IF NOT EXISTS outfit_products (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  outfit_id UUID REFERENCES outfits(id) ON DELETE CASCADE NOT NULL,
  label TEXT NOT NULL DEFAULT 'A',
  name TEXT NOT NULL DEFAULT '',
  image_url TEXT DEFAULT '',
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 4. متغيرات كل منتج (مقاس + سعر + كمية)
CREATE TABLE IF NOT EXISTS outfit_variants (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  outfit_product_id UUID REFERENCES outfit_products(id) ON DELETE CASCADE NOT NULL,
  size TEXT NOT NULL DEFAULT '',
  price INTEGER NOT NULL DEFAULT 0,
  stock INTEGER DEFAULT 0,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 5. تعطيل RLS للقراءة العامة
ALTER TABLE outfits DISABLE ROW LEVEL SECURITY;
ALTER TABLE outfit_images DISABLE ROW LEVEL SECURITY;
ALTER TABLE outfit_products DISABLE ROW LEVEL SECURITY;
ALTER TABLE outfit_variants DISABLE ROW LEVEL SECURITY;

-- 6. فهرس للبحث بالـ slug
CREATE INDEX IF NOT EXISTS idx_outfits_slug ON outfits(slug);
CREATE INDEX IF NOT EXISTS idx_outfit_products_outfit_id ON outfit_products(outfit_id);
CREATE INDEX IF NOT EXISTS idx_outfit_variants_product_id ON outfit_variants(outfit_product_id);
CREATE INDEX IF NOT EXISTS idx_outfit_images_outfit_id ON outfit_images(outfit_id);
