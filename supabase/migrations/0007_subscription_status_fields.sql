-- Adds per-subscription status/purpose/reminder/notification fields for
-- the new item details page (see lib/screens/subscription_view_screen.dart)
-- — additive and backward compatible: every new column is either nullable
-- or has a default, so existing rows and the existing insert path in
-- lib/data/subscriptions_store.dart keep working unchanged until updated
-- to write these columns too.

alter table subscriptions
  add column if not exists status text not null default 'active'
    check (status in ('active', 'trial', 'cancelled', 'paused')),
  add column if not exists purpose_tag text,
  add column if not exists reminder_date date,
  add column if not exists notifications_enabled boolean not null default true;
