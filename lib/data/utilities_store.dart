import 'package:flutter/material.dart';

import 'subscription.dart' show BillingCycle;
import 'tracked_item.dart';
import 'utility_categories.dart';

class UtilitiesStore {
  UtilitiesStore._();

  static final TrackedItemsStore instance = TrackedItemsStore(_seed());

  static List<TrackedItem> _seed() {
    final now = DateTime.now();
    return [
      TrackedItem(
        name: 'Saudi Electricity Company',
        logoAsset: 'lib/assets/logos/1696007538-89-saudi-electricity-company.jpg',
        amount: 150,
        cycle: BillingCycle.monthly,
        nextBillingDate: now.add(const Duration(days: 5)),
        category: UtilityCategories.electricity,
      ),
      TrackedItem(
        name: 'STC',
        logoAsset: 'lib/assets/logos/stc.jpeg',
        amount: 250,
        cycle: BillingCycle.monthly,
        nextBillingDate: now.add(const Duration(days: 15)),
        category: UtilityCategories.internet,
      ),
      TrackedItem(
        name: 'National Water Company',
        icon: Icons.water_drop_outlined,
        iconColor: const Color(0xFF2B6CB0),
        amount: 70,
        cycle: BillingCycle.monthly,
        nextBillingDate: now.add(const Duration(days: 20)),
        category: UtilityCategories.water,
      ),
      TrackedItem(
        name: 'Zain',
        logoAsset: 'lib/assets/logos/zain.png',
        amount: 150,
        cycle: BillingCycle.monthly,
        nextBillingDate: now.add(const Duration(days: 25)),
        category: UtilityCategories.mobile,
      ),
    ];
  }
}
