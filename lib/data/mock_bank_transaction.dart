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
  });

  final String id;
  final String bankId;
  final String merchantName;
  final double amount;
  final DateTime transactionDate;

  /// One of 'subscription', 'utility', 'person', 'other'.
  final String category;

  factory MockBankTransactionRow.fromRow(Map<String, dynamic> row) =>
      MockBankTransactionRow(
        id: row['id'] as String,
        bankId: row['bank_id'] as String,
        merchantName: row['merchant_name'] as String,
        amount: (row['amount'] as num).toDouble(),
        transactionDate: DateTime.parse(row['transaction_date'] as String),
        category: row['category'] as String,
      );
}
