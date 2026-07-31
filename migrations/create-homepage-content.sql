-- ============================================================
-- Migration: Create homepage_content table
-- Run this in Supabase SQL Editor
-- ============================================================

CREATE TABLE IF NOT EXISTS homepage_content (
  id SERIAL PRIMARY KEY,
  field TEXT NOT NULL,
  lang TEXT NOT NULL DEFAULT 'en' CHECK (lang IN ('en', 'ar', 'fr')),
  value TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(field, lang)
);

-- Enable RLS
ALTER TABLE homepage_content ENABLE ROW LEVEL SECURITY;

-- Allow public read access
CREATE POLICY "Public read homepage content"
  ON homepage_content FOR SELECT USING (true);

-- Allow admin full access
CREATE POLICY "Admin manage homepage content"
  ON homepage_content FOR ALL USING (true) WITH CHECK (true);

-- Insert default English content
INSERT INTO homepage_content (field, lang, value) VALUES
('hero_title', 'en', 'Premium Fashion for the Modern Era'),
('hero_cta', 'en', '<a href="products.html" class="btn-hero-primary">Shop Now</a>'),
('cat_title', 'en', 'Shop by Category'),
('featured_title', 'en', 'Featured Products'),
('about_title', 'en', 'About Celis'),
('about_subtitle', 'en', 'Premium fashion for the modern era'),
('story_title', 'en', 'Our Story'),
('story_text', 'en', 'Founded in Algeria, Celis brings premium fashion to the modern era.'),
('values_title', 'en', 'Our Values'),
('values_text', 'en', 'Quality, Innovation, and Customer Satisfaction'),
('footer_text', 'en', '© 2026 Celis clothing. All rights reserved.'),
('contact_email', 'en', 'contact@celis.dz'),
('contact_phone', 'en', '+213555555555'),
('contact_address', 'en', 'Algeria')
ON CONFLICT (field, lang) DO NOTHING;

-- Insert default Arabic content
INSERT INTO homepage_content (field, lang, value) VALUES
('hero_title', 'ar', 'أزياء فاخرة للعصر الحديث'),
('hero_cta', 'ar', '<a href="products.html" class="btn-hero-primary">تسوق الآن</a>'),
('cat_title', 'ar', 'تسوق حسب الفئة'),
('featured_title', 'ar', 'منتجات مميزة'),
('about_title', 'ar', 'عن سيليس'),
('about_subtitle', 'ar', 'أزياء فاخرة للعصر الحديث'),
('story_title', 'ar', 'قصتنا'),
('story_text', 'ar', 'تأسست في الجزائر، تقدم سيليس أزياء فاخرة للعصر الحديث.'),
('values_title', 'ar', 'قيمنا'),
('values_text', 'ar', 'الجودة والابتكار ورضا العملاء'),
('footer_text', 'ar', '© 2026 سيليس. جميع الحقوق محفوظة.'),
('contact_email', 'ar', 'contact@celis.dz'),
('contact_phone', 'ar', '+213555555555'),
('contact_address', 'ar', 'الجزائر')
ON CONFLICT (field, lang) DO NOTHING;

-- Insert default French content
INSERT INTO homepage_content (field, lang, value) VALUES
('hero_title', 'fr', 'Mode Premium pour l''Ère Moderne'),
('hero_cta', 'fr', '<a href="products.html" class="btn-hero-primary">Acheter</a>'),
('cat_title', 'fr', 'Acheter par Catégorie'),
('featured_title', 'fr', 'Produits Vedettes'),
('about_title', 'fr', 'À propos de Celis'),
('about_subtitle', 'fr', 'Mode premium pour l''ère moderne'),
('story_title', 'fr', 'Notre Histoire'),
('story_text', 'fr', 'Fondée en Algérie, Celis offre une mode premium pour l''ère moderne.'),
('values_title', 'fr', 'Nos Valeurs'),
('values_text', 'fr', 'Qualité, Innovation et Satisfaction Client'),
('footer_text', 'fr', '© 2026 Celis. Tous droits réservés.'),
('contact_email', 'fr', 'contact@celis.dz'),
('contact_phone', 'fr', '+213555555555'),
('contact_address', 'fr', 'Algérie')
ON CONFLICT (field, lang) DO NOTHING;
