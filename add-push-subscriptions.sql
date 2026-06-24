-- Push subscriptions table for admin notifications
create table if not exists push_subscriptions (
  id uuid default gen_random_uuid() primary key,
  endpoint text not null unique,
  p256dh text not null,
  auth text not null,
  user_agent text,
  created_at timestamp with time zone default now()
);

-- RLS: allow all (same pattern as other tables)
alter table push_subscriptions enable row level security;
create policy "allow all" on push_subscriptions for all using (true);

-- Index for faster lookups
create index if not exists idx_push_sub_endpoint on push_subscriptions(endpoint);
