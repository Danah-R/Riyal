import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/strings.dart';

/// English display label for a profile field key -> its localized text.
/// The keys themselves ('Full name', 'Email', ...) stay English: they're
/// used for persistence and equality checks throughout profile_screen.dart.
String profileFieldLabel(String field) => switch (field) {
  'Full name' => Strings.t('field_full_name'),
  'Email' => Strings.t('field_email'),
  'Phone number' => Strings.t('field_phone_number'),
  'Joined on' => Strings.t('field_joined_on'),
  _ => field,
};

class ProfileStore {
  static final instance = ProfileStore();
  SharedPreferencesAsync get _prefs => SharedPreferencesAsync();
  Map<String, String> values = {
    'Full name': 'Riyal User',
    'Email': 'user@example.com',
    'Phone number': '+966 50 000 0000',
    'Joined on': DateTime.now().toIso8601String().split('T').first,
  };
  Future<void> load() async {
    final saved = await _prefs.getString('riyal.demo_profile.v1');
    if (saved == null) {
      await _prefs.setString('riyal.demo_profile.v1', jsonEncode(values));
    }
    if (saved != null) {
      values = {
        ...values,
        ...Map<String, String>.from(jsonDecode(saved) as Map),
      };
    }
  }

  Future<void> save(String field, String value) async {
    if (!['Full name', 'Email', 'Phone number'].contains(field)) {
      throw ArgumentError('This profile field is read-only');
    }
    final next = {...values, field: value};
    await _prefs.setString('riyal.demo_profile.v1', jsonEncode(next));
    values = next;
  }
}
