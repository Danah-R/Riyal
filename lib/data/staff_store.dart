import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'id_generator.dart';
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
        id: IdGenerator.uuidV4(),
        name: 'Driver',
        icon: Icons.directions_car_outlined,
        iconColor: AppColors.staffDriving,
        amount: 400,
        cycle: BillingCycle.monthly,
        nextBillingDate: now.add(const Duration(days: 10)),
        category: StaffCategories.driving,
      ),
      TrackedItem(
        id: IdGenerator.uuidV4(),
        name: 'Housekeeper',
        icon: Icons.cleaning_services_outlined,
        iconColor: AppColors.staffHousekeeping,
        amount: 250,
        cycle: BillingCycle.monthly,
        nextBillingDate: now.add(const Duration(days: 18)),
        category: StaffCategories.household,
      ),
      TrackedItem(
        id: IdGenerator.uuidV4(),
        name: 'Nanny',
        icon: Icons.child_care_outlined,
        iconColor: AppColors.staffChildcare,
        amount: 120,
        cycle: BillingCycle.monthly,
        nextBillingDate: now.add(const Duration(days: 22)),
        category: StaffCategories.childcare,
      ),
    ];
  }
}
