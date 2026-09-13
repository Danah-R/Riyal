import 'package:flutter/foundation.dart';

import 'bank_account.dart';
import 'lean_customer_store.dart';
import 'supabase_config.dart';

/// Connected bank accounts, backed by the Supabase `bank_accounts` table
/// (see supabase/migrations/0001_init.sql) instead of local storage — the
/// Edge Function writes rows here after a successful Lean connect, and
/// this store just reads them back.
class BankAccountsStore {
  BankAccountsStore._();
  static final instance = BankAccountsStore._();

  final accounts = ValueNotifier<List<BankAccount>>([]);

  Future<void> load() async {
    final deviceId = await LeanCustomerStore.instance.getOrCreateDeviceId();
    final rows = await supabase
        .from('bank_accounts')
        .select()
        .eq('device_id', deviceId)
        .order('created_at');
    accounts.value = rows
        .map((row) => BankAccount.fromSupabaseRow(row))
        .toList();
  }

  Future<void> remove(String entityId) async {
    final deviceId = await LeanCustomerStore.instance.getOrCreateDeviceId();
    await supabase
        .from('bank_accounts')
        .delete()
        .eq('device_id', deviceId)
        .eq('entity_id', entityId);
    accounts.value = accounts.value
        .where((a) => a.entityId != entityId)
        .toList();
  }
}
