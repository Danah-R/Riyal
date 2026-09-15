import 'item_status.dart';
import 'subscription_category.dart';
import 'tracked_category.dart';

enum BillingCycle { monthly, yearly }

class Subscription {
  const Subscription({
    required this.id,
    required this.name,
    required this.logoAsset,
    required this.amount,
    required this.cycle,
    required this.nextBillingDate,
    this.category = SubscriptionCategories.other,
    this.status = ItemStatus.active,
    this.purposeTag,
    this.reminderDate,
    this.notificationsEnabled = true,
  });

  final String id;
  final String name;
  final String? logoAsset;
  final double amount;
  final BillingCycle cycle;
  final DateTime nextBillingDate;
  final TrackedCategory category;
  final ItemStatus status;

  /// Free-text note on why this subscription exists or how long it's meant
  /// to last (e.g. "Shared with family", "Cancel after the trip") — shown
  /// on the details page; optional.
  final String? purposeTag;

  /// A user-set date to revisit this subscription, independent of the
  /// automatic renewal reminder (e.g. "check before the trial ends").
  final DateTime? reminderDate;
  final bool notificationsEnabled;

  int get renewsInDays => nextBillingDate.difference(DateTime.now()).inDays;

  double get monthlyAmount =>
      cycle == BillingCycle.monthly ? amount : amount / 12;

  Subscription copyWith({
    double? amount,
    BillingCycle? cycle,
    DateTime? nextBillingDate,
    TrackedCategory? category,
    ItemStatus? status,
    String? purposeTag,
    bool clearPurposeTag = false,
    DateTime? reminderDate,
    bool clearReminderDate = false,
    bool? notificationsEnabled,
  }) => Subscription(
    id: id,
    name: name,
    logoAsset: logoAsset,
    amount: amount ?? this.amount,
    cycle: cycle ?? this.cycle,
    nextBillingDate: nextBillingDate ?? this.nextBillingDate,
    category: category ?? this.category,
    status: status ?? this.status,
    purposeTag: clearPurposeTag ? null : (purposeTag ?? this.purposeTag),
    reminderDate: clearReminderDate
        ? null
        : (reminderDate ?? this.reminderDate),
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
  );
}
