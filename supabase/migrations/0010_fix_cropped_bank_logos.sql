-- Al Rajhi's and STC Bank's logo images were wide wordmark lockups, and
-- BSF's had the wordmark crowding its icon — all three got cropped badly
-- by the connect-bank grid's square/circular badges (see LogoImage's
-- BoxFit.cover). Point them at icon-only (or square-padded) crops instead.

update mock_banks set logo_asset_path = 'lib/assets/logos/alrajhi.webp'
  where name = 'Al Rajhi Bank';
update mock_banks set logo_asset_path = 'lib/assets/logos/stc_bank_new.png'
  where name = 'STC Bank';
update mock_banks set logo_asset_path = 'lib/assets/logos/bsf_icon.png'
  where name = 'BSF';
