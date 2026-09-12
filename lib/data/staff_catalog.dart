import 'package:flutter/material.dart';

import 'catalog_entry.dart';
import 'staff_categories.dart';

const List<CatalogEntry> staffCatalog = [
  CatalogEntry(
    name: 'Driver',
    icon: Icons.directions_car_outlined,
    iconColor: Color(0xFF37474F),
    category: StaffCategories.driving,
  ),
  CatalogEntry(
    name: 'Housekeeper',
    icon: Icons.cleaning_services_outlined,
    iconColor: Color(0xFF6B7A3A),
    category: StaffCategories.household,
  ),
  CatalogEntry(
    name: 'Nanny',
    icon: Icons.child_care_outlined,
    iconColor: Color(0xFFC2637A),
    category: StaffCategories.childcare,
  ),
  CatalogEntry(
    name: 'Cook',
    icon: Icons.restaurant_outlined,
    iconColor: Color(0xFF6B7A3A),
    category: StaffCategories.household,
  ),
  CatalogEntry(
    name: 'Gardener',
    icon: Icons.grass_outlined,
    iconColor: Color(0xFF4C7A3A),
    category: StaffCategories.household,
  ),
  CatalogEntry(
    name: 'Security Guard',
    icon: Icons.shield_outlined,
    iconColor: Color(0xFF7A3A3A),
    category: StaffCategories.security,
  ),
  CatalogEntry(
    name: 'Tutor',
    icon: Icons.school_outlined,
    iconColor: Color(0xFF3A5A7A),
    category: StaffCategories.other,
  ),
  CatalogEntry(
    name: 'Personal Assistant',
    icon: Icons.badge_outlined,
    iconColor: Color(0xFF6A5A8A),
    category: StaffCategories.other,
  ),
];
