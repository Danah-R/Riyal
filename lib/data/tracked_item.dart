import 'package:flutter/material.dart';

import 'subscription.dart' show BillingCycle;
import 'tracked_category.dart';

/// A recurring cost being tracked — a utility bill or a staff member's pay,
/// mirroring [Subscription]'s shape so the Utilities/Staff pages can reuse
/// the same UI as the Subscriptions page.
class TrackedItem {
  const TrackedItem({
    required this.name,
    required this.amount,
    required this.cycle,
    required this.nextBillingDate,
    required this.category,
    this.logoAsset,
    this.icon,
    this.iconColor,
  });

  final String name;
  final String? logoAsset;
  final IconData? icon;
  final Color? iconColor;
  final double amount;
  final BillingCycle cycle;
  final DateTime nextBillingDate;
  final TrackedCategory category;

  int get renewsInDays => nextBillingDate.difference(DateTime.now()).inDays;

  double get monthlyAmount => cycle == BillingCycle.monthly ? amount : amount / 12;
}

/// Holds the list of tracked items for one domain (Utilities, Staff, ...).
class TrackedItemsStore {
  TrackedItemsStore(List<TrackedItem> seed) : items = ValueNotifier(seed);

  final ValueNotifier<List<TrackedItem>> items;

  void add(TrackedItem item) {
    items.value = [...items.value, item];
  }
}
