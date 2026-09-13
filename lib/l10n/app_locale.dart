import 'package:flutter/material.dart';

import '../data/app_settings.dart';

/// Holds the app's current [Locale] so [MainApp] can rebuild the whole
/// tree with the new language the instant it changes in Settings — no
/// restart needed. Read by [Strings.t] to pick which text table to use.
class AppLocale {
  AppLocale._();

  static final ValueNotifier<Locale> locale = ValueNotifier(
    Locale(AppSettings.instance.languageCode),
  );

  static Future<void> set(Locale value) async {
    await AppSettings.instance.saveLanguage(value.languageCode);
    locale.value = value;
  }
}
