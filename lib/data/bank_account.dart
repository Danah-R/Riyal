enum BankAccountStatus { connected, syncing, error }

/// Mirrors a row in the Supabase `bank_accounts` table. The Edge Function
/// (supabase/functions/lean) is what actually writes these rows — after a
/// successful Lean connect, the app just re-reads this table rather than
/// constructing the record itself, so both the Dart and Edge Function
/// parsing of Lean's raw JSON don't need to be kept in sync.
class BankAccount {
  const BankAccount({
    required this.entityId,
    required this.bankName,
    required this.maskedAccountNumber,
    required this.status,
    this.accountId,
    this.lastSyncedAt,
    this.errorMessage,
  });

  /// Identifies this bank connection with Lean — the id used to fetch
  /// accounts/transactions/balance.
  final String entityId;

  /// Lean's internal account id within the entity, once known.
  final String? accountId;

  final String bankName;
  final String maskedAccountNumber;
  final BankAccountStatus status;
  final DateTime? lastSyncedAt;
  final String? errorMessage;

  factory BankAccount.fromSupabaseRow(Map<String, dynamic> row) => BankAccount(
    entityId: row['entity_id'] as String,
    accountId: row['account_id'] as String?,
    bankName: row['bank_name'] as String,
    maskedAccountNumber: row['masked_account_number'] as String,
    status: BankAccountStatus.values.firstWhere(
      (s) => s.name == row['status'],
      orElse: () => BankAccountStatus.error,
    ),
    lastSyncedAt: row['last_synced_at'] != null
        ? DateTime.tryParse(row['last_synced_at'] as String)
        : null,
    errorMessage: row['error_message'] as String?,
  );
}
