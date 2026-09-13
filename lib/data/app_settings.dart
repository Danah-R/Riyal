import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  static final instance = AppSettings();
  SharedPreferencesAsync get _prefs => SharedPreferencesAsync();
  bool paymentReminders = true;
  int reminderDays = 5;
  bool monthlyReviewReminders = true;
  int monthlyReviewDay = 1;
  String languageCode = 'en';

  Future<void> load() async {
    final raw = await _prefs.getString('riyal.settings.v1');
    if (raw == null) return;
    final data = jsonDecode(raw) as Map<String, dynamic>;
    paymentReminders = data['paymentReminders'] as bool? ?? true;
    final days = data['reminderDays'];
    reminderDays = [1, 3, 5, 7].contains(days) ? days as int : 5;
    monthlyReviewReminders = data['monthlyReviewReminders'] as bool? ?? true;
    final reviewDay = data['monthlyReviewDay'];
    monthlyReviewDay = [1, 15, 28].contains(reviewDay) ? reviewDay as int : 1;
    final language = data['languageCode'];
    languageCode = ['en', 'ar'].contains(language) ? language as String : 'en';
  }

  Future<void> save({required bool enabled, required int days}) async {
    if (![1, 3, 5, 7].contains(days)) throw ArgumentError.value(days);
    await _prefs.setString(
      'riyal.settings.v1',
      jsonEncode({
        'paymentReminders': enabled,
        'reminderDays': days,
        'monthlyReviewReminders': monthlyReviewReminders,
        'monthlyReviewDay': monthlyReviewDay,
        'languageCode': languageCode,
      }),
    );
    paymentReminders = enabled;
    reminderDays = days;
  }

  Future<void> saveMonthlyReview({
    required bool enabled,
    required int day,
  }) async {
    if (![1, 15, 28].contains(day)) throw ArgumentError.value(day);
    await _prefs.setString(
      'riyal.settings.v1',
      jsonEncode({
        'paymentReminders': paymentReminders,
        'reminderDays': reminderDays,
        'monthlyReviewReminders': enabled,
        'monthlyReviewDay': day,
        'languageCode': languageCode,
      }),
    );
    monthlyReviewReminders = enabled;
    monthlyReviewDay = day;
  }

  Future<void> saveLanguage(String code) async {
    if (!['en', 'ar'].contains(code)) throw ArgumentError.value(code);
    await _prefs.setString(
      'riyal.settings.v1',
      jsonEncode({
        'paymentReminders': paymentReminders,
        'reminderDays': reminderDays,
        'monthlyReviewReminders': monthlyReviewReminders,
        'monthlyReviewDay': monthlyReviewDay,
        'languageCode': code,
      }),
    );
    languageCode = code;
  }
}
