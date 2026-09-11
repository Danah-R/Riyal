import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const background = Color(0xFF0B0F0C);
  static const surface = Color(0xFF141914);
  static const cardBorder = Color(0xFF3A4A3A);
  static const gold = Color(0xFFD4AF6A);
  static const goldDark = Color(0xFF9C7C3D);
  static const textPrimary = Color(0xFFF5F3EC);
  static const textSecondary = Color(0xFFAAB2A6);
  static const trackBackground = Color(0xFF23281F);

  static const subscriptions = Color(0xFF6FBF9A);
  static const utilities = Color(0xFF8FA85E);
  static const staff = Color(0xFF4B4630);
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    brightness: Brightness.dark,
    fontFamily: 'Roboto',
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.gold,
      brightness: Brightness.dark,
      surface: AppColors.surface,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: AppColors.textPrimary),
    ),
  );
}
