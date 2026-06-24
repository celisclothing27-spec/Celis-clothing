-- ============================================================
-- Migration: Add missing tables + data only
-- Safe to run — will NOT affect existing tables
-- ============================================================

-- ############################################################
-- TABLE: homepage_content (MISSING - needs to be created)
-- ############################################################
CREATE TABLE IF NOT EXISTS homepage_content (
  id SERIAL PRIMARY KEY,
  field TEXT NOT NULL,
  lang TEXT NOT NULL DEFAULT 'en' CHECK (lang IN ('en','ar','fr')),
  value TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(field, lang)
);

ALTER TABLE homepage_content ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  CREATE POLICY "Public read homepage content"
    ON homepage_content FOR SELECT USING (true);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE POLICY "Admin manage homepage content"
    ON homepage_content FOR ALL USING (true) WITH CHECK (true);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DROP TRIGGER IF EXISTS homepage_content_updated_at ON homepage_content;
CREATE TRIGGER homepage_content_updated_at
  BEFORE UPDATE ON homepage_content
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ############################################################
-- TABLE: admin_users (MISSING - needs to be created)
-- ############################################################
CREATE TABLE IF NOT EXISTS admin_users (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  access_code TEXT UNIQUE NOT NULL,
  permissions TEXT[] NOT NULL DEFAULT '{}',
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE admin_users ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  CREATE POLICY "Admin manage admin_users"
    ON admin_users FOR ALL USING (true) WITH CHECK (true);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

CREATE INDEX IF NOT EXISTS idx_admin_users_access_code ON admin_users(access_code);
CREATE INDEX IF NOT EXISTS idx_admin_users_active ON admin_users(is_active);

-- ############################################################
-- DEFAULT DATA: Homepage Content (EN)
-- ############################################################
INSERT INTO homepage_content (field, lang, value) VALUES
('hero_title', 'en', 'Premium Fashion for the Modern Era'),
('hero_cta', 'en', '<a href="products.html" class="btn-hero-primary">Shop Now</a>'),
('cat_title', 'en', 'Shop by Category'),
('featured_title', 'en', 'Featured Products'),
('footer_text', 'en', '© 2026 Celis clothing. All rights reserved.')
ON CONFLICT (field, lang) DO NOTHING;

-- ############################################################
-- DEFAULT DATA: Homepage Content (AR)
-- ############################################################
INSERT INTO homepage_content (field, lang, value) VALUES
('hero_title', 'ar', 'أزياء فاخرة للعصر الحديث'),
('hero_cta', 'ar', '<a href="products.html" class="btn-hero-primary">تسوق الآن</a>'),
('cat_title', 'ar', 'تسوق حسب الفئة'),
('featured_title', 'ar', 'منتجات مميزة'),
('footer_text', 'ar', '© 2026 سيليس. جميع الحقوق محفوظة.')
ON CONFLICT (field, lang) DO NOTHING;

-- ############################################################
-- DEFAULT DATA: Homepage Content (FR)
-- ############################################################
INSERT INTO homepage_content (field, lang, value) VALUES
('hero_title', 'fr', 'Mode Premium pour l''Ère Moderne'),
('hero_cta', 'fr', '<a href="products.html" class="btn-hero-primary">Acheter</a>'),
('cat_title', 'fr', 'Acheter par Catégorie'),
('featured_title', 'fr', 'Produits Vedettes'),
('footer_text', 'fr', '© 2026 Celis. Tous droits réservés.')
ON CONFLICT (field, lang) DO NOTHING;

-- ############################################################
-- DEFAULT DATA: Admin Credentials (if not exists)
-- ############################################################
INSERT INTO site_settings (key, value) VALUES
('admin_username', 'admin'),
('admin_password', 'Yun@2026'),
('zr_use_api_rates', 'false'),
('checkout_background', ''),
('products_page_eyebrow', ''),
('products_page_title', '')
ON CONFLICT (key) DO NOTHING;

-- ############################################################
-- DEFAULT DATA: About Page (EN) - only if empty
-- ############################################################
INSERT INTO site_content (section, field, lang, value, sort_order) VALUES
('about_hero', 'title', 'en', 'WHO WE ARE', 1),
('about_hero', 'subtitle', 'en', 'Y2K Fashion Revival // Digital Age', 2),
('about_story', 'heading', 'en', 'Our Story', 1),
('about_story', 'paragraph1', 'en', 'Celis clothing was born from the intersection of nostalgia and digital culture.', 2),
('about_story', 'paragraph2', 'en', 'Every piece in our collection is a nod to the early 2000s.', 3),
('about_story', 'tagline', 'en', 'Digital Natives. Physical Style.', 4),
('about_values', 'v1_title', 'en', 'Quality', 1),
('about_values', 'v1_desc', 'en', 'Premium materials and construction.', 2),
('about_values', 'v2_title', 'en', 'Authenticity', 3),
('about_values', 'v2_desc', 'en', 'Real Y2K inspiration, not fast-fashion copies.', 4),
('about_values', 'v3_title', 'en', 'Digital-First', 5),
('about_values', 'v3_desc', 'en', 'Born online, built for the scroll generation.', 6),
('about_contact', 'phone', 'en', '+213 555 55 55 55', 1),
('about_contact', 'email', 'en', 'contact@celis.dz', 2),
('about_contact', 'instagram', 'en', '@celis.dz', 3),
('about_contact', 'address', 'en', 'Algeria', 4),
('about_contact', 'hours', 'en', 'Sat — Thu, 10:00 AM — 8:00 PM', 5)
ON CONFLICT (section, field, lang) DO NOTHING;

-- ############################################################
-- DEFAULT DATA: About Page (AR)
-- ############################################################
INSERT INTO site_content (section, field, lang, value, sort_order) VALUES
('about_hero', 'title', 'ar', 'من نحن', 1),
('about_hero', 'subtitle', 'ar', 'إحياء أزياء Y2K // العصر الرقمي', 2),
('about_story', 'heading', 'ar', 'قصتنا', 1),
('about_story', 'paragraph1', 'ar', 'ولدت Celis clothing من تقاطع الحنين والثقافة الرقمية.', 2),
('about_story', 'paragraph2', 'ar', 'كل قطعة في مجموعتنا هي إشارة إلى أوائل الألفية.', 3),
('about_story', 'tagline', 'ar', 'أبناء الرقم. أسلوب مادي.', 4),
('about_values', 'v1_title', 'ar', 'الجودة', 1),
('about_values', 'v1_desc', 'ar', 'مواد وتركيب متميز.', 2),
('about_values', 'v2_title', 'ar', 'الأصالة', 3),
('about_values', 'v2_desc', 'ar', 'إلهام Y2K حقيقي.', 4),
('about_values', 'v3_title', 'ar', 'رقمي أولاً', 5),
('about_values', 'v3_desc', 'ar', 'وُلدنا أونلاين، صُنعنا لجيل التمرير.', 6),
('about_contact', 'phone', 'ar', '+213 555 55 55 55', 1),
('about_contact', 'email', 'ar', 'contact@celis.dz', 2),
('about_contact', 'instagram', 'ar', '@celis.dz', 3),
('about_contact', 'address', 'ar', 'الجزائر', 4),
('about_contact', 'hours', 'ar', 'السبت — الخميس، 10:00 صباحًا — 8:00 مساءً', 5)
ON CONFLICT (section, field, lang) DO NOTHING;

-- ############################################################
-- DEFAULT DATA: About Page (FR)
-- ############################################################
INSERT INTO site_content (section, field, lang, value, sort_order) VALUES
('about_hero', 'title', 'fr', 'QUI SOMMES-NOUS', 1),
('about_hero', 'subtitle', 'fr', 'Renaissance Y2K // Ère Numérique', 2),
('about_story', 'heading', 'fr', 'Notre Histoire', 1),
('about_story', 'paragraph1', 'fr', 'Celis clothing est née de l''intersection de la nostalgie et de la culture numérique.', 2),
('about_story', 'paragraph2', 'fr', 'Chaque pièce de notre collection est un hommage aux années 2000.', 3),
('about_story', 'tagline', 'fr', 'Enfants du Numérique. Style Physique.', 4),
('about_values', 'v1_title', 'fr', 'Qualité', 1),
('about_values', 'v1_desc', 'fr', 'Matériaux et construction premium.', 2),
('about_values', 'v2_title', 'fr', 'Authenticité', 3),
('about_values', 'v2_desc', 'fr', 'Inspiration Y2K réelle.', 4),
('about_values', 'v3_title', 'fr', 'Numérique d''Abord', 5),
('about_values', 'v3_desc', 'fr', 'Nés en ligne, construits pour la génération du scroll.', 6),
('about_contact', 'phone', 'fr', '+213 555 55 55 55', 1),
('about_contact', 'email', 'fr', 'contact@celis.dz', 2),
('about_contact', 'instagram', 'fr', '@celis.dz', 3),
('about_contact', 'address', 'fr', 'Algérie', 4),
('about_contact', 'hours', 'fr', 'Sam — Jeu, 10h00 — 20h00', 5)
ON CONFLICT (section, field, lang) DO NOTHING;

-- ============================================================
-- DONE! 
-- ✓ homepage_content table created
-- ✓ admin_users table created  
-- ✓ Default data inserted (EN/AR/FR)
-- ✓ No existing tables affected
-- ============================================================
