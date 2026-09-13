import 'package:flutter/foundation.dart';
import 'subscriptions_store.dart';
import 'utilities_store.dart';
import 'staff_store.dart';
import 'notice_read_state.dart';
import 'dart:convert';

class PaymentNotice {
  const PaymentNotice({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.reminder,
  });
  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool reminder;
}

/// In-app demo inbox, fed by the same observable stores as the payment screens.
class NotificationsStore {
  NotificationsStore._() {
    refresh(seed: true);
    SubscriptionsStore.instance.subscriptions.addListener(refresh);
    UtilitiesStore.instance.items.addListener(refresh);
    StaffStore.instance.items.addListener(refresh);
  }
  static final instance = NotificationsStore._();
  final notices = ValueNotifier<List<PaymentNotice>>([]);
  final readState = NoticeReadState();
  final Map<Object, String> _itemIds = Map.identity();
  final Set<Object> _seen = Set.identity();
  final Map<Object, Set<DateTime>> _reminded = Map.identity();

  void refresh({bool seed = false}) {
    final now = DateTime.now();
    final additions = <PaymentNotice>[];
    void visit(
      Object identity,
      String name,
      String category,
      double amount,
      DateTime due,
    ) {
      final date = DateTime(due.year, due.month, due.day);
      final itemId = _itemIds.putIfAbsent(
        identity,
        () => jsonEncode([
          seed
              ? 'demo'
              : 'added-${now.microsecondsSinceEpoch}-${_itemIds.length}',
          category,
          name,
          amount,
        ]),
      );
      final formattedDate = '${date.day}/${date.month}/${date.year}';
      if (_seen.add(identity)) {
        additions.add(
          PaymentNotice(
            id: 'added:$itemId',
            title: category == 'Subscriptions'
                ? 'New subscription'
                : 'New payment commitment',
            message:
                '$name · $category\nSAR ${amount.toStringAsFixed(2)} · Next payment $formattedDate',
            createdAt: seed
                ? now.subtract(Duration(days: 7, seconds: _seen.length))
                : now,
            reminder: false,
          ),
        );
      }
      // Calendar subtraction avoids truncating 5 days to 4 due to time of day.
      final reminderDate = DateTime(date.year, date.month, date.day - 5);
      if (!reminderDate.isAfter(now) &&
          (_reminded[identity] ??= {}).add(date)) {
        additions.add(
          PaymentNotice(
            id: 'reminder:$itemId:${itemId.contains('"demo"') ? 'seed' : date.toIso8601String()}',
            title: category == 'Subscriptions'
                ? 'Subscription renewal reminder'
                : 'Payment reminder',
            message:
                '$name · $category\nSAR ${amount.toStringAsFixed(2)} due $formattedDate\nReminder: 5 days before payment.',
            createdAt: reminderDate,
            reminder: true,
          ),
        );
      }
    }

    for (final item in SubscriptionsStore.instance.subscriptions.value) {
      visit(
        item,
        item.name,
        'Subscriptions',
        item.amount,
        item.nextBillingDate,
      );
    }
    for (final item in UtilitiesStore.instance.items.value) {
      visit(item, item.name, 'Utilities', item.amount, item.nextBillingDate);
    }
    for (final item in StaffStore.instance.items.value) {
      visit(item, item.name, 'Staff', item.amount, item.nextBillingDate);
    }
    if (additions.isNotEmpty) {
      notices.value = [...notices.value, ...additions]
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      readState.updateIds(notices.value.map((notice) => notice.id));
    }
  }
}
