-- Give the 5 original mock banks their real logo images (previously null,
-- shown as a colored initials badge instead) and add 8 more real Saudi
-- banks the user provided logos for. Saudi Central Bank (SAMA) was also
-- provided but deliberately excluded — it's the regulator, not a retail
-- bank a person would hold a checking/savings account at.

update mock_banks set logo_asset_path = 'lib/assets/logos/al_rajhi.jpg'
  where name = 'Al Rajhi Bank';
update mock_banks set logo_asset_path = 'lib/assets/logos/alinma.png'
  where name = 'Alinma Bank';
update mock_banks set logo_asset_path = 'lib/assets/logos/stc_bank.png'
  where name = 'STC Bank';
update mock_banks set logo_asset_path = 'lib/assets/logos/saudi_national_bank.jpg'
  where name = 'Saudi National Bank';
update mock_banks set logo_asset_path = 'lib/assets/logos/d360_bank.png'
  where name = 'D360 Bank';

insert into mock_banks (name, logo_asset_path, primary_color, sort_order) values
  ('BSF', 'lib/assets/logos/bsf.jpg', '#0D2B2B', 6),
  ('SAB', 'lib/assets/logos/sab.png', '#EE1C25', 7),
  ('Arab National Bank', 'lib/assets/logos/anb.webp', '#0072BC', 8),
  ('Bank Albilad', 'lib/assets/logos/bank_albilad.png', '#D71921', 9),
  ('barq', 'lib/assets/logos/barq.jpg', '#111111', 10),
  ('The Saudi Investment Bank', 'lib/assets/logos/saudi_investment_bank.jpg', '#F5A623', 11),
  ('Bank AlJazira', 'lib/assets/logos/aljazira_bank.webp', '#1A1A1A', 12),
  ('gib', 'lib/assets/logos/gib.png', '#E8871E', 13)
on conflict (name) do nothing;
