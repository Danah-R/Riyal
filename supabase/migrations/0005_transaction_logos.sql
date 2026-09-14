-- Store each transaction's logo asset path directly in Supabase instead of
-- re-deriving it client-side by fuzzy-matching merchant_name against the
-- Dart-side catalogs (subscription_catalog.dart / utility_catalog.dart) —
-- keeps the logo as ground truth data rather than a runtime guess.
--
-- Only merchants with a real image asset already bundled in
-- lib/assets/logos/ get one; everything else (one-off retail/restaurant/
-- ride-hailing purchases, and person-to-person payments, which use a
-- Material icon badge instead of a photo) is left null and falls back to
-- the existing client-side catalog match, same as before.

alter table mock_transactions add column if not exists logo_asset text;

update mock_transactions set logo_asset = 'lib/assets/logos/Netflix_icon.svg'
  where merchant_name = 'NETFLIX.COM';

update mock_transactions set logo_asset = 'lib/assets/logos/Spotify_App_Logo.svg.webp'
  where merchant_name = 'SPOTIFY AB';

update mock_transactions set logo_asset = 'lib/assets/logos/shahid.png'
  where merchant_name = 'SHAHID VIP SUBSCRIPTION';

update mock_transactions set logo_asset = 'lib/assets/logos/anghami.png'
  where merchant_name = 'ANGHAMI MUSIC';

update mock_transactions set logo_asset = 'lib/assets/logos/notion.webp'
  where merchant_name = 'NOTION.SO SUBSCRIPTION';

update mock_transactions set logo_asset = 'lib/assets/logos/1696007538-89-saudi-electricity-company.jpg'
  where merchant_name = 'SAUDI ELECTRICITY COMPANY - SEC BILL';

update mock_transactions set logo_asset = 'lib/assets/logos/stc.jpeg'
  where merchant_name = 'STC INTERNET BILL';

update mock_transactions set logo_asset = 'lib/assets/logos/saudi water comp.png'
  where merchant_name = 'NATIONAL WATER COMPANY BILL';

update mock_transactions set logo_asset = 'lib/assets/logos/zain.png'
  where merchant_name = 'ZAIN MOBILE BILL';

update mock_transactions set logo_asset = 'lib/assets/logos/noon-com-logo-png_seeklogo-467329.png'
  where merchant_name = 'NOON.COM';
