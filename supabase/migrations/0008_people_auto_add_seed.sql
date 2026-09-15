-- Exercises the new auto-detection rule (see
-- lib/data/recurring_detection.dart's autoAddOccurrences and
-- lib/data/notifications_store.dart's _refreshAutoDetection): a merchant
-- with 4+ occurrences now auto-adds straight to the right store instead of
-- waiting for a manual confirm on the Accounts screen, classified purely by
-- matching against the subscription/utility reference catalogs
-- (lib/data/subscription_catalog.dart, lib/data/utility_catalog.dart).

-- STC Bank's second recurring "subscription" merchant had no catalog
-- match (there is no "Fitness Time Gym" entry in subscription_catalog.dart),
-- so under the new catalog-based classifier it would've wrongly fallen
-- through to People. Rename it to a merchant that's actually in the
-- catalog so it correctly auto-adds as a Subscription.
update mock_transactions
set merchant_name = 'GRAMMARLY SUBSCRIPTION'
where merchant_name = 'FITNESS TIME GYM MEMBERSHIP';

-- Give Al Rajhi Bank's housekeeper payment its 4th occurrence, crossing
-- the auto-add threshold. "Housekeeper Salary - Fatima" matches neither
-- reference catalog, so this is what exercises the People auto-add path
-- end to end (added with its role left unassigned for the user to fill
-- in from the item's details page).
insert into mock_transactions (bank_id, merchant_name, amount, transaction_date, category)
select id, 'HOUSEKEEPER SALARY - FATIMA', 800, current_date - 90, 'person'
from mock_banks
where name = 'Al Rajhi Bank';

-- A second, distinct person-to-person payment on the same bank, capped at
-- 3 occurrences — stays below the auto-add threshold and remains a manual
-- "possible" suggestion on the Accounts screen, same as the other four
-- banks' person-category merchants already do.
insert into mock_transactions (bank_id, merchant_name, amount, transaction_date, category)
select id, 'TRANSFER TO GARDENER - YOUSEF', 350, current_date - offset_days, 'person'
from mock_banks, (values (20), (50), (80)) as t(offset_days)
where mock_banks.name = 'Al Rajhi Bank';
