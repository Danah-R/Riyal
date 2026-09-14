import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riyal/data/mock_bank.dart';
import 'package:riyal/data/mock_bank_transaction.dart';
import 'package:riyal/data/user_bank_account.dart';

void main() {
  group('MockBank.fromRow', () {
    test('parses a mock_banks row, including its hex color', () {
      final bank = MockBank.fromRow({
        'id': 'bank-1',
        'name': 'Al Rajhi Bank',
        'logo_asset_path': null,
        'primary_color': '#1A6E3C',
        'sort_order': 1,
      });

      expect(bank.id, 'bank-1');
      expect(bank.name, 'Al Rajhi Bank');
      expect(bank.logoAssetPath, isNull);
      expect(bank.primaryColor, const Color(0xFF1A6E3C));
    });
  });

  group('MockBankTransactionRow.fromRow', () {
    test('parses a mock_transactions row', () {
      final row = MockBankTransactionRow.fromRow({
        'id': 'tx-1',
        'bank_id': 'bank-1',
        'merchant_name': 'NETFLIX.COM',
        'amount': 45,
        'transaction_date': '2026-01-15',
        'category': 'subscription',
      });

      expect(row.id, 'tx-1');
      expect(row.bankId, 'bank-1');
      expect(row.merchantName, 'NETFLIX.COM');
      expect(row.amount, 45);
      expect(row.transactionDate, DateTime(2026, 1, 15));
      expect(row.category, 'subscription');
    });
  });

  group('UserBankAccount.fromRow', () {
    test('parses a user_bank_accounts row joined with mock_banks', () {
      final account = UserBankAccount.fromRow({
        'id': 'acc-1',
        'bank_id': 'bank-1',
        'account_label': 'Checking',
        'masked_account_number': '•••• 4821',
        'connected_at': '2026-01-15T00:00:00.000Z',
        'mock_banks': {
          'id': 'bank-1',
          'name': 'Al Rajhi Bank',
          'logo_asset_path': null,
          'primary_color': '#1A6E3C',
          'sort_order': 1,
        },
      });

      expect(account.id, 'acc-1');
      expect(account.bankId, 'bank-1');
      expect(account.bankName, 'Al Rajhi Bank');
      expect(account.bankPrimaryColor, const Color(0xFF1A6E3C));
      expect(account.accountLabel, 'Checking');
      expect(account.maskedAccountNumber, '•••• 4821');
    });
  });
}
