-- subscriptions.device_id incorrectly required a lean_customers row to
-- exist first (via a foreign key) — but subscriptions are seeded on every
-- app launch and can be added manually, independent of ever connecting a
-- bank account. A fresh device with no Lean customer yet couldn't insert
-- its seed data. Drop the FK; device_id stays as a plain filter key.

alter table subscriptions drop constraint if exists subscriptions_device_id_fkey;
