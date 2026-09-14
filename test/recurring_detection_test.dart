import 'package:flutter_test/flutter_test.dart';
import 'package:riyal/data/mock_bank_transaction.dart';
import 'package:riyal/data/recurring_detection.dart';
import 'package:riyal/data/subscription.dart';

MockBankTransactionRow _tx(String merchantName, double amount, DateTime date) =>
    MockBankTransactionRow(
      id: '$merchantName-${date.toIso8601String()}',
      bankId: 'bank-1',
      merchantName: merchantName,
      amount: amount,
      transactionDate: date,
      category: 'other',
    );

void main() {
  test('groups a monthly-cadence merchant into a detected subscription', () {
    final base = DateTime(2026, 1, 15);
    final transactions = [
      _tx('NETFLIX.COM', 45, base),
      _tx('NETFLIX.COM', 45, base.add(const Duration(days: 30))),
      _tx('NETFLIX.COM', 45, base.add(const Duration(days: 61))),
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
      _tx('AMAZON PRIME', 20, DateTime(2024, 6, 1)),
      _tx('AMAZON PRIME', 20, DateTime(2025, 6, 2)),
      _tx('SPOTIFY AB', 25, DateTime(2026, 1, 1)),
      _tx('SPOTIFY AB', 25, DateTime(2026, 2, 1)),
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
      // everyday shopping, not a subscription.
      _tx('CARREFOUR HYPERMARKET', 40, DateTime(2026, 1, 9)),
      _tx('CARREFOUR HYPERMARKET', 300, DateTime(2026, 1, 22)),
    ];

    expect(RecurringDetectionEngine.detect(transactions), isEmpty);
  });

  test('requires at least two occurrences to suggest a subscription', () {
    final transactions = [_tx('NETFLIX.COM', 45, DateTime(2026, 1, 1))];
    expect(RecurringDetectionEngine.detect(transactions), isEmpty);
  });
}
