-- ============================================================
-- Celis clothing — Dark Luxury Fashion E-Commerce (Algeria Market)
-- Supabase Database Schema
-- ============================================================

-- ############################################################
-- TABLE 1: products
-- ############################################################
create table products (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  name_ar text,
  slug text unique not null,
  description text,
  description_ar text,
  category text not null check (category in ('outerwear','hoodies','jackets','t-shirts','pants','accessories','outfit','layering','footwear')),
  base_price integer not null,
  sale_price integer,
  is_active boolean default true,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- ############################################################
-- TABLE 2: product_images
-- ############################################################
create table product_images (
  id uuid default gen_random_uuid() primary key,
  product_id uuid references products(id) on delete cascade,
  cloudinary_url text not null,
  cloudinary_public_id text not null,
  is_primary boolean default false,
  sort_order integer default 0,
  created_at timestamptz default now()
);

-- ############################################################
-- TABLE 3: product_variants
-- Each variant = one combination of (size + color) with its own
-- price and stock.  Example: Size L + Color Black = 6 units at 12500 DA
-- ############################################################
create table product_variants (
  id uuid default gen_random_uuid() primary key,
  product_id uuid references products(id) on delete cascade,
  size text not null,         -- e.g. 'XS','S','M','L','XL','XXL'
  color text not null,        -- e.g. 'Black','White','Red'
  color_hex text,             -- e.g. '#1a1a1a'
  price integer not null,     -- can differ from base_price
  stock integer not null default 0 check (stock >= 0),
  sku text unique,
  is_active boolean default true,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  unique(product_id, size, color)
);

-- ############################################################
-- TABLE 3b: categories
-- Admin-managed categories with images
-- ############################################################
create table categories (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  slug text unique not null,
  image_url text,
  is_active boolean default true,
  created_at timestamptz default now()
);

-- ############################################################
-- TABLE 4: wilaya_pricing  (Algeria shipping zones)
-- ############################################################
create table wilaya_pricing (
  id serial primary key,
  wilaya_code text not null unique,
  wilaya_name text not null,
  home_price integer not null,
  post_price integer not null
);

insert into wilaya_pricing (wilaya_code, wilaya_name, home_price, post_price) values
('01','Adrar',1400,970),('02','Chlef',850,520),('03','Laghouat',950,620),
('04','Oum El Bouaghi',850,520),('05','Batna',900,520),('06','Bejaia',800,520),
('07','Biskra',950,620),('08','Bechar',1200,970),('09','Blida',600,470),
('10','Bouira',700,520),('11','Tamanrasset',1600,1120),('12','Tebessa',900,520),
('13','Tlemcen',900,570),('14','Tiaret',850,520),('15','Tizi Ouzou',750,520),
('16','Alger',500,370),('17','Djelfa',950,570),('18','Jijel',900,520),
('19','Setif',800,520),('20','Saida',900,570),('21','Skikda',900,520),
('22','Sidi Bel Abbes',900,520),('23','Annaba',850,520),('24','Guelma',900,520),
('25','Constantine',800,520),('26','Medea',800,520),('27','Mostaganem',900,520),
('28','Mila',850,570),('29','Mascara',900,520),('30','Ouargla',950,670),
('31','Oran',800,520),('32','El Bayadh',1100,670),
('34','Bordj Bou Arreridj',800,520),
('42','Tipaza',700,520),('43','Mila',900,520),('44','Ain Defla',900,520),
('45','Naama',1100,670),('46','Ain Temouchent',900,520),('47','Ghardaia',950,620),
('48','Relizane',900,520),('49','Timimoun',1400,970),
('51','Ouled Djellal',950,620),('52','Beni Abbes',1200,970),
('53','In Salah',1600,1120),('54','In Guezzam',1600,0),
('55','Touggourt',950,670),('57','El Meghaier',950,0),
('58','El Menia',1000,670);

-- ############################################################
-- TABLE 5: orders
-- ############################################################
create table orders (
  id uuid default gen_random_uuid() primary key,
  order_number bigint generated always as identity,

  -- Customer info
  first_name text not null,
  last_name text not null,
  phone text not null,

  -- Location
  wilaya_code text references wilaya_pricing(wilaya_code),
  wilaya_name text not null,
  commune text not null,

  -- Delivery
  delivery_type text not null check (delivery_type in ('home','post')),
  home_address text,
  shipping_cost integer not null,

  -- Pricing
  subtotal integer not null,
  total integer not null,

  -- Status
  status text not null default 'pending'
    check (status in ('pending','confirmed','processing','shipped','delivered','cancelled')),

  -- Meta tracking
  meta_event_id text,

  -- Timestamps
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- ############################################################
-- TABLE 6: order_items
-- Snapshot of variant + price at time of purchase
-- ############################################################
create table order_items (
  id uuid default gen_random_uuid() primary key,
  order_id uuid references orders(id) on delete cascade,
  product_id uuid references products(id),
  variant_id uuid references product_variants(id),

  -- Snapshot at time of order
  product_name text not null,
  product_image_url text,
  size text not null,
  color text not null,
  unit_price integer not null,
  quantity integer not null check (quantity > 0),
  line_total integer not null,

  created_at timestamptz default now()
);

-- ############################################################
-- TABLE 7: stock_movements
-- Audit log for every stock change
-- ############################################################
create table stock_movements (
  id uuid default gen_random_uuid() primary key,
  variant_id uuid references product_variants(id) on delete cascade,
  order_id uuid references orders(id),
  movement_type text not null check (movement_type in ('sale','restock','adjustment','cancelled')),
  quantity_change integer not null,
  stock_before integer not null,
  stock_after integer not null,
  note text,
  created_at timestamptz default now()
);

-- ############################################################
-- FUNCTIONS & TRIGGERS
-- ############################################################

-- Auto-update updated_at
create or replace function update_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger products_updated_at
  before update on products
  for each row execute function update_updated_at();

create trigger variants_updated_at
  before update on product_variants
  for each row execute function update_updated_at();

create trigger orders_updated_at
  before update on orders
  for each row execute function update_updated_at();

-- Decrease stock when order is placed + log movement
create or replace function decrease_stock_on_order(
  p_variant_id uuid,
  p_quantity integer,
  p_order_id uuid
) returns void as $$
declare
  current_stock integer;
begin
  select stock into current_stock
  from product_variants
  where id = p_variant_id
  for update;

  if current_stock < p_quantity then
    raise exception 'Insufficient stock for variant %', p_variant_id;
  end if;

  update product_variants
  set stock = stock - p_quantity
  where id = p_variant_id;

  insert into stock_movements (
    variant_id, order_id, movement_type,
    quantity_change, stock_before, stock_after
  ) values (
    p_variant_id, p_order_id, 'sale',
    -p_quantity, current_stock, current_stock - p_quantity
  );
end;
$$ language plpgsql;

-- Restore stock when order is cancelled
create or replace function restore_stock_on_cancel(
  p_order_id uuid
) returns void as $$
declare
  item record;
  current_stock integer;
begin
  for item in
    select variant_id, quantity from order_items where order_id = p_order_id
  loop
    select stock into current_stock
    from product_variants where id = item.variant_id;

    update product_variants
    set stock = stock + item.quantity
    where id = item.variant_id;

    insert into stock_movements (
      variant_id, order_id, movement_type,
      quantity_change, stock_before, stock_after
    ) values (
      item.variant_id, p_order_id, 'cancelled',
      item.quantity, current_stock, current_stock + item.quantity
    );
  end loop;
end;
$$ language plpgsql;

-- ############################################################
-- INDEXES
-- ############################################################

create index idx_products_category on products(category);
create index idx_products_slug on products(slug);
create index idx_products_active on products(is_active);
create index idx_variants_product on product_variants(product_id);
create index idx_variants_stock on product_variants(stock);
create index idx_images_product on product_images(product_id);
create index idx_orders_status on orders(status);
create index idx_orders_phone on orders(phone);
create index idx_orders_created on orders(created_at desc);
create index idx_order_items_order on order_items(order_id);
create index idx_stock_movements_variant on stock_movements(variant_id);

-- ############################################################
-- ROW LEVEL SECURITY (RLS)
-- ############################################################

alter table products enable row level security;
alter table product_images enable row level security;
alter table product_variants enable row level security;
alter table wilaya_pricing enable row level security;
alter table orders enable row level security;
alter table order_items enable row level security;
alter table stock_movements enable row level security;

-- Public read policies
create policy "Public read products"
  on products for select using (is_active = true);

create policy "Public read images"
  on product_images for select using (true);

create policy "Public read variants"
  on product_variants for select using (is_active = true);

create policy "Public read wilaya pricing"
  on wilaya_pricing for select using (true);

-- Public insert policies (place order without login)
create policy "Public insert orders"
  on orders for insert with check (true);

create policy "Public insert order items"
  on order_items for insert with check (true);

-- Admin full-access policies (all operations for password-gated dashboard)
create policy "Admin manage products"
  on products for all using (true) with check (true);

create policy "Admin manage images"
  on product_images for all using (true) with check (true);

create policy "Admin manage variants"
  on product_variants for all using (true) with check (true);

create policy "Admin manage orders"
  on orders for all using (true) with check (true);

create policy "Admin manage order_items"
  on order_items for all using (true) with check (true);

create policy "Admin manage stock_movements"
  on stock_movements for all using (true) with check (true);

create policy "Admin manage site_settings"
  on site_settings for all using (true) with check (true);

create policy "Admin manage categories"
  on categories for all using (true) with check (true);

-- ############################################################
-- TABLE 8: site_settings
-- Stores global site configuration (hero video, etc.)
-- ############################################################
create table site_settings (
  key text primary key,
  value text,
  updated_at timestamptz default now()
);

insert into site_settings (key, value) values
('hero_video_url', ''),
('logo_url', 'https://res.cloudinary.com/dblanptpo/image/upload/q_auto/f_auto/v1781461884/IMG_20260531_223119_1_ebk1xo.png'),
('instagram_url', 'https://instagram.com/yun.store.dz'),
('whatsapp_phone', '+213555555555'),
('email_address', 'contact@yunstore.dz'),
('store_address', 'Algeria'),
('working_hours', 'Sat — Thu, 10:00 AM — 8:00 PM'),
('zr_use_api_rates', 'false'),
('admin_username', 'admin'),
('admin_password', 'Yun@2026')
on conflict (key) do nothing;

-- ############################################################
-- TABLE 9: site_content  (About page + multilingual content)
-- ############################################################
create table site_content (
  id uuid default gen_random_uuid() primary key,
  section text not null,        -- e.g. 'about_hero', 'about_story', 'about_values'
  field text not null,          -- e.g. 'title', 'subtitle', 'description', 'tagline'
  lang text not null default 'en' check (lang in ('en','ar','fr')),
  value text,
  sort_order integer default 0,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  unique(section, field, lang)
);

alter table site_content enable row level security;

create policy "Public read site_content"
  on site_content for select using (true);

create policy "Admin manage site_content"
  on site_content for all using (true) with check (true);

create trigger site_content_updated_at
  before update on site_content
  for each row execute function update_updated_at();

-- ############################################################
-- TABLE 10: homepage_content  (Homepage multilingual content)
-- ############################################################
create table homepage_content (
  id serial primary key,
  field text not null,
  lang text not null default 'en' check (lang in ('en','ar','fr')),
  value text,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  unique(field, lang)
);

alter table homepage_content enable row level security;

create policy "Public read homepage content"
  on homepage_content for select using (true);

create policy "Admin manage homepage content"
  on homepage_content for all using (true) with check (true);

create trigger homepage_content_updated_at
  before update on homepage_content
  for each row execute function update_updated_at();

-- Insert default Homepage content (English)
insert into homepage_content (field, lang, value) values
('hero_title', 'en', 'Premium Fashion for the Modern Era'),
('hero_cta', 'en', '<a href="products.html" class="btn-hero-primary">Shop Now</a>'),
('cat_title', 'en', 'Shop by Category'),
('featured_title', 'en', 'Featured Products'),
('footer_text', 'en', '© 2026 Celis clothing. All rights reserved.')
on conflict (field, lang) do nothing;

-- Insert default Homepage content (Arabic)
insert into homepage_content (field, lang, value) values
('hero_title', 'ar', 'أزياء فاخرة للعصر الحديث'),
('hero_cta', 'ar', '<a href="products.html" class="btn-hero-primary">تسوق الآن</a>'),
('cat_title', 'ar', 'تسوق حسب الفئة'),
('featured_title', 'ar', 'منتجات مميزة'),
('footer_text', 'ar', '© 2026 سيليس. جميع الحقوق محفوظة.')
on conflict (field, lang) do nothing;

-- Insert default Homepage content (French)
insert into homepage_content (field, lang, value) values
('hero_title', 'fr', 'Mode Premium pour l''Ère Moderne'),
('hero_cta', 'fr', '<a href="products.html" class="btn-hero-primary">Acheter</a>'),
('cat_title', 'fr', 'Acheter par Catégorie'),
('featured_title', 'fr', 'Produits Vedettes'),
('footer_text', 'fr', '© 2026 Celis. Tous droits réservés.')
on conflict (field, lang) do nothing;

-- Insert default About page content (English)
insert into site_content (section, field, lang, value, sort_order) values
-- Hero
('about_hero', 'title', 'en', 'WHO WE ARE', 1),
('about_hero', 'subtitle', 'en', 'Y2K Fashion Revival // Digital Age', 2),
-- Story
('about_story', 'heading', 'en', 'Our Story', 1),
('about_story', 'paragraph1', 'en', 'Celis clothing was born from the intersection of nostalgia and digital culture. We curate Y2K-inspired fashion that bridges the gap between retro aesthetics and modern streetwear — designed for the generation that grew up in the pixel era.', 2),
('about_story', 'paragraph2', 'en', 'Every piece in our collection is a nod to the early 2000s — the glossy textures, the bold silhouettes, the digital-age attitude. We source, design, and deliver with one mission: make Y2K fashion accessible to Algeria and beyond.', 3),
('about_story', 'tagline', 'en', 'Digital Natives. Physical Style.', 4),
-- Values
('about_values', 'v1_title', 'en', 'Quality', 1),
('about_values', 'v1_desc', 'en', 'Premium materials and construction. Every piece is built to last beyond trends.', 2),
('about_values', 'v2_title', 'en', 'Authenticity', 3),
('about_values', 'v2_desc', 'en', 'Real Y2K inspiration, not fast-fashion copies. We curate with intent.', 4),
('about_values', 'v3_title', 'en', 'Digital-First', 5),
('about_values', 'v3_desc', 'en', 'Born online, built for the scroll generation. From our website to your door.', 6),
-- Contact
('about_contact', 'phone', 'en', '+213 555 55 55 55', 1),
('about_contact', 'email', 'en', 'contact@yunstore.dz', 2),
('about_contact', 'instagram', 'en', '@yun.store.dz', 3),
('about_contact', 'address', 'en', 'Algeria', 4),
('about_contact', 'hours', 'en', 'Sat — Thu, 10:00 AM — 8:00 PM', 5)
on conflict (section, field, lang) do nothing;

-- Insert Arabic translations
insert into site_content (section, field, lang, value, sort_order) values
('about_hero', 'title', 'ar', 'من نحن', 1),
('about_hero', 'subtitle', 'ar', 'إحياء أزياء Y2K // العصر الرقمي', 2),
('about_story', 'heading', 'ar', 'قصتنا', 1),
('about_story', 'paragraph1', 'ar', 'ولدت Celis clothing من تقاطع الحنين والثقافة الرقمية. نقدم أزياء مستوحاة من Y2K تسد الفج بين الجماليات العصرية والملابس العصرية — مصممة للجيل الذي نشأ في عصر البكسل.', 2),
('about_story', 'paragraph2', 'ar', 'كل قطعة في مجموعتنا هي إشارة إلى أوائل الألفية — النسيج اللامع، الأشكال الجريئة، وال attitudes العصرية. نختار ونصمم ونوصّل بهدف واحد: جعل أزياء Y2K متاحة للجزائر وما بعدها.', 3),
('about_story', 'tagline', 'ar', 'أبناء الرقم. أسلوب مادي.', 4),
('about_values', 'v1_title', 'ar', 'الجودة', 1),
('about_values', 'v1_desc', 'ar', 'مواد وتركيب متميز. كل قطعة مصممة لتستمر أكثر من الاتجاهات.', 2),
('about_values', 'v2_title', 'ar', 'الأصالة', 3),
('about_values', 'v2_desc', 'ar', 'إلهام Y2K حقيقي، وليس نسخ الموضة السريعة. نختار بعناية.', 4),
('about_values', 'v3_title', 'ar', 'رقمي أولاً', 5),
('about_values', 'v3_desc', 'ar', 'وُلدنا أونلاين، صُنعنا لجيل التمرير. من موقعنا إلى بابك.', 6),
('about_contact', 'phone', 'ar', '+213 555 55 55 55', 1),
('about_contact', 'email', 'ar', 'contact@yunstore.dz', 2),
('about_contact', 'instagram', 'ar', '@yun.store.dz', 3),
('about_contact', 'address', 'ar', 'الجزائر', 4),
('about_contact', 'hours', 'ar', 'السبت — الخميس، 10:00 صباحًا — 8:00 مساءً', 5)
on conflict (section, field, lang) do nothing;

-- Insert French translations
insert into site_content (section, field, lang, value, sort_order) values
('about_hero', 'title', 'fr', 'QUI SOMMES-NOUS', 1),
('about_hero', 'subtitle', 'fr', 'Renaissance Y2K // Ère Numérique', 2),
('about_story', 'heading', 'fr', 'Notre Histoire', 1),
('about_story', 'paragraph1', 'fr', 'Celis clothing est n\u00e9e de l''intersection de la nostalgie et de la culture num\u00e9rique. Nous s\u00e9lectionnons des mode inspir\u00e9e du Y2K qui fait le pont entre les esth\u00e9tiques r\u00e9tro et le streetwear moderne — con\u00e7ue pour la g\u00e9ration qui a grandi \u00e0 l''\u00e8re du pixel.', 2),
('about_story', 'paragraph2', 'fr', 'Chaque pièce de notre collection est un hommage aux années 2000 — les textures brillantes, les silhouettes audacieuses, l''attitude de l''âge numérique. Nous sélectionnons, concevons et livrons avec une mission : rendre la mode Y2K accessible à l''Algérie et au-delà.', 3),
('about_story', 'tagline', 'fr', 'Enfants du Numérique. Style Physique.', 4),
('about_values', 'v1_title', 'fr', 'Qualité', 1),
('about_values', 'v1_desc', 'fr', 'Matériaux et construction premium. Chaque pièce est conçue pour durer au-delà des tendances.', 2),
('about_values', 'v2_title', 'fr', 'Authenticité', 3),
('about_values', 'v2_desc', 'fr', 'Inspiration Y2K réelle, pas des copies de fast-fashion. Nous sélectionnons avec intention.', 4),
('about_values', 'v3_title', 'fr', 'Numérique d''Abord', 5),
('about_values', 'v3_desc', 'fr', 'Nés en ligne, construits pour la génération du scroll. De notre site à votre porte.', 6),
('about_contact', 'phone', 'fr', '+213 555 55 55 55', 1),
('about_contact', 'email', 'fr', 'contact@yunstore.dz', 2),
('about_contact', 'instagram', 'fr', '@yun.store.dz', 3),
('about_contact', 'address', 'fr', 'Algérie', 4),
('about_contact', 'hours', 'fr', 'Sam — Jeu, 10h00 — 20h00', 5)
on conflict (section, field, lang) do nothing;

alter table site_settings enable row level security;

alter table site_content enable row level security;

alter table categories enable row level security;

-- Note: site_settings is covered by "Admin manage site_settings" policy above

-- ############################################################
-- VIEWS (admin dashboard convenience)
-- ############################################################

-- Orders with full detail + aggregated items
create or replace view orders_full as
select
  o.order_number,
  o.id,
  o.first_name || ' ' || o.last_name as customer_name,
  o.phone,
  o.wilaya_name,
  o.commune,
  o.delivery_type,
  o.home_address,
  o.shipping_cost,
  o.subtotal,
  o.total,
  o.status,
  o.created_at,
  json_agg(json_build_object(
    'product', oi.product_name,
    'image', oi.product_image_url,
    'size', oi.size,
    'color', oi.color,
    'qty', oi.quantity,
    'price', oi.unit_price,
    'total', oi.line_total
  )) as items
from orders o
left join order_items oi on oi.order_id = o.id
group by o.id
order by o.created_at desc;

-- Products with stock summary + primary image
drop view if exists products_with_stock;
create view products_with_stock as
select
  p.id,
  p.name,
  p.category,
  p.base_price,
  p.sale_price,
  p.slug,
  p.is_active,
  count(distinct pv.id) as variant_count,
  sum(pv.stock) as total_stock,
  (select cloudinary_url from product_images
   where product_id = p.id and is_primary = true limit 1) as primary_image
from products p
left join product_variants pv on pv.product_id = p.id
group by p.id
order by p.created_at desc;

-- ############################################################
-- TABLE 10: outfits (Outfit = multiple products sold together)
-- ############################################################
create table outfits (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  name_ar text,
  slug text unique not null,
  description text,
  description_ar text,
  base_price integer not null,
  sale_price integer,
  is_active boolean default true,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- ############################################################
-- TABLE 11: outfit_images
-- ############################################################
create table outfit_images (
  id uuid default gen_random_uuid() primary key,
  outfit_id uuid references outfits(id) on delete cascade,
  cloudinary_url text not null,
  cloudinary_public_id text not null,
  is_primary boolean default false,
  sort_order integer default 0,
  created_at timestamptz default now()
);

-- ############################################################
-- TABLE 12: outfit_items (products inside an outfit)
-- ############################################################
create table outfit_items (
  id uuid default gen_random_uuid() primary key,
  outfit_id uuid references outfits(id) on delete cascade,
  product_id uuid references products(id) on delete cascade,
  variant_id uuid references product_variants(id) on delete set null,
  quantity integer not null default 1 check (quantity > 0),
  created_at timestamptz default now(),
  unique(outfit_id, product_id, variant_id)
);

-- ############################################################
-- OUTFit FUNCTIONS & TRIGGERS
-- ############################################################

create trigger outfits_updated_at
  before update on outfits
  for each row execute function update_updated_at();

-- ############################################################
-- OUTFit INDEXES
-- ############################################################

create index idx_outfits_slug on outfits(slug);
create index idx_outfits_active on outfits(is_active);
create index idx_outfit_images_outfit on outfit_images(outfit_id);
create index idx_outfit_items_outfit on outfit_items(outfit_id);
create index idx_outfit_items_product on outfit_items(product_id);

-- ############################################################
-- OUTFit ROW LEVEL SECURITY (RLS)
-- ############################################################

alter table outfits enable row level security;
alter table outfit_images enable row level security;
alter table outfit_items enable row level security;

-- Public read policies
create policy "Public read outfits"
  on outfits for select using (is_active = true);

create policy "Public read outfit_images"
  on outfit_images for select using (true);

create policy "Public read outfit_items"
  on outfit_items for select using (true);

-- Admin full-access policies
create policy "Admin manage outfits"
  on outfits for all using (true) with check (true);

create policy "Admin manage outfit_images"
  on outfit_images for all using (true) with check (true);

create policy "Admin manage outfit_items"
  on outfit_items for all using (true) with check (true);

-- ############################################################
-- OUTFit VIEWS
-- ############################################################

create or replace view outfits_with_items as
select
  o.id,
  o.name,
  o.name_ar,
  o.slug,
  o.description,
  o.description_ar,
  o.base_price,
  o.sale_price,
  o.is_active,
  o.created_at,
  (select cloudinary_url from outfit_images
   where outfit_id = o.id and is_primary = true limit 1) as primary_image,
  json_agg(json_build_object(
    'product_id', oi.product_id,
    'variant_id', oi.variant_id,
    'quantity', oi.quantity,
    'product_name', p.name,
    'product_name_ar', p.name_ar,
    'product_price', p.base_price
  )) as items
from outfits o
left join outfit_items oi on oi.outfit_id = o.id
left join products p on p.id = oi.product_id
group by o.id
order by o.created_at desc;
