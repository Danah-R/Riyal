import 'catalog_entry.dart';
import 'mock_bank_transaction.dart';
import 'mock_charge.dart';
import 'mock_transactions.dart';
import 'subscription_catalog.dart';
import 'supabase_config.dart';
import 'tracked_domain.dart';
import 'user_bank_accounts_store.dart';

/// Every mock transaction across every bank the current user has
/// connected — used by the Accounts screen's recurring-suggestion panel,
/// which needs the full mix (subscriptions, utilities, people, one-offs)
/// to tell signal from noise. Returns an empty list rather than the
/// bundled demo data when nothing's connected — unlike the two loaders
/// below, there's no single-list fallback shape that makes sense here.
Future<List<MockBankTransactionRow>> loadAllConnectedTransactions() async {
  final accounts = UserBankAccountsStore.instance.accounts.value;
  if (accounts.isEmpty) return const [];
  final bankIds = accounts.map((a) => a.bankId).toList();
  final rows = await supabase
      .from('mock_transactions')
      .select()
      .inFilter('bank_id', bankIds);
  return rows.map(MockBankTransactionRow.fromRow).toList();
}

/// Real transactions from every connected bank account, filtered to the
/// 'subscription' category and mapped into the same [MockTransaction]
/// shape the "recent transactions" screen already renders. Falls back to
/// the bundled demo data when no bank is connected yet (or the fetch comes
/// back empty) so the screen is never blank.
Future<List<MockTransaction>> loadRecentSubscriptionTransactions() async {
  final accounts = UserBankAccountsStore.instance.accounts.value;
  if (accounts.isEmpty) return recentTransactions;
  final bankIds = accounts.map((a) => a.bankId).toList();

  final rows = await supabase
      .from('mock_transactions')
      .select()
      .inFilter('bank_id', bankIds)
      .eq('category', 'subscription')
      .order('transaction_date', ascending: false);
  final transactions = rows.map(MockBankTransactionRow.fromRow).toList();

  if (transactions.isEmpty) return recentTransactions;
  return transactions.map(matchBankTransaction).toList();
}

/// Same idea as [loadRecentSubscriptionTransactions], but for the
/// Utilities/Staff "from a previous transaction" flow — filtered to
/// [domain]'s own mock-transaction category and matched against that
/// domain's own catalog instead of the subscription catalog.
Future<List<MockCharge>> loadRecentDomainCharges(TrackedDomain domain) async {
  final accounts = UserBankAccountsStore.instance.accounts.value;
  if (accounts.isEmpty) return domain.mockCharges;
  final bankIds = accounts.map((a) => a.bankId).toList();

  final rows = await supabase
      .from('mock_transactions')
      .select()
      .inFilter('bank_id', bankIds)
      .eq('category', domain.mockTransactionCategory)
      .order('transaction_date', ascending: false);
  final transactions = rows.map(MockBankTransactionRow.fromRow).toList();

  if (transactions.isEmpty) return domain.mockCharges;
  return transactions
      .map((t) => _matchAgainstCatalog(t, domain.catalog))
      .toList();
}

MockCharge _matchAgainstCatalog(
  MockBankTransactionRow transaction,
  List<CatalogEntry> catalog,
) {
  final merchant = transaction.merchantName.toUpperCase();
  for (final entry in catalog) {
    if (merchant.contains(entry.name.toUpperCase())) {
      return MockCharge(
        merchant: transaction.merchantName,
        amount: transaction.amount,
        daysAgo: DateTime.now().difference(transaction.transactionDate).inDays,
        matchedName: entry.name,
        matchedLogo: entry.logoAsset,
        matchedIcon: entry.icon,
        matchedIconColor: entry.iconColor,
        matchedCategory: entry.category,
      );
    }
  }
  return MockCharge(
    merchant: transaction.merchantName,
    amount: transaction.amount,
    daysAgo: DateTime.now().difference(transaction.transactionDate).inDays,
  );
}

/// Best-effort matches a mock bank transaction's merchant name against the
/// known subscription catalog, producing the same [MockTransaction] shape
/// the "recent transactions" UI already renders.
MockTransaction matchBankTransaction(MockBankTransactionRow transaction) {
  final merchant = transaction.merchantName.toUpperCase();
  for (final app in subscriptionCatalog) {
    final name = app.name.toUpperCase();
    if (merchant.contains(name)) {
      return MockTransaction(
        merchant: transaction.merchantName,
        amount: transaction.amount,
        daysAgo: DateTime.now().difference(transaction.transactionDate).inDays,
        matchedName: app.name,
        matchedLogo: app.logoAsset,
        matchedCategory: app.category,
      );
    }
  }
  return MockTransaction(
    merchant: transaction.merchantName,
    amount: transaction.amount,
    daysAgo: DateTime.now().difference(transaction.transactionDate).inDays,
  );
}
