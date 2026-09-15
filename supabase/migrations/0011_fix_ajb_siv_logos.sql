-- Same wide-wordmark cropping problem as migration 0010, for the two
-- remaining banks flagged with it: Bank AlJazira and The Saudi
-- Investment Bank. Point them at icon-only square crops instead.

update mock_banks set logo_asset_path = 'lib/assets/logos/ajb_icon.png'
  where name = 'Bank AlJazira';
update mock_banks set logo_asset_path = 'lib/assets/logos/saudi_investment_icon.png'
  where name = 'The Saudi Investment Bank';
