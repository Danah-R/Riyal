import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

/// This device's anonymous identifier. It's the one thing that still has
/// to live in local storage — with no real Supabase Auth sign-in in this
/// app, there's no other stable anchor to say "these Postgres rows are
/// mine". Everything else (the Lean customer_id mapped to this device,
/// connected accounts, transactions, subscriptions) lives in Supabase —
/// see supabase/migrations/0001_init.sql.
class LeanCustomerStore {
  LeanCustomerStore._();
  static final instance = LeanCustomerStore._();

  SharedPreferencesAsync get _prefs => SharedPreferencesAsync();
  static const _deviceIdKey = 'riyal.device_id.v1';

  Future<String> getOrCreateDeviceId() async {
    final existing = await _prefs.getString(_deviceIdKey);
    if (existing != null) return existing;
    final generated = _generateId();
    await _prefs.setString(_deviceIdKey, generated);
    return generated;
  }

  String _generateId() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
