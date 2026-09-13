import 'package:flutter_test/flutter_test.dart';
import 'package:riyal/data/notifications_store.dart';
import 'package:riyal/data/subscription.dart';
import 'package:riyal/data/subscriptions_store.dart';
import 'package:riyal/data/staff_store.dart';
import 'package:riyal/data/utilities_store.dart';
import 'package:riyal/data/tracked_item.dart';
import 'package:riyal/data/staff_categories.dart';
import 'package:riyal/data/utility_categories.dart';

void main() {
  test(
    'Inbox reflects additions across domains and the five-day boundary without duplicates',
    () {
      final inbox = NotificationsStore.instance;
      final now = DateTime.now();
      final due5 = DateTime(now.year, now.month, now.day + 5, 23, 59);
      final due6 = DateTime(now.year, now.month, now.day + 6);
      final initial = inbox.notices.value.length;
      SubscriptionsStore.instance.add(
        Subscription(
          name: 'Boundary five',
          logoAsset: null,
          amount: 39,
          cycle: BillingCycle.monthly,
          nextBillingDate: due5,
        ),
      );
      expect(inbox.notices.value.length, initial + 2);
      SubscriptionsStore.instance.add(
        Subscription(
          name: 'Boundary six',
          logoAsset: null,
          amount: 50,
          cycle: BillingCycle.monthly,
          nextBillingDate: due6,
        ),
      );
      expect(inbox.notices.value.length, initial + 3);
      UtilitiesStore.instance.add(
        TrackedItem(
          name: 'Test utility',
          amount: 100,
          cycle: BillingCycle.monthly,
          nextBillingDate: due6,
          category: UtilityCategories.water,
        ),
      );
      StaffStore.instance.add(
        TrackedItem(
          name: 'Test staff',
          amount: 200,
          cycle: BillingCycle.monthly,
          nextBillingDate: due6,
          category: StaffCategories.household,
        ),
      );
      expect(inbox.notices.value.length, initial + 5);
      inbox.refresh();
      inbox.refresh();
      expect(inbox.notices.value.length, initial + 5);
      expect(
        inbox.notices.value.where(
          (n) => n.reminder && n.message.contains('Boundary six'),
        ),
        isEmpty,
      );
      final notices = inbox.notices.value;
      for (var i = 1; i < notices.length; i++) {
        expect(
          notices[i - 1].createdAt.isBefore(notices[i].createdAt),
          isFalse,
        );
      }
    },
  );
}
