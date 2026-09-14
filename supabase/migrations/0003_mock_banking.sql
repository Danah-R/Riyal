-- Riyal: replace the Lean Technologies integration with a fully mocked bank
-- connection system, now that the app has real Supabase Auth sign-in.
--
-- Drops the Lean-era tables outright (no data worth preserving — Lean was
-- never used past sandbox testing) and introduces three new ones:
-- mock_banks (a small fixed catalog), user_bank_accounts (which user
-- "connected" to which mock bank), and mock_transactions (a canned
-- transaction history per bank, seeded once below). Unlike the old
-- device_id scheme, user_bank_accounts is scoped by real `auth.uid()` —
-- this app now requires a Supabase Auth account to reach Home at all.

drop policy if exists "anon full access" on bank_transactions;
drop policy if exists "anon full access" on bank_accounts;
drop policy if exists "anon full access" on lean_customers;
drop table if exists bank_transactions;
drop table if exists bank_accounts;
drop table if exists lean_customers;

create table if not exists mock_banks (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  logo_asset_path text,
  primary_color text not null,
  sort_order int not null default 0
);

create table if not exists user_bank_accounts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  bank_id uuid not null references mock_banks (id) on delete cascade,
  account_label text not null,
  masked_account_number text not null,
  connected_at timestamptz not null default now(),
  unique (user_id, bank_id)
);

create table if not exists mock_transactions (
  id uuid primary key default gen_random_uuid(),
  bank_id uuid not null references mock_banks (id) on delete cascade,
  merchant_name text not null,
  amount numeric not null,
  transaction_date date not null,
  category text not null check (category in ('subscription', 'utility', 'person', 'other'))
);

alter table mock_banks enable row level security;
alter table user_bank_accounts enable row level security;
alter table mock_transactions enable row level security;

-- The bank catalog and its canned transactions aren't secret or
-- per-user — every signed-in device can read them.
create policy "anyone can read mock banks" on mock_banks for select using (true);
create policy "anyone can read mock transactions" on mock_transactions for select using (true);

-- user_bank_accounts is real per-user data now that there's real auth.
create policy "users manage their own bank accounts" on user_bank_accounts
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create index if not exists user_bank_accounts_user_idx on user_bank_accounts (user_id);
create index if not exists mock_transactions_bank_idx on mock_transactions (bank_id);

-- ---------------------------------------------------------------------
-- Seed: 5 mock banks
-- ---------------------------------------------------------------------

insert into mock_banks (name, primary_color, sort_order) values
  ('Al Rajhi Bank', '#1A6E3C', 1),
  ('Alinma Bank', '#8A1538', 2),
  ('STC Bank', '#4B2E83', 3),
  ('Saudi National Bank', '#003057', 4),
  ('D360 Bank', '#111318', 5)
on conflict (name) do nothing;

-- ---------------------------------------------------------------------
-- Seed: ~16 transactions per bank — a mix of recurring subscriptions,
-- recurring utility bills (amount drifts slightly month to month, like a
-- real bill), recurring person-to-person payments, and one-off purchases
-- that should NOT be flagged as recurring by the detection engine.
-- Recurring items are spaced 30 days apart so they land inside the
-- engine's 25-35 day "monthly" window; amounts stay within its 5%
-- tolerance of the group average.
-- ---------------------------------------------------------------------

-- Al Rajhi Bank: Netflix + electricity + housekeeper, plus one-offs.
insert into mock_transactions (bank_id, merchant_name, amount, transaction_date, category)
select id, merchant_name, amount, current_date - offset_days, category
from mock_banks, (values
  ('NETFLIX.COM', 45, 0, 'subscription'),
  ('NETFLIX.COM', 45, 30, 'subscription'),
  ('NETFLIX.COM', 45, 60, 'subscription'),
  ('NETFLIX.COM', 45, 90, 'subscription'),
  ('SAUDI ELECTRICITY COMPANY - SEC BILL', 150, 0, 'utility'),
  ('SAUDI ELECTRICITY COMPANY - SEC BILL', 145, 30, 'utility'),
  ('SAUDI ELECTRICITY COMPANY - SEC BILL', 152, 60, 'utility'),
  ('SAUDI ELECTRICITY COMPANY - SEC BILL', 148, 90, 'utility'),
  ('HOUSEKEEPER SALARY - FATIMA', 800, 0, 'person'),
  ('HOUSEKEEPER SALARY - FATIMA', 800, 30, 'person'),
  ('HOUSEKEEPER SALARY - FATIMA', 800, 60, 'person'),
  ('JARIR BOOKSTORE', 210, 12, 'other'),
  ('CAREEM RIDE', 32, 4, 'other'),
  ('DANUBE HYPERMARKET', 186, 8, 'other'),
  ('ALBAIK RESTAURANT', 45, 2, 'other'),
  ('UBER TRIP', 28, 18, 'other')
) as t(merchant_name, amount, offset_days, category)
where mock_banks.name = 'Al Rajhi Bank';

