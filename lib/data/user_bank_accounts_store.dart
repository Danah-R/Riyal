import 'package:flutter/foundation.dart';

import 'device_id_store.dart';
import 'supabase_config.dart';
import 'user_bank_account.dart';

/// This device's connected mock bank accounts, backed by the Supabase
/// `user_bank_accounts` table (see
/// supabase/migrations/0004_bank_accounts_device_scoped.sql). Scoped by a
/// locally-generated device id rather than a real signed-in user — real
/// Supabase Auth (email confirmation) was blocking testing, so this
/// temporarily falls back to the same scheme `SubscriptionsStore` already
/// uses. See [AuthStore] for the auth wiring this bypasses for now.
class UserBankAccountsStore {
  UserBankAccountsStore._();
  static final instance = UserBankAccountsStore._();

  final accounts = ValueNotifier<List<UserBankAccount>>([]);

  Future<void> load() async {
    final deviceId = await DeviceIdStore.instance.getOrCreateDeviceId();
    final rows = await supabase
        .from('user_bank_accounts')
        .select('*, mock_banks(*)')
        .eq('device_id', deviceId)
        .order('connected_at', ascending: true);
    accounts.value = rows.map(UserBankAccount.fromRow).toList();
  }

  /// Whether this device has connected at least one bank — without forcing
  /// a full [load], for the post-login/signup gate.
  Future<bool> hasAnyAccount() async {
    final deviceId = await DeviceIdStore.instance.getOrCreateDeviceId();
    final rows = await supabase
        .from('user_bank_accounts')
        .select('id')
        .eq('device_id', deviceId)
        .limit(1);
    return rows.isNotEmpty;
  }

  Future<void> remove(String accountId) async {
    final deviceId = await DeviceIdStore.instance.getOrCreateDeviceId();
    await supabase
        .from('user_bank_accounts')
        .delete()
        .eq('id', accountId)
        .eq('device_id', deviceId);
    accounts.value = accounts.value.where((a) => a.id != accountId).toList();
  }

  /// Clears the in-memory list — kept around for [AuthStore.signOut]'s
  /// call site even while sign-out is a no-op with no real auth wired up.
  void clear() => accounts.value = [];
}
