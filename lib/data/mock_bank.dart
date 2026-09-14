import 'package:flutter/material.dart';

/// One entry in the fixed catalog of fake banks a user can "connect" to —
/// mirrors a row in the Supabase `mock_banks` table (see
/// supabase/migrations/0003_mock_banking.sql). There's no real logo asset
/// for these (they're invented brand names), so the connect UI renders a
/// colored badge from [primaryColor] instead of [logoAssetPath].
class MockBank {
  const MockBank({
    required this.id,
    required this.name,
    required this.primaryColor,
    this.logoAssetPath,
  });

  final String id;
  final String name;
  final String? logoAssetPath;
  final Color primaryColor;

  factory MockBank.fromRow(Map<String, dynamic> row) => MockBank(
    id: row['id'] as String,
    name: row['name'] as String,
    logoAssetPath: row['logo_asset_path'] as String?,
    primaryColor: _colorFromHex(row['primary_color'] as String),
  );

  static Color _colorFromHex(String hex) {
    final cleaned = hex.replaceFirst('#', '');
    return Color(int.parse('FF$cleaned', radix: 16));
  }
}
