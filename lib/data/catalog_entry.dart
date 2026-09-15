import 'package:flutter/material.dart';

import 'tracked_category.dart';

/// One selectable entry in a "choose from scratch" catalog (utility
/// providers, people roles, ...). Either a real [logoAsset] photo, or an
/// [icon]/[iconColor] pair to render as a colored badge instead.
class CatalogEntry {
  const CatalogEntry({
    required this.name,
    required this.category,
    this.logoAsset,
    this.icon,
    this.iconColor,
  }) : assert(
         logoAsset != null || icon != null,
         'CatalogEntry needs either a logoAsset or an icon',
       );

  final String name;
  final TrackedCategory category;
  final String? logoAsset;
  final IconData? icon;
  final Color? iconColor;
}
