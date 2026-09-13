import 'bank_account.dart';
import 'bank_accounts_store.dart';
import 'bank_transaction.dart';
import 'catalog_entry.dart';
import 'lean_customer_store.dart';
import 'lean_service.dart';
import 'mock_charge.dart';
import 'mock_transactions.dart';
import 'subscription_catalog.dart';
import 'tracked_domain.dart';

/// Real transactions from every connected bank account, mapped into the
/// same [MockTransaction] shape the "recent transactions" screen already
/// renders. Falls back to the bundled demo data when no bank is connected
/// yet (or the fetch comes back empty) so the screen is never blank.
Future<List<MockTransaction>> loadRecentSubscriptionTransactions() async {
  final accounts = BankAccountsStore.instance.accounts.value;
  if (accounts.isEmpty) return recentTransactions;
  final deviceId = await LeanCustomerStore.instance.getOrCreateDeviceId();

  final matched = <MockTransaction>[];
  for (final BankAccount account in accounts) {
    try {
      final json = await LeanService.instance.fetchTransactions(
        entityId: account.entityId,
        deviceId: deviceId,
      );
      final transactions = BankTransaction.fromLeanJson(
        entityId: account.entityId,
        json: json,
      );
      matched.addAll(transactions.map(matchBankTransaction));
    } catch (_) {
      // This account's data may not be ready yet — skip it rather than
      // failing the whole screen.
    }
  }

  if (matched.isEmpty) return recentTransactions;
  matched.sort((a, b) => a.daysAgo.compareTo(b.daysAgo));
  return matched;
}

/// Same idea as [loadRecentSubscriptionTransactions], but for the
/// Utilities/Staff "from a previous transaction" flow, matched against
/// that [domain]'s own catalog instead of the subscription catalog.
Future<List<MockCharge>> loadRecentDomainCharges(TrackedDomain domain) async {
  final accounts = BankAccountsStore.instance.accounts.value;
  if (accounts.isEmpty) return domain.mockCharges;
  final deviceId = await LeanCustomerStore.instance.getOrCreateDeviceId();

  final matched = <MockCharge>[];
  for (final BankAccount account in accounts) {
    try {
      final json = await LeanService.instance.fetchTransactions(
        entityId: account.entityId,
        deviceId: deviceId,
      );
      final transactions = BankTransaction.fromLeanJson(
        entityId: account.entityId,
        json: json,
      );
      matched.addAll(
        transactions.map((t) => _matchAgainstCatalog(t, domain.catalog)),
      );
    } catch (_) {
      // Skip accounts whose data isn't ready yet.
    }
  }

  if (matched.isEmpty) return domain.mockCharges;
  matched.sort((a, b) => a.daysAgo.compareTo(b.daysAgo));
  return matched;
}

MockCharge _matchAgainstCatalog(
  BankTransaction transaction,
  List<CatalogEntry> catalog,
) {
  final description = transaction.description.toUpperCase();
  for (final entry in catalog) {
    if (description.contains(entry.name.toUpperCase())) {
      return MockCharge(
        merchant: transaction.description,
        amount: transaction.amount,
        daysAgo: DateTime.now().difference(transaction.date).inDays,
        matchedName: entry.name,
        matchedLogo: entry.logoAsset,
        matchedIcon: entry.icon,
        matchedIconColor: entry.iconColor,
        matchedCategory: entry.category,
      );
    }
  }
  return MockCharge(
    merchant: transaction.description,
    amount: transaction.amount,
    daysAgo: DateTime.now().difference(transaction.date).inDays,
  );
}

/// Best-effort matches a real bank transaction's raw description against
/// the known subscription catalog, producing the same [MockTransaction]
/// shape the "recent transactions" UI already renders — so real Lean data
/// can flow through that screen unchanged.
MockTransaction matchBankTransaction(BankTransaction transaction) {
  final description = transaction.description.toUpperCase();
  for (final app in subscriptionCatalog) {
    final name = app.name.toUpperCase();
    if (description.contains(name)) {
      return MockTransaction(
        merchant: transaction.description,
        amount: transaction.amount,
        daysAgo: DateTime.now().difference(transaction.date).inDays,
        matchedName: app.name,
        matchedLogo: app.logoAsset,
        matchedCategory: app.category,
      );
    }
  }
  return MockTransaction(
    merchant: transaction.description,
    amount: transaction.amount,
    daysAgo: DateTime.now().difference(transaction.date).inDays,
  );
}
