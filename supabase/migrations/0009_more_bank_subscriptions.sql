-- Each connected bank's mock feed only had 1-2 merchants shaped like a
-- real subscription (the rest is a utility, a person payment, and one-off
-- noise), so auto-detected subscriptions felt sparse. Adds two more
-- catalog-matched subscription merchants (4 occurrences each, 30 days
-- apart) per bank — names not already used anywhere in mock_transactions
-- or in SubscriptionsStore's local demo seed, so these are genuinely new
-- auto-adds sourced from the bank feed rather than the app's own bundled
-- demo subscriptions.

insert into mock_transactions (bank_id, merchant_name, amount, transaction_date, category)
select id, merchant_name, amount, current_date - offset_days, 'subscription'
from mock_banks, (values
  ('DISNEY PLUS', 35, 0),
  ('DISNEY PLUS', 35, 30),
  ('DISNEY PLUS', 35, 60),
  ('DISNEY PLUS', 35, 90),
  ('YOUTUBE PREMIUM', 45, 0),
  ('YOUTUBE PREMIUM', 45, 30),
  ('YOUTUBE PREMIUM', 45, 60),
  ('YOUTUBE PREMIUM', 45, 90)
) as t(merchant_name, amount, offset_days)
where mock_banks.name = 'Al Rajhi Bank';

insert into mock_transactions (bank_id, merchant_name, amount, transaction_date, category)
select id, merchant_name, amount, current_date - offset_days, 'subscription'
from mock_banks, (values
  ('APPLE MUSIC', 22, 0),
  ('APPLE MUSIC', 22, 30),
  ('APPLE MUSIC', 22, 60),
  ('APPLE MUSIC', 22, 90),
  ('DROPBOX', 45, 0),
  ('DROPBOX', 45, 30),
  ('DROPBOX', 45, 60),
  ('DROPBOX', 45, 90)
) as t(merchant_name, amount, offset_days)
where mock_banks.name = 'Alinma Bank';

insert into mock_transactions (bank_id, merchant_name, amount, transaction_date, category)
select id, merchant_name, amount, current_date - offset_days, 'subscription'
from mock_banks, (values
  ('XBOX GAME PASS', 55, 0),
  ('XBOX GAME PASS', 55, 30),
  ('XBOX GAME PASS', 55, 60),
  ('XBOX GAME PASS', 55, 90),
  ('CANVA', 40, 0),
  ('CANVA', 40, 30),
  ('CANVA', 40, 60),
  ('CANVA', 40, 90)
) as t(merchant_name, amount, offset_days)
where mock_banks.name = 'STC Bank';

insert into mock_transactions (bank_id, merchant_name, amount, transaction_date, category)
select id, merchant_name, amount, current_date - offset_days, 'subscription'
from mock_banks, (values
  ('AMAZON PRIME VIDEO', 20, 0),
  ('AMAZON PRIME VIDEO', 20, 30),
  ('AMAZON PRIME VIDEO', 20, 60),
  ('AMAZON PRIME VIDEO', 20, 90),
  ('FIGMA', 60, 0),
  ('FIGMA', 60, 30),
  ('FIGMA', 60, 60),
  ('FIGMA', 60, 90)
) as t(merchant_name, amount, offset_days)
where mock_banks.name = 'Saudi National Bank';

insert into mock_transactions (bank_id, merchant_name, amount, transaction_date, category)
select id, merchant_name, amount, current_date - offset_days, 'subscription'
from mock_banks, (values
  ('SLACK', 35, 0),
  ('SLACK', 35, 30),
  ('SLACK', 35, 60),
  ('SLACK', 35, 90),
  ('NORDVPN', 25, 0),
  ('NORDVPN', 25, 30),
  ('NORDVPN', 25, 60),
  ('NORDVPN', 25, 90)
) as t(merchant_name, amount, offset_days)
where mock_banks.name = 'D360 Bank';
