-- ############################################################
-- SETUP_RLS_PROTECTED.sql
-- Run this in: Supabase Dashboard -> SQL Editor
--
-- WHAT THIS DOES
-- 1) Turns ON Row Level Security on every app table.
-- 2) Removes ALL old (open) policies.
-- 3) The PUBLIC (anon key) can only:
--      - READ the store catalog (products, outfits, categories, settings...)
--      - PLACE orders (orders / order_items) and register page views
--      - USE a promo code (increment used_count only)
--    The public can NO LONGER edit/delete products, settings, orders, etc.
-- 4) The DASHBOARD keeps FULL control through netlify/functions/admin-db.js
--    which runs with the service_role (secret) key and bypasses RLS.
--
-- NOTE: you must also deploy the new admin-db function + client changes
-- together with this file (see deployment steps in chat).
-- ############################################################

-- ============================================================
-- STEP 1: Drop every existing policy on the app tables
-- ============================================================
DO $$
DECLARE t text; r record;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'products','product_images','product_variants','categories',
    'outfits','outfit_images','outfit_products','outfit_variants','outfit_items',
    'homepage_content','site_settings','site_content','wilaya_pricing','promo_codes',
    'orders','order_items','stock_movements','page_views','push_subscriptions','admin_users'
  ] LOOP
    FOR r IN SELECT policyname FROM pg_policies WHERE schemaname = 'public' AND tablename = t LOOP
      EXECUTE format('DROP POLICY IF EXISTS %I ON public.%I', r.policyname, t);
    END LOOP;
  END LOOP;
END $$;

-- ============================================================
-- STEP 2: Enable RLS on every app table
-- ============================================================
alter table if exists public.products               enable row level security;
alter table if exists public.product_images         enable row level security;
alter table if exists public.product_variants       enable row level security;
alter table if exists public.categories             enable row level security;
alter table if exists public.outfits                enable row level security;
alter table if exists public.outfit_images          enable row level security;
alter table if exists public.outfit_products        enable row level security;
alter table if exists public.outfit_variants        enable row level security;
alter table if exists public.outfit_items           enable row level security;
alter table if exists public.homepage_content       enable row level security;
alter table if exists public.site_settings          enable row level security;
alter table if exists public.site_content           enable row level security;
alter table if exists public.wilaya_pricing         enable row level security;
alter table if exists public.promo_codes            enable row level security;
alter table if exists public.orders                 enable row level security;
alter table if exists public.order_items            enable row level security;
alter table if exists public.stock_movements        enable row level security;
alter table if exists public.page_views             enable row level security;
alter table if exists public.push_subscriptions     enable row level security;
alter table if exists public.admin_users            enable row level security;

-- ============================================================
-- STEP 3: Make sure the dashboard (service_role / secret key)
--         always has full privileges on everything.
-- ============================================================
grant select, insert, update, delete on all tables in schema public to service_role;
grant usage, select on all sequences in schema public to service_role;
grant execute on all functions in schema public to service_role;
alter default privileges in schema public
  grant select, insert, update, delete on tables to service_role;
alter default privileges in schema public
  grant usage, select on sequences to service_role;
alter default privileges in schema public
  grant execute on functions to service_role;

-- ============================================================
-- STEP 4: PUBLIC READ policies (store catalog)
-- ============================================================
create policy "public_read_products" on public.products
  for select to anon
  using (is_active = true);

create policy "public_read_images" on public.product_images
  for select to anon using (true);

create policy "public_read_variants" on public.product_variants
  for select to anon using (is_active = true);

create policy "public_read_categories" on public.categories
  for select to anon using (true);

create policy "public_read_outfits" on public.outfits
  for select to anon using (is_active = true);

create policy "public_read_outfit_images" on public.outfit_images
  for select to anon using (true);

create policy "public_read_outfit_products" on public.outfit_products
  for select to anon using (true);

create policy "public_read_outfit_variants" on public.outfit_variants
  for select to anon using (true);

create policy "public_read_outfit_items" on public.outfit_items
  for select to anon using (true);

create policy "public_read_site_content" on public.site_content
  for select to anon using (true);

create policy "public_read_homepage" on public.homepage_content
  for select to anon using (true);

-- Settings are public EXCEPT the sensitive keys below.
create policy "public_read_settings" on public.site_settings
  for select to anon
  using (key <> all (array['admin_username','admin_password','zr_api_key','zr_tenant_id']));

create policy "public_read_pricing" on public.wilaya_pricing
  for select to anon using (true);

create policy "public_read_promos" on public.promo_codes
  for select to anon using (is_active = true);

-- ============================================================
-- STEP 5: PUBLIC PLACE-ORDER policies (checkout without login)
-- ============================================================
create policy "public_insert_orders" on public.orders
  for insert to anon
  with check (status is null or status = 'pending');

create policy "public_insert_order_items" on public.order_items
  for insert to anon with check (true);

-- ============================================================
-- STEP 6: Public analytics inserts (page_views)
-- ============================================================
create table if not exists public.page_views (
  id uuid default gen_random_uuid() primary key,
  page text not null,
  path text,
  referrer text,
  user_agent text,
  screen_width integer,
  country text,
  created_at timestamptz default now()
);

create index if not exists idx_page_views_created_at on public.page_views(created_at desc);
create index if not exists idx_page_views_page on public.page_views(page);

grant insert, select on public.page_views to anon, authenticated;

create policy "public_insert_page_views" on public.page_views
  for insert to anon with check (true);

-- The public cannot read page_views (admin reads them via the secret key).
create policy "deny_public_read_page_views" on public.page_views
  for select to anon using (false);

-- ============================================================
-- STEP 7: Promo codes - public may only bump used_count
-- ============================================================
create policy "public_use_promo" on public.promo_codes
  for update to anon
  using (is_active = true) with check (is_active = true);

revoke update on public.promo_codes from anon;
grant update (used_count) on public.promo_codes to anon;

-- ============================================================
-- STEP 8: Order cooldown check (security definer -> hides orders)
-- ============================================================
create or replace function public.check_recent_order(p_phone text, p_since timestamptz)
returns timestamptz
language plpgsql
security definer
set search_path = public
as $$
declare v_last timestamptz;
begin
  select max(created_at) into v_last
    from public.orders
    where phone = p_phone and created_at >= p_since;
  return v_last;
end;
$$;

revoke all on function public.check_recent_order(text, timestamptz) from public;
grant execute on function public.check_recent_order(text, timestamptz) to anon;

-- ============================================================
-- STEP 9: Lock the views - public cannot read them anymore.
--         (orders_full / products_with_stock contain private data)
--         The dashboard still reads them through the secret key.
-- ============================================================
DO $$
DECLARE v record;
BEGIN
  FOR v IN SELECT table_name FROM information_schema.views
           WHERE table_schema = 'public' LOOP
    EXECUTE format('REVOKE ALL ON public.%I FROM anon, authenticated', v.table_name);
  END LOOP;
END $$;

-- ============================================================
-- DONE. No policies were created for anon on:
--   orders (SELECT), order_items (SELECT), stock_movements,
--   push_subscriptions, admin_users
-- -> the public is completely blocked from those.
-- ============================================================
