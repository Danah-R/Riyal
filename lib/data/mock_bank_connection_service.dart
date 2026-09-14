import 'dart:math';

import 'device_id_store.dart';
import 'mock_bank.dart';
import 'supabase_config.dart';

/// Simulates "connecting" a bank: after the fake login screen's Login
/// button is tapped, this is what actually happens — insert a row into
/// `user_bank_accounts` for this device. No real bank is ever contacted;
/// see the disclaimer on [ConnectBankScreen].
class MockBankConnectionService {
  MockBankConnectionService._();
  static final instance = MockBankConnectionService._();

  Future<void> connect(MockBank bank) async {
    final deviceId = await DeviceIdStore.instance.getOrCreateDeviceId();
    await supabase.from('user_bank_accounts').upsert({
      'device_id': deviceId,
      'bank_id': bank.id,
      'account_label': 'Checking',
      'masked_account_number': _fakeMaskedNumber(),
    }, onConflict: 'device_id,bank_id');
  }

  String _fakeMaskedNumber() {
    final random = Random();
    final digits = List.generate(4, (_) => random.nextInt(10)).join();
    return '•••• $digits';
  }
}
