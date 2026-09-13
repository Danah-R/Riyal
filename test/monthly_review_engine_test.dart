import 'package:flutter_test/flutter_test.dart';
import 'package:riyal/data/monthly_review.dart';
import 'package:riyal/data/subscription.dart';

void main() {
  MonthlyReviewItem subscription({
    String name = 'Example',
    double amount = 50,
  }) => MonthlyReviewItem(
    id: 'subscription:${name.toLowerCase()}',
    name: name,
    domain: ReviewDomain.subscription,
    monthlyAmount: amount,
    cycle: BillingCycle.monthly,
  );

  test('unused subscription produces quantified cancellation saving', () {
    final answer = MonthlyReviewAnswer(
      item: subscription(amount: 45),
      activity: ReviewActivity.none,
      need: ReviewNeed.unsure,
      continueForYear: false,
    );

    final recommendation = MonthlyReviewEngine.evaluate([answer]).single;

    expect(recommendation.type, RecommendationType.cancel);
    expect(recommendation.monthlySaving, 45);
    expect(recommendation.annualSaving, 540);
  });

  test('frequently used monthly subscription flags annual-plan review', () {
    final answer = MonthlyReviewAnswer(
      item: subscription(),
      activity: ReviewActivity.high,
      need: ReviewNeed.keep,
      continueForYear: true,
    );

    final recommendation = MonthlyReviewEngine.evaluate([answer]).single;

    expect(recommendation.type, RecommendationType.annualPlan);
    expect(recommendation.monthlySaving, 0);
  });

  test('essential utility is not treated as a cancellation target', () {
    const item = MonthlyReviewItem(
      id: 'utility:electricity',
      name: 'Electricity',
      domain: ReviewDomain.utility,
      monthlyAmount: 150,
      cycle: BillingCycle.monthly,
    );
    const answer = MonthlyReviewAnswer(
      item: item,
      activity: ReviewActivity.low,
      need: ReviewNeed.keep,
      continueForYear: true,
    );

    final recommendation = MonthlyReviewEngine.evaluate([answer]).single;

    expect(recommendation.type, RecommendationType.keep);
    expect(recommendation.monthlySaving, 0);
  });
}
