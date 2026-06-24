-- ############################################################
-- TABLE: admin_users (Sub-Admins with limited permissions)
-- ############################################################
create table if not exists admin_users (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  access_code text unique not null,
  permissions text[] not null default '{}',
  is_active boolean default true,
  created_at timestamptz default now()
);

alter table admin_users enable row level security;

create policy "Admin manage admin_users"
  on admin_users for all using (true) with check (true);

create index idx_admin_users_access_code on admin_users(access_code);
create index idx_admin_users_active on admin_users(is_active);
