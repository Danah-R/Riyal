-- Use the user-supplied, pre-cropped "ajb" lettermark instead of the
-- manual crop from migration 0011, and re-crop The Saudi Investment
-- Bank's icon tighter (less surrounding padding, more zoomed in).

update mock_banks set logo_asset_path = 'lib/assets/logos/ajb.png'
  where name = 'Bank AlJazira';

-- saudi_investment_icon.png itself was overwritten with a tighter crop;
-- the logo_asset_path set in migration 0011 still points at the right
-- filename, so no row update is needed here for that bank.
