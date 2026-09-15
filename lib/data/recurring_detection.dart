import 'mock_bank_transaction.dart';
import 'subscription.dart';

/// A recurring-payment candidate found in a connected bank account's
/// transaction history — merchant-grouped, amount- and interval-matched,
/// and classified into a billing cycle.
class DetectedSubscription {
  const DetectedSubscription({
    required this.merchantName,
    required this.amount,
    required this.cycle,
    required this.lastDate,
    required this.occurrences,
    required this.category,
    this.logoAsset,
  });

  final String merchantName;
  final double amount;
  final BillingCycle cycle;
  final DateTime lastDate;
  final int occurrences;

  /// One of 'subscription', 'utility', 'person', 'other' — which domain
  /// this recurring charge should be added to (see
  /// lib/screens/accounts_screen.dart's `_addSuggestion`), not just a
  /// blanket "subscription".
  final String category;

  /// From the matching transaction's own `logo_asset` column when set (see
  /// supabase/migrations/0005_transaction_logos.sql) — null for merchants
  /// with no bundled image, in which case the caller falls back to
  /// matching [merchantName] against a Dart-side catalog instead.
  final String? logoAsset;

  /// Naive next-due estimate from the last seen charge — good enough as a
  /// starting point for a suggested subscription; the user can adjust it.
  DateTime get suggestedNextBillingDate => cycle == BillingCycle.yearly
      ? DateTime(lastDate.year + 1, lastDate.month, lastDate.day)
      : DateTime(lastDate.year, lastDate.month + 1, lastDate.day);
}

/// Groups bank transactions by merchant, and flags groups whose amount and
/// timing look like a recurring subscription (as opposed to one-off
/// purchases from the same merchant). A group is only "confirmed" as
/// recurring once it's been seen at least [_minOccurrences] times — one or
/// two charges from the same merchant isn't enough signal.
class RecurringDetectionEngine {
  RecurringDetectionEngine._();

  /// A merchant needs at least this many charges before it's confirmed as
  /// recurring rather than a coincidence — the floor for showing up as a
  /// manual "possible" suggestion at all.
  static const _minOccurrences = 3;

  /// At or above this many occurrences, a recurring charge is confident
  /// enough to skip the manual confirm step entirely and go straight from
  /// detected to added (see lib/data/notifications_store.dart's
  /// `_refreshAutoDetection` and lib/screens/accounts_screen.dart). Below
  /// this — i.e. exactly [_minOccurrences] — it still surfaces as a manual
  /// suggestion instead.
  static const autoAddOccurrences = 4;

  /// Amounts within this fraction of the group average still count as
  /// "the same" — banks occasionally show tiny FX/rounding variance on
  /// otherwise-fixed subscription charges.
  static const _amountTolerance = 0.05;

  /// Utility bills genuinely fluctuate month to month (usage-based), so
  /// they get a much looser amount tolerance than a fixed-price
  /// subscription or a flat person-to-person payment.
  static const _utilityAmountTolerance = 0.4;

  static List<DetectedSubscription> detect(
    List<MockBankTransactionRow> transactions,
  ) {
    final groups = <String, List<MockBankTransactionRow>>{};
    for (final transaction in transactions) {
      groups
          .putIfAbsent(_normalizeMerchant(transaction.merchantName), () => [])
          .add(transaction);
    }

    final results = <DetectedSubscription>[];
    for (final group in groups.values) {
      if (group.length < _minOccurrences) continue;
      final sorted = [...group]
        ..sort((a, b) => a.transactionDate.compareTo(b.transactionDate));

      final avgAmount =
          sorted.map((t) => t.amount).reduce((a, b) => a + b) / sorted.length;
      if (avgAmount <= 0) continue;
      final tolerance = sorted.first.category == 'utility'
          ? _utilityAmountTolerance
          : _amountTolerance;
      final amountsConsistent = sorted.every(
        (t) => (t.amount - avgAmount).abs() / avgAmount <= tolerance,
      );
      if (!amountsConsistent) continue;

      final intervals = <int>[
        for (var i = 1; i < sorted.length; i++)
          sorted[i].transactionDate
              .difference(sorted[i - 1].transactionDate)
              .inDays,
      ];
      final avgInterval = intervals.reduce((a, b) => a + b) / intervals.length;

      final cycle = _classifyCycle(avgInterval);
      if (cycle == null) continue;

      results.add(
        DetectedSubscription(
          merchantName: _displayName(sorted.last.merchantName),
          amount: avgAmount,
          cycle: cycle,
          lastDate: sorted.last.transactionDate,
          occurrences: sorted.length,
          category: sorted.first.category,
          logoAsset: sorted.last.logoAsset,
        ),
      );
    }

    results.sort((a, b) => b.lastDate.compareTo(a.lastDate));
    return results;
  }

  static BillingCycle? _classifyCycle(double avgIntervalDays) {
    if (avgIntervalDays >= 25 && avgIntervalDays <= 35) {
      return BillingCycle.monthly;
    }
    if (avgIntervalDays >= 350 && avgIntervalDays <= 380) {
      return BillingCycle.yearly;
    }
    return null;
  }

  /// Strips digits, punctuation and extra whitespace so e.g. "NETFLIX.COM"
  /// and "NETFLIX COM 123456" group together.
  static String _normalizeMerchant(String description) {
    return description
        .toUpperCase()
        .replaceAll(RegExp(r'[0-9]+'), ' ')
        .replaceAll(RegExp(r'[^A-Z ]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// A human-friendlier version of the raw bank description for display,
  /// e.g. "NETFLIX.COM" -> "Netflix.com". Kept close to the original
  /// (untranslated, like other merchant/brand text in this app) rather
  /// than trying to map to a "real" brand name.
  static String _displayName(String rawDescription) {
    final trimmed = rawDescription.trim();
    if (trimmed.isEmpty) return trimmed;
    return trimmed
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? word
              : word[0].toUpperCase() + word.substring(1).toLowerCase(),
        )
        .join(' ');
  }
}
