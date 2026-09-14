/// One row from the Supabase `mock_transactions` table (see
/// supabase/migrations/0003_mock_banking.sql) — a canned transaction
/// belonging to one of the mock banks, for a connected user to "see" once
/// they've linked that bank.
class MockBankTransactionRow {
  const MockBankTransactionRow({
    required this.id,
    required this.bankId,
    required this.merchantName,
    required this.amount,
    required this.transactionDate,
    required this.category,
    this.logoAsset,
  });

  final String id;
  final String bankId;
  final String merchantName;
  final double amount;
  final DateTime transactionDate;

  /// One of 'subscription', 'utility', 'person', 'other'.
  final String category;

  /// Set directly in Supabase (see
  /// supabase/migrations/0005_transaction_logos.sql) for merchants with a
  /// real bundled logo asset; null for everything else, in which case
  /// callers fall back to matching [merchantName] against a Dart-side
  /// catalog instead — see lib/data/bank_transaction_matcher.dart.
  final String? logoAsset;

  factory MockBankTransactionRow.fromRow(Map<String, dynamic> row) =>
      MockBankTransactionRow(
        id: row['id'] as String,
        bankId: row['bank_id'] as String,
        merchantName: row['merchant_name'] as String,
        amount: (row['amount'] as num).toDouble(),
        transactionDate: DateTime.parse(row['transaction_date'] as String),
        category: row['category'] as String,
        logoAsset: row['logo_asset'] as String?,
      );
}
