import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'catalog_entry.dart';
import 'utility_categories.dart';

const List<CatalogEntry> utilityCatalog = [
  CatalogEntry(
    name: 'STC',
    logoAsset: 'lib/assets/logos/stc.jpeg',
    category: UtilityCategories.internet,
  ),
  CatalogEntry(
    name: 'Mobily',
    logoAsset: 'lib/assets/logos/mobily.png',
    category: UtilityCategories.internet,
  ),
  CatalogEntry(
    name: 'Zain',
    logoAsset: 'lib/assets/logos/zain.png',
    category: UtilityCategories.mobile,
  ),
  CatalogEntry(
    name: 'Saudi Electricity Company',
    logoAsset: 'lib/assets/logos/1696007538-89-saudi-electricity-company.jpg',
    category: UtilityCategories.electricity,
  ),
  CatalogEntry(
    name: 'National Water Company',
    logoAsset: 'lib/assets/logos/saudi water comp.png',
    category: UtilityCategories.water,
  ),
  CatalogEntry(
    name: 'Gas Provider',
    icon: Icons.local_fire_department_outlined,
    iconColor: AppColors.utilityGas,
    category: UtilityCategories.gas,
  ),
  CatalogEntry(
    name: 'Waste & Municipality',
    icon: Icons.delete_outline_rounded,
    iconColor: AppColors.utilityOther,
    category: UtilityCategories.other,
  ),
];
