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
/// to tell signal from noise, and by the "add from a previous transaction"
/// pickers below, which deliberately show every transaction rather than
/// pre-filtering by category — the user picks, not a category guess.
/// Always reads from Supabase; returns empty rather than falling back to
/// any bundled demo data.
Future<List<MockBankTransactionRow>> loadAllConnectedTransactions() async {
  final accounts = UserBankAccountsStore.instance.accounts.value;
  if (accounts.isEmpty) return const [];
  final bankIds = accounts.map((a) => a.bankId).toList();
  final rows = await supabase
      .from('mock_transactions')
      .select()
      .inFilter('bank_id', bankIds)
      .order('transaction_date', ascending: false);
  return rows.map(MockBankTransactionRow.fromRow).toList();
}

/// Every connected transaction, matched against the subscription catalog
/// where possible and mapped into the [MockTransaction] shape the "recent
/// transactions" screen renders — including transactions that don't match
/// any known subscription, so the user can turn literally any charge into
/// a tracked subscription, not just ones we recognize.
Future<List<MockTransaction>> loadRecentSubscriptionTransactions() async {
  final transactions = await loadAllConnectedTransactions();
  return transactions.map(matchBankTransaction).toList();
}

/// Same idea as [loadRecentSubscriptionTransactions], but matched against
/// [domain]'s own catalog (Utilities/People) instead of the subscription
/// one — still every connected transaction, not just ones already tagged
/// with that domain's category.
Future<List<MockCharge>> loadRecentDomainCharges(TrackedDomain domain) async {
  final transactions = await loadAllConnectedTransactions();
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
        // Supabase's own logo_asset (see
        // supabase/migrations/0005_transaction_logos.sql) wins when set;
        // the catalog's is just a fallback guess from the merchant name.
        matchedLogo: transaction.logoAsset ?? entry.logoAsset,
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
    matchedLogo: transaction.logoAsset,
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
        matchedLogo: transaction.logoAsset ?? app.logoAsset,
        matchedCategory: app.category,
      );
    }
  }
  return MockTransaction(
    merchant: transaction.merchantName,
    amount: transaction.amount,
    daysAgo: DateTime.now().difference(transaction.transactionDate).inDays,
    matchedLogo: transaction.logoAsset,
  );
}
