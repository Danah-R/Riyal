import 'package:flutter/material.dart';

import 'app_typography.dart';

class AppColors {
  AppColors._();

  static const background = Color(0xFF0B0F0C);
  static const surface = Color(0xFF141914);
  static const cardBorder = Color(0xFF3A4A3A);
  static const gold = Color.fromARGB(255, 183, 158, 60);
  static const goldDark = Color(0xFF9C7C3D);
  static const textPrimary = Color(0xFFF5F3EC);
  static const textSecondary = Color(0xFFAAB2A6);
  static const trackBackground = Color(0xFF23281F);

  static const subscriptions = Color(0xFF6FBF9A);
  static const utilities = Color(0xFF8FA85E);
  static const staff = Color(0xFF4B4630);
}

/// Builds the app theme for the given language — body/UI text renders in
/// Inter for English or IBM Plex Sans Arabic for Arabic (see
/// [AppTypography]), so this should be rebuilt whenever the app's locale
/// changes rather than built once at startup.
ThemeData buildAppTheme({String languageCode = 'en'}) {
  const baseTextTheme = TextTheme(
    bodyMedium: TextStyle(color: AppColors.textPrimary),
  );
  final textTheme = AppTypography.textTheme(languageCode, baseTextTheme)
      .apply(bodyColor: AppColors.textPrimary, displayColor: AppColors.textPrimary);

  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    brightness: Brightness.dark,
    fontFamily: textTheme.bodyMedium?.fontFamily,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 215, 184, 61),
      brightness: Brightness.dark,
      surface: AppColors.surface,
    ),
    textTheme: textTheme,
  );
}
