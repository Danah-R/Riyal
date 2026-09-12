import 'subscription_category.dart';
import 'tracked_category.dart';

enum BillingCycle { monthly, yearly }

class Subscription {
  const Subscription({
    required this.name,
    required this.logoAsset,
    required this.amount,
    required this.cycle,
    required this.nextBillingDate,
    this.category = SubscriptionCategories.other,
  });

  final String name;
  final String? logoAsset;
  final double amount;
  final BillingCycle cycle;
  final DateTime nextBillingDate;
  final TrackedCategory category;

  int get renewsInDays => nextBillingDate.difference(DateTime.now()).inDays;

  double get monthlyAmount => cycle == BillingCycle.monthly ? amount : amount / 12;
}