-- Alinma Bank: Spotify + STC internet + driver, plus one-offs.
insert into mock_transactions (bank_id, merchant_name, amount, transaction_date, category)
select id, merchant_name, amount, current_date - offset_days, category
from mock_banks, (values
  ('SPOTIFY AB', 25, 0, 'subscription'),
  ('SPOTIFY AB', 25, 30, 'subscription'),
  ('SPOTIFY AB', 25, 60, 'subscription'),
  ('SPOTIFY AB', 25, 90, 'subscription'),
  ('STC INTERNET BILL', 250, 0, 'utility'),
  ('STC INTERNET BILL', 245, 30, 'utility'),
  ('STC INTERNET BILL', 255, 60, 'utility'),
  ('STC INTERNET BILL', 248, 90, 'utility'),
  ('TRANSFER TO DRIVER - AHMED', 1500, 0, 'person'),
  ('TRANSFER TO DRIVER - AHMED', 1500, 30, 'person'),
  ('TRANSFER TO DRIVER - AHMED', 1500, 60, 'person'),
  ('EXTRA ELECTRONICS', 899, 20, 'other'),
  ('CAREEM RIDE', 40, 6, 'other'),
  ('PANDA HYPERMARKET', 210, 9, 'other'),
  ('KUDU RESTAURANT', 38, 3, 'other'),
  ('JARIR BOOKSTORE', 65, 14, 'other')
) as t(merchant_name, amount, offset_days, category)
where mock_banks.name = 'Alinma Bank';

-- STC Bank: Shahid VIP + a gym membership + a tutor, plus one-offs.
insert into mock_transactions (bank_id, merchant_name, amount, transaction_date, category)
select id, merchant_name, amount, current_date - offset_days, category
from mock_banks, (values
  ('SHAHID VIP SUBSCRIPTION', 30, 0, 'subscription'),
  ('SHAHID VIP SUBSCRIPTION', 30, 30, 'subscription'),
  ('SHAHID VIP SUBSCRIPTION', 30, 60, 'subscription'),
  ('SHAHID VIP SUBSCRIPTION', 30, 90, 'subscription'),
  ('FITNESS TIME GYM MEMBERSHIP', 199, 0, 'subscription'),
  ('FITNESS TIME GYM MEMBERSHIP', 199, 30, 'subscription'),
  ('FITNESS TIME GYM MEMBERSHIP', 199, 60, 'subscription'),
  ('FITNESS TIME GYM MEMBERSHIP', 199, 90, 'subscription'),
  ('TUTOR PAYMENT - MR AHMAD', 300, 0, 'person'),
  ('TUTOR PAYMENT - MR AHMAD', 300, 30, 'person'),
  ('TUTOR PAYMENT - MR AHMAD', 300, 60, 'person'),
  ('STARBUCKS COFFEE', 24, 1, 'other'),
  ('UBER TRIP', 22, 5, 'other'),
  ('PANDA HYPERMARKET', 175, 11, 'other'),
  ('JARIR BOOKSTORE', 340, 16, 'other'),
  ('ALBAIK RESTAURANT', 52, 7, 'other')
) as t(merchant_name, amount, offset_days, category)
where mock_banks.name = 'STC Bank';

-- Saudi National Bank: Anghami + water bill + nanny, plus one-offs.
insert into mock_transactions (bank_id, merchant_name, amount, transaction_date, category)
select id, merchant_name, amount, current_date - offset_days, category
from mock_banks, (values
  ('ANGHAMI MUSIC', 20, 0, 'subscription'),
  ('ANGHAMI MUSIC', 20, 30, 'subscription'),
  ('ANGHAMI MUSIC', 20, 60, 'subscription'),
  ('ANGHAMI MUSIC', 20, 90, 'subscription'),
  ('NATIONAL WATER COMPANY BILL', 70, 0, 'utility'),
  ('NATIONAL WATER COMPANY BILL', 68, 30, 'utility'),
  ('NATIONAL WATER COMPANY BILL', 72, 60, 'utility'),
  ('NATIONAL WATER COMPANY BILL', 69, 90, 'utility'),
  ('NANNY SALARY - MARIA', 1200, 0, 'person'),
  ('NANNY SALARY - MARIA', 1200, 30, 'person'),
  ('NANNY SALARY - MARIA', 1200, 60, 'person'),
  ('IKEA', 560, 22, 'other'),
  ('CAREEM RIDE', 35, 2, 'other'),
  ('CARREFOUR HYPERMARKET', 240, 10, 'other'),
  ('SHAWARMA HOUSE', 30, 4, 'other'),
  ('NOON.COM', 150, 13, 'other')
) as t(merchant_name, amount, offset_days, category)
where mock_banks.name = 'Saudi National Bank';

-- D360 Bank: Notion + Zain mobile + a second driver, plus one-offs.
insert into mock_transactions (bank_id, merchant_name, amount, transaction_date, category)
select id, merchant_name, amount, current_date - offset_days, category
from mock_banks, (values
  ('NOTION.SO SUBSCRIPTION', 15, 0, 'subscription'),
  ('NOTION.SO SUBSCRIPTION', 15, 30, 'subscription'),
  ('NOTION.SO SUBSCRIPTION', 15, 60, 'subscription'),
  ('NOTION.SO SUBSCRIPTION', 15, 90, 'subscription'),
  ('ZAIN MOBILE BILL', 150, 0, 'utility'),
  ('ZAIN MOBILE BILL', 148, 30, 'utility'),
  ('ZAIN MOBILE BILL', 153, 60, 'utility'),
  ('ZAIN MOBILE BILL', 151, 90, 'utility'),
  ('TRANSFER TO DRIVER - KHALID', 1600, 0, 'person'),
  ('TRANSFER TO DRIVER - KHALID', 1600, 30, 'person'),
  ('TRANSFER TO DRIVER - KHALID', 1600, 60, 'person'),
  ('JARIR BOOKSTORE', 120, 15, 'other'),
  ('UBER TRIP', 45, 6, 'other'),
  ('CARREFOUR HYPERMARKET', 265, 9, 'other'),
  ('KUDU RESTAURANT', 42, 3, 'other'),
  ('KEETA DELIVERY', 55, 1, 'other')
) as t(merchant_name, amount, offset_days, category)
where mock_banks.name = 'D360 Bank';
