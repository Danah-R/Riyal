import 'package:flutter_test/flutter_test.dart';
import 'package:riyal/data/item_payment_history.dart';
import 'package:riyal/data/mock_bank_transaction.dart';
import 'package:riyal/data/utility_anomaly_detection.dart';
import 'package:riyal/data/utility_categories.dart';

void main() {
  group('UtilityAnomalyDetector', () {
    test('does not flag a bill with fewer than 3 prior bills', () {
      final result = UtilityAnomalyDetector.detect(
        category: UtilityCategories.electricity,
        priorAmounts: [100, 100],
        currentAmount: 500,
      );
      expect(result, isNull);
    });

    test('does not flag a bill within normal variance', () {
      final result = UtilityAnomalyDetector.detect(
        category: UtilityCategories.water,
        priorAmounts: [100, 105, 95],
        currentAmount: 115,
      );
      expect(result, isNull);
    });

    test('flags 25-30% above trailing average as yellow', () {
      final result = UtilityAnomalyDetector.detect(
        category: UtilityCategories.electricity,
        priorAmounts: [100, 100, 100],
        currentAmount: 127,
      );
      expect(result, isNotNull);
      expect(result!.level, UtilityAnomalyLevel.yellow);
      expect(result.percentAbove, 27);
    });

    test('flags 50%+ above trailing average as red', () {
      final result = UtilityAnomalyDetector.detect(
        category: UtilityCategories.electricity,
        priorAmounts: [100, 100, 100],
        currentAmount: 160,
      );
      expect(result, isNotNull);
      expect(result!.level, UtilityAnomalyLevel.red);
      expect(result.percentAbove, 60);
    });

    test('internet stays unflagged under its flat 10% threshold', () {
      final result = UtilityAnomalyDetector.detect(
        category: UtilityCategories.internet,
        priorAmounts: [200, 200, 200],
        currentAmount: 215, // 7.5% above average
      );
      expect(result, isNull);
    });

    test('internet is flagged past 10% even though that is below the '
        'general 25% yellow threshold', () {
      final result = UtilityAnomalyDetector.detect(
        category: UtilityCategories.internet,
        priorAmounts: [200, 200, 200],
        currentAmount: 230, // 15% above average
      );
      expect(result, isNotNull);
      expect(result!.level, UtilityAnomalyLevel.yellow);
    });

    test('a bill below the trailing average is never flagged', () {
      final result = UtilityAnomalyDetector.detect(
        category: UtilityCategories.electricity,
        priorAmounts: [200, 200, 200],
        currentAmount: 90,
      );
      expect(result, isNull);
    });
  });

  group('historyForItemName / priceChanges', () {
    MockBankTransactionRow row(String merchant, double amount, int daysAgo) =>
        MockBankTransactionRow(
          id: '$merchant-$daysAgo',
          bankId: 'bank-1',
          merchantName: merchant,
          amount: amount,
          transactionDate: DateTime.now().subtract(Duration(days: daysAgo)),
          category: 'utility',
        );

    test('matches by case-insensitive substring, newest first', () {
      final all = [
        row('SAUDI ELECTRICITY COMPANY - SEC BILL', 150, 90),
        row('STC INTERNET BILL', 250, 60),
        row('SAUDI ELECTRICITY COMPANY - SEC BILL', 148, 0),
      ];
      final history = historyForItemName(all, 'Saudi Electricity Company');
      expect(history.length, 2);
      expect(history.first.amount, 148);
      expect(history.last.amount, 150);
    });

    test('reports only genuine amount changes, oldest to newest', () {
      final newestFirst = [
        row('X', 160, 0),
        row('X', 150, 30),
        row('X', 150, 60),
        row('X', 100, 90),
      ];
      final changes = priceChanges(newestFirst);
      expect(changes.map((c) => c.amount), [150, 160]);
    });

    test('reports no changes when the price never moved', () {
      final newestFirst = [row('X', 100, 0), row('X', 100, 30)];
      expect(priceChanges(newestFirst), isEmpty);
    });
  });
}
