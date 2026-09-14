-- Riyal: bank accounts (Lean), transactions, and subscriptions.
--
-- This app has no real sign-in yet (the login screen is an explicit demo
-- with no backend authentication), so there's no Supabase Auth user to
-- scope rows to. Instead every table is keyed by `device_id` — a random
-- identifier the app generates once and keeps locally (see
-- lib/data/lean_customer_store.dart). RLS policies below allow the anon
-- key to read/write only... well, honestly, anon key + no auth means RLS
-- can't truly distinguish devices at the database level (there's no
-- verified claim to check against). We still enable RLS and add
-- permissive policies (rather than leaving it open with RLS disabled) so
-- the door is easy to close later: swap these for `auth.uid() = user_id`
-- policies once real Supabase Auth is added, without changing the schema.

create extension if not exists "pgcrypto";

create table if not exists lean_customers (
  device_id text primary key,
  customer_id text not null unique,
  created_at timestamptz not null default now()
);

create table if not exists bank_accounts (
  id uuid primary key default gen_random_uuid(),
  device_id text not null references lean_customers (device_id) on delete cascade,
  entity_id text not null,
  account_id text,
  bank_name text not null,
  masked_account_number text not null,
  status text not null default 'connected' check (status in ('connected', 'syncing', 'error')),
  error_message text,
  last_synced_at timestamptz,
  created_at timestamptz not null default now(),
  unique (device_id, entity_id)
);

create table if not exists bank_transactions (
  id uuid primary key default gen_random_uuid(),
  device_id text not null references lean_customers (device_id) on delete cascade,
  entity_id text not null,
  lean_transaction_id text not null,
  description text not null,
  amount numeric not null,
  occurred_at timestamptz not null,
  created_at timestamptz not null default now(),
  unique (device_id, lean_transaction_id)
);

create table if not exists subscriptions (
  id uuid primary key default gen_random_uuid(),
  -- No FK to lean_customers: subscriptions are seeded for every device on
  -- first launch and can be added manually from the catalog, regardless of
  -- whether that device has ever connected a bank account.
  device_id text not null,
  name text not null,
  logo_asset text,
  amount numeric not null,
  cycle text not null check (cycle in ('monthly', 'yearly')),
  next_billing_date date not null,
  category_key text not null default 'other',
  source text not null default 'manual' check (source in ('manual', 'catalog', 'bank_detected')),
  created_at timestamptz not null default now()
);

alter table lean_customers enable row level security;
alter table bank_accounts enable row level security;
alter table bank_transactions enable row level security;
alter table subscriptions enable row level security;

-- Permissive anon-key policies (see note above) — every device can read
-- and write every row. Fine for a single-user demo app; not a real
-- multi-tenant security boundary.
create policy "anon full access" on lean_customers for all using (true) with check (true);
create policy "anon full access" on bank_accounts for all using (true) with check (true);
create policy "anon full access" on bank_transactions for all using (true) with check (true);
create policy "anon full access" on subscriptions for all using (true) with check (true);

create index if not exists bank_accounts_device_id_idx on bank_accounts (device_id);
create index if not exists bank_transactions_device_entity_idx on bank_transactions (device_id, entity_id);
create index if not exists subscriptions_device_id_idx on subscriptions (device_id);
