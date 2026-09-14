import 'package:flutter/material.dart';

import 'app_typography.dart';

/// Colors match the Riyal App Design (Claude Design project), converted
/// from their source OKLCH values to sRGB. Dark forest-green surfaces with
/// a warm gold accent.
class AppColors {
  AppColors._();

  // Surfaces — darkest to lightest: elevated/nav sits below the page
  // background on purpose (a grounded nav bar), cards sit above it.
  static const background = Color(0xFF031108);
  static const surface = Color(0xFF0A1B11);
  static const surfaceElevated = Color(0xFF020C05);

  // Borders/dividers — alpha baked in, matching the source design's
  // translucent oklch() values.
  static const cardBorder = Color(0x9918281E);
  static const dividerStrong = Color(0x8027382C);

  static const gold = Color(0xFFCBA960);
  static const goldDark = Color(0xFF9C7C3D);

  static const textPrimary = Color(0xFFF7F1E9);
  static const textSecondary = Color(0xFF9B998B);
  static const textTertiary = Color(0xFF747265);

  static const trackBackground = Color(0xFF23281F);

  /// Muted text/icon tone for content sitting on the light gold/cream
  /// auth coin (login/signup) — the coin is the one bright surface in an
  /// otherwise dark theme, so it needs its own dark-on-light tone rather
  /// than any of the (light-on-dark) text or category colors above.
  static const coinMuted = Color(0xFF4B4630);

  // Category accents.
  static const subscriptions = Color(0xFFCBA960);
  static const utilities = Color(0xFF2CB3B3);
  static const staff = Color(0xFFBD7D60);

  // Subscription/tracked-item status accents.
  static const statusActive = Color(0xFF6CC581);
  static const statusTrial = Color(0xFFD8B260);
  static const statusCancelled = Color(0xFFE2726B);
  static const statusPaused = Color(0xFF908F89);
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
      seedColor: AppColors.gold,
      brightness: Brightness.dark,
      surface: AppColors.surface,
    ),
    textTheme: textTheme,
  );
}
