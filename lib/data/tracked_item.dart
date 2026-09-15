import 'package:flutter/material.dart';

import 'item_status.dart';
import 'subscription.dart' show BillingCycle;
import 'tracked_category.dart';

/// A recurring cost being tracked — a utility bill or a person's pay,
/// mirroring [Subscription]'s shape so the Utilities/People pages can reuse
/// the same UI as the Subscriptions page.
class TrackedItem {
  const TrackedItem({
    required this.id,
    required this.name,
    required this.amount,
    required this.cycle,
    required this.nextBillingDate,
    required this.category,
    this.logoAsset,
    this.icon,
    this.iconColor,
    this.status = ItemStatus.active,
    this.notes,
    this.pausedUntil,
    this.notificationsEnabled = true,
  });

  final String id;
  final String name;
  final String? logoAsset;
  final IconData? icon;
  final Color? iconColor;
  final double amount;
  final BillingCycle cycle;
  final DateTime nextBillingDate;
  final TrackedCategory category;
  final ItemStatus status;

  /// Free-text notes — surfaced on the People details page; harmless
  /// and simply unused for Utilities, which don't render it.
  final String? notes;

  /// When set (and still in the future), this person's allowance/pay is
  /// paused until this date — the People details page's pause
  /// scheduling control reads and writes this.
  final DateTime? pausedUntil;
  final bool notificationsEnabled;

  int get renewsInDays => nextBillingDate.difference(DateTime.now()).inDays;

  double get monthlyAmount =>
      cycle == BillingCycle.monthly ? amount : amount / 12;

  TrackedItem copyWith({
    double? amount,
    BillingCycle? cycle,
    DateTime? nextBillingDate,
    TrackedCategory? category,
    ItemStatus? status,
    String? notes,
    bool clearNotes = false,
    DateTime? pausedUntil,
    bool clearPausedUntil = false,
    bool? notificationsEnabled,
  }) => TrackedItem(
    id: id,
    name: name,
    logoAsset: logoAsset,
    icon: icon,
    iconColor: iconColor,
    amount: amount ?? this.amount,
    cycle: cycle ?? this.cycle,
    nextBillingDate: nextBillingDate ?? this.nextBillingDate,
    category: category ?? this.category,
    status: status ?? this.status,
    notes: clearNotes ? null : (notes ?? this.notes),
    pausedUntil: clearPausedUntil ? null : (pausedUntil ?? this.pausedUntil),
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
  );
}

/// Holds the list of tracked items for one domain (Utilities, People, ...).
class TrackedItemsStore {
  TrackedItemsStore(List<TrackedItem> seed) : items = ValueNotifier(seed);

  final ValueNotifier<List<TrackedItem>> items;

  void add(TrackedItem item) {
    items.value = [...items.value, item];
  }

  void update(TrackedItem item) {
    items.value = [
      for (final existing in items.value)
        if (existing.id == item.id) item else existing,
    ];
  }

  void remove(String id) {
    items.value = items.value.where((item) => item.id != id).toList();
  }
}
