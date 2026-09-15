import 'mock_bank_transaction.dart';

/// Matches a tracked item's name against connected-bank transaction rows —
/// the same substring convention used elsewhere to line up a bank charge
/// with a catalog entry (see `_matchAgainstCatalog` in
/// lib/data/bank_transaction_matcher.dart) — so the details page can show
/// real payment/price history without a new persisted history log. Returns
/// matches newest-first.
List<MockBankTransactionRow> historyForItemName(
  List<MockBankTransactionRow> allTransactions,
  String name,
) {
  final needle = name.toUpperCase();
  final matches = allTransactions
      .where((t) => t.merchantName.toUpperCase().contains(needle))
      .toList()
    ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
  return matches;
}

/// The distinct amount changes across a merchant's history, oldest first —
/// empty when the price never changed (or there's fewer than two payments),
/// in which case the details page's "price history" section stays hidden.
List<MockBankTransactionRow> priceChanges(
  List<MockBankTransactionRow> historyNewestFirst,
) {
  final oldestFirst = historyNewestFirst.reversed.toList();
  final changes = <MockBankTransactionRow>[];
  for (var i = 1; i < oldestFirst.length; i++) {
    if (oldestFirst[i].amount != oldestFirst[i - 1].amount) {
      changes.add(oldestFirst[i]);
    }
  }
  return changes;
}
