import 'tracked_category.dart';

/// One bank transaction as shown in the "recent transactions" pickers —
/// see lib/data/bank_transaction_matcher.dart, which builds these from the
/// Supabase `mock_transactions` table (never from bundled demo data).
class MockTransaction {
  const MockTransaction({
    required this.merchant,
    required this.amount,
    required this.daysAgo,
    this.matchedName,
    this.matchedLogo,
    this.matchedCategory,
  });

  final String merchant;
  final double amount;
  final int daysAgo;
  final String? matchedName;
  final String? matchedLogo;
  final TrackedCategory? matchedCategory;
}
