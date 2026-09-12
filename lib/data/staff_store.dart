import 'package:flutter/material.dart';

import 'staff_categories.dart';
import 'subscription.dart' show BillingCycle;
import 'tracked_item.dart';

class StaffStore {
  StaffStore._();

  static final TrackedItemsStore instance = TrackedItemsStore(_seed());

  static List<TrackedItem> _seed() {
    final now = DateTime.now();
    return [
      TrackedItem(
        name: 'Driver',
        icon: Icons.directions_car_outlined,
        iconColor: const Color(0xFF37474F),
        amount: 400,
        cycle: BillingCycle.monthly,
        nextBillingDate: now.add(const Duration(days: 10)),
        category: StaffCategories.driving,
      ),
      TrackedItem(
        name: 'Housekeeper',
        icon: Icons.cleaning_services_outlined,
        iconColor: const Color(0xFF6B7A3A),
        amount: 250,
        cycle: BillingCycle.monthly,
        nextBillingDate: now.add(const Duration(days: 18)),
        category: StaffCategories.household,
      ),
      TrackedItem(
        name: 'Nanny',
        icon: Icons.child_care_outlined,
        iconColor: const Color(0xFFC2637A),
        amount: 120,
        cycle: BillingCycle.monthly,
        nextBillingDate: now.add(const Duration(days: 22)),
        category: StaffCategories.childcare,
      ),
    ];
  }
}
