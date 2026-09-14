import 'package:flutter_test/flutter_test.dart';
import 'package:riyal/data/bank_transaction_matcher.dart';
import 'package:riyal/data/mock_bank_transaction.dart';

MockBankTransactionRow _tx({required String merchant, String? logoAsset}) =>
    MockBankTransactionRow(
      id: 'tx-1',
      bankId: 'bank-1',
      merchantName: merchant,
      amount: 45,
      transactionDate: DateTime(2026, 1, 15),
      category: 'subscription',
      logoAsset: logoAsset,
    );

void main() {
  group('matchBankTransaction', () {
    test('prefers the logo stored on the transaction over the catalog\'s '
        'own guess', () {
      final result = matchBankTransaction(
        _tx(
          merchant: 'NETFLIX.COM',
          logoAsset: 'lib/assets/logos/Netflix_icon.svg',
        ),
      );

      expect(result.matchedName, 'Netflix');
      expect(result.matchedLogo, 'lib/assets/logos/Netflix_icon.svg');
    });

    test('falls back to the catalog logo when Supabase has none stored', () {
      final result = matchBankTransaction(_tx(merchant: 'NETFLIX.COM'));

      expect(result.matchedName, 'Netflix');
      expect(result.matchedLogo, 'lib/assets/logos/Netflix_icon.svg');
    });

    test('carries a stored logo through even with no catalog match', () {
      final result = matchBankTransaction(
        _tx(
          merchant: 'SOME UNKNOWN MERCHANT',
          logoAsset: 'lib/assets/logos/mystery.png',
        ),
      );

      expect(result.matchedName, isNull);
      expect(result.matchedLogo, 'lib/assets/logos/mystery.png');
    });
  });
}
