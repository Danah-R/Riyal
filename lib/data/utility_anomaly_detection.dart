import 'tracked_category.dart';
import 'utility_categories.dart';

enum UtilityAnomalyLevel { yellow, red }

class UtilityAnomaly {
  const UtilityAnomaly({
    required this.level,
    required this.currentAmount,
    required this.trailingAverage,
    required this.percentAbove,
  });

  final UtilityAnomalyLevel level;
  final double currentAmount;
  final double trailingAverage;

  /// Rounded whole-percent the current bill is above [trailingAverage].
  final int percentAbove;
}

/// Flags a utility bill as unusual relative to its own trailing history —
/// styled the same way as [RecurringDetectionEngine] (see
/// lib/data/recurring_detection.dart): a private-constructor, static-only
/// class with named tunable constants and a pure `detect` function.
class UtilityAnomalyDetector {
  UtilityAnomalyDetector._();

  /// At least this many prior bills are required before flagging anything —
  /// a brand-new utility has no baseline to compare against yet.
  static const _minPriorBills = 3;

  /// 25-30% above the trailing average is a "check this out" spike.
  static const _yellowThreshold = 0.25;

  /// 50%+ above the trailing average is a "this looks like a leak/fault"
  /// spike.
  static const _redThreshold = 0.50;

  /// Wifi/internet is fixed-price and shouldn't fluctuate like a
  /// usage-based utility, so it gets one flat, much tighter threshold
  /// instead of the yellow/red tiers above.
  static const _flatRateThreshold = 0.10;

  static bool _isFlatRate(TrackedCategory category) =>
      category == UtilityCategories.internet;

  /// [priorAmounts] must be the bills immediately before [currentAmount],
  /// oldest-to-newest or newest-to-newest order doesn't matter — only their
  /// average is used. Returns null when there's not enough history yet, or
  /// the current amount doesn't cross any threshold.
  static UtilityAnomaly? detect({
    required TrackedCategory category,
    required List<double> priorAmounts,
    required double currentAmount,
  }) {
    if (priorAmounts.length < _minPriorBills) return null;
    final trailingAverage =
        priorAmounts.reduce((a, b) => a + b) / priorAmounts.length;
    if (trailingAverage <= 0) return null;

    final ratio = (currentAmount - trailingAverage) / trailingAverage;
    final percentAbove = (ratio * 100).round();

    if (_isFlatRate(category)) {
      if (ratio > _flatRateThreshold) {
        return UtilityAnomaly(
          level: UtilityAnomalyLevel.yellow,
          currentAmount: currentAmount,
          trailingAverage: trailingAverage,
          percentAbove: percentAbove,
        );
      }
      return null;
    }

    if (ratio >= _redThreshold) {
      return UtilityAnomaly(
        level: UtilityAnomalyLevel.red,
        currentAmount: currentAmount,
        trailingAverage: trailingAverage,
        percentAbove: percentAbove,
      );
    }
    if (ratio >= _yellowThreshold) {
      return UtilityAnomaly(
        level: UtilityAnomalyLevel.yellow,
        currentAmount: currentAmount,
        trailingAverage: trailingAverage,
        percentAbove: percentAbove,
      );
    }
    return null;
  }
}
