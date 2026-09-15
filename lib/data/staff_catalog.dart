import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'catalog_entry.dart';
import 'staff_categories.dart';

const List<CatalogEntry> staffCatalog = [
  CatalogEntry(
    name: 'Driver',
    icon: Icons.directions_car_outlined,
    iconColor: AppColors.staffDriving,
    category: StaffCategories.driving,
  ),
  CatalogEntry(
    name: 'Housekeeper',
    icon: Icons.cleaning_services_outlined,
    iconColor: AppColors.staffHousekeeping,
    category: StaffCategories.household,
  ),
  CatalogEntry(
    name: 'Nanny',
    icon: Icons.child_care_outlined,
    iconColor: AppColors.staffChildcare,
    category: StaffCategories.childcare,
  ),
  CatalogEntry(
    name: 'Cook',
    icon: Icons.restaurant_outlined,
    iconColor: AppColors.staffHousekeeping,
    category: StaffCategories.household,
  ),
  CatalogEntry(
    name: 'Gardener',
    icon: Icons.grass_outlined,
    iconColor: AppColors.staffGardening,
    category: StaffCategories.household,
  ),
  CatalogEntry(
    name: 'Security Guard',
    icon: Icons.shield_outlined,
    iconColor: AppColors.staffSecurity,
    category: StaffCategories.security,
  ),
  CatalogEntry(
    name: 'Tutor',
    icon: Icons.school_outlined,
    iconColor: AppColors.staffTutoring,
    category: StaffCategories.other,
  ),
  CatalogEntry(
    name: 'Personal Assistant',
    icon: Icons.badge_outlined,
    iconColor: AppColors.staffAssistant,
    category: StaffCategories.other,
  ),
];
