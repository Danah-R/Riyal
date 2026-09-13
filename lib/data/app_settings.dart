import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  static final instance = AppSettings();
  final _prefs = SharedPreferencesAsync();
  bool paymentReminders = true;
  int reminderDays = 5;

  Future<void> load() async {
    final raw = await _prefs.getString('riyal.settings.v1');
    if (raw == null) return;
    final data = jsonDecode(raw) as Map<String, dynamic>;
    paymentReminders = data['paymentReminders'] as bool? ?? true;
    final days = data['reminderDays'];
    reminderDays = [1, 3, 5, 7].contains(days) ? days as int : 5;
  }

  Future<void> save({required bool enabled, required int days}) async {
    if (![1, 3, 5, 7].contains(days)) throw ArgumentError.value(days);
    await _prefs.setString(
      'riyal.settings.v1',
      jsonEncode({'paymentReminders': enabled, 'reminderDays': days}),
    );
    paymentReminders = enabled;
    reminderDays = days;
  }
}
