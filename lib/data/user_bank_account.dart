import 'package:flutter/material.dart';

import 'mock_bank.dart';

/// A bank this device has "connected" via the mock connect flow — mirrors
/// a `user_bank_accounts` row joined with its `mock_banks` row (see
/// supabase/migrations/0003_mock_banking.sql and
/// 0004_bank_accounts_device_scoped.sql). Unlike the old Lean-backed
/// model, there's no sync status: a mock connection is either there or it
/// isn't.
class UserBankAccount {
  const UserBankAccount({
    required this.id,
    required this.bankId,
    required this.bankName,
    required this.bankPrimaryColor,
    required this.accountLabel,
    required this.maskedAccountNumber,
    required this.connectedAt,
  });

  final String id;
  final String bankId;
  final String bankName;
  final Color bankPrimaryColor;
  final String accountLabel;
  final String maskedAccountNumber;
  final DateTime connectedAt;

  factory UserBankAccount.fromRow(Map<String, dynamic> row) {
    final bank = row['mock_banks'] as Map<String, dynamic>;
    return UserBankAccount(
      id: row['id'] as String,
      bankId: row['bank_id'] as String,
      bankName: bank['name'] as String,
      bankPrimaryColor: MockBank.fromRow(bank).primaryColor,
      accountLabel: row['account_label'] as String,
      maskedAccountNumber: row['masked_account_number'] as String,
      connectedAt: DateTime.parse(row['connected_at'] as String),
    );
  }
}
