import 'package:flutter/foundation.dart';
import 'subscriptions_store.dart';
import 'utilities_store.dart';
import 'staff_store.dart';

class PaymentNotice {
  const PaymentNotice({
    required this.title,
    required this.message,
    required this.createdAt,
    required this.reminder,
  });
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
      final formattedDate = '${date.day}/${date.month}/${date.year}';
      if (_seen.add(identity)) {
        additions.add(
          PaymentNotice(
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
    }
  }
}
