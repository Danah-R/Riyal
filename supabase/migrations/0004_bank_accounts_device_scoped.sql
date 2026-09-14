-- Temporarily remove the real Supabase Auth requirement on
-- user_bank_accounts — email confirmation was blocking testing. Falls
-- back to the same device_id scheme `subscriptions` already uses (see
-- lib/data/device_id_store.dart). Re-tighten to auth.uid() later if real
-- per-user accounts come back.

alter table user_bank_accounts alter column user_id drop not null;
alter table user_bank_accounts add column if not exists device_id text;

alter table user_bank_accounts drop constraint if exists user_bank_accounts_user_id_bank_id_key;
alter table user_bank_accounts add constraint user_bank_accounts_device_id_bank_id_key
  unique (device_id, bank_id);

drop policy if exists "users manage their own bank accounts" on user_bank_accounts;
create policy "anon full access" on user_bank_accounts for all using (true) with check (true);

create index if not exists user_bank_accounts_device_id_idx on user_bank_accounts (device_id);
