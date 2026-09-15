import 'package:flutter_test/flutter_test.dart';
import 'package:riyal/data/mock_bank_transaction.dart';
import 'package:riyal/data/recurring_detection.dart';
import 'package:riyal/data/subscription.dart';

MockBankTransactionRow _tx(
  String merchantName,
  double amount,
  DateTime date, {
  String category = 'other',
  String? logoAsset,
}) => MockBankTransactionRow(
  id: '$merchantName-${date.toIso8601String()}',
  bankId: 'bank-1',
  merchantName: merchantName,
  amount: amount,
  transactionDate: date,
  category: category,
  logoAsset: logoAsset,
);

void main() {
  test('groups a monthly-cadence merchant into a detected subscription', () {
    final base = DateTime(2026, 1, 15);
    final transactions = [
      _tx('NETFLIX.COM', 45, base, category: 'subscription'),
      _tx(
        'NETFLIX.COM',
        45,
        base.add(const Duration(days: 30)),
        category: 'subscription',
      ),
      _tx(
        'NETFLIX.COM',
        45,
        base.add(const Duration(days: 61)),
        category: 'subscription',
      ),
    ];

    final detected = RecurringDetectionEngine.detect(transactions);

    expect(detected, hasLength(1));
    expect(detected.single.merchantName, 'Netflix.com');
    expect(detected.single.amount, 45);
    expect(detected.single.cycle, BillingCycle.monthly);
    expect(detected.single.occurrences, 3);
  });

  test('groups a yearly-cadence merchant separately from monthly ones', () {
    final transactions = [
      _tx('AMAZON PRIME', 20, DateTime(2023, 6, 1)),
      _tx('AMAZON PRIME', 20, DateTime(2024, 6, 1)),
      _tx('AMAZON PRIME', 20, DateTime(2025, 6, 2)),
      _tx('SPOTIFY AB', 25, DateTime(2025, 12, 1), category: 'subscription'),
      _tx('SPOTIFY AB', 25, DateTime(2026, 1, 1), category: 'subscription'),
      _tx('SPOTIFY AB', 25, DateTime(2026, 2, 1), category: 'subscription'),
    ];

    final detected = RecurringDetectionEngine.detect(transactions);
    final cycles = {for (final d in detected) d.merchantName: d.cycle};

    expect(cycles['Amazon Prime'], BillingCycle.yearly);
    expect(cycles['Spotify Ab'], BillingCycle.monthly);
  });

  test('ignores one-off purchases and inconsistent amounts', () {
    final transactions = [
      _tx('CARREFOUR HYPERMARKET', 214, DateTime(2026, 1, 1)),
      // Same merchant, wildly different amounts and no regular interval —
      // everyday shopping, not a subscription. Not tagged 'utility', so
      // the strict tolerance applies.
      _tx('CARREFOUR HYPERMARKET', 40, DateTime(2026, 1, 9)),
      _tx('CARREFOUR HYPERMARKET', 300, DateTime(2026, 1, 22)),
    ];

    expect(RecurringDetectionEngine.detect(transactions), isEmpty);
  });

  test('requires at least three occurrences to confirm a subscription', () {
    final transactions = [
      _tx('NETFLIX.COM', 45, DateTime(2026, 1, 1), category: 'subscription'),
      _tx('NETFLIX.COM', 45, DateTime(2026, 1, 31), category: 'subscription'),
    ];
    expect(RecurringDetectionEngine.detect(transactions), isEmpty);
  });

  test('confirms a utility bill despite month-to-month amount swings that '
      'would fail a subscription', () {
    final base = DateTime(2026, 1, 15);
    final transactions = [
      _tx('SAUDI ELECTRICITY COMPANY', 150, base, category: 'utility'),
      _tx(
        'SAUDI ELECTRICITY COMPANY',
        95,
        base.add(const Duration(days: 30)),
        category: 'utility',
      ),
      _tx(
        'SAUDI ELECTRICITY COMPANY',
        210,
        base.add(const Duration(days: 61)),
        category: 'utility',
      ),
    ];

    final detected = RecurringDetectionEngine.detect(transactions);

    expect(detected, hasLength(1));
    expect(detected.single.cycle, BillingCycle.monthly);
    expect(detected.single.occurrences, 3);
  });

  test('still rejects a non-utility merchant with the same amount swings', () {
    final base = DateTime(2026, 1, 15);
    final transactions = [
      _tx('RANDOM MERCHANT', 150, base),
      _tx('RANDOM MERCHANT', 95, base.add(const Duration(days: 30))),
      _tx('RANDOM MERCHANT', 210, base.add(const Duration(days: 61))),
    ];

    expect(RecurringDetectionEngine.detect(transactions), isEmpty);
  });

  test('carries the transaction\'s own logo through to the suggestion', () {
    final base = DateTime(2026, 1, 15);
    final transactions = [
      _tx(
        'ANGHAMI MUSIC',
        20,
        base,
        category: 'subscription',
        logoAsset: 'lib/assets/logos/anghami.png',
      ),
      _tx(
        'ANGHAMI MUSIC',
        20,
        base.add(const Duration(days: 30)),
        category: 'subscription',
        logoAsset: 'lib/assets/logos/anghami.png',
      ),
      _tx(
        'ANGHAMI MUSIC',
        20,
        base.add(const Duration(days: 61)),
        category: 'subscription',
        logoAsset: 'lib/assets/logos/anghami.png',
      ),
    ];

    final detected = RecurringDetectionEngine.detect(transactions);

    expect(detected.single.logoAsset, 'lib/assets/logos/anghami.png');
  });

  test('leaves logoAsset null when the transaction has none', () {
    final base = DateTime(2026, 1, 15);
    final transactions = [
      _tx('NANNY SALARY - MARIA', 1200, base, category: 'person'),
      _tx(
        'NANNY SALARY - MARIA',
        1200,
        base.add(const Duration(days: 30)),
        category: 'person',
      ),
      _tx(
        'NANNY SALARY - MARIA',
        1200,
        base.add(const Duration(days: 61)),
        category: 'person',
      ),
    ];

    final detected = RecurringDetectionEngine.detect(transactions);

    expect(detected.single.category, 'person');
    expect(detected.single.logoAsset, isNull);
  });
}
