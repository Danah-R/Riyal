import 'package:flutter/material.dart';

import 'tracked_category.dart';

class StaffCategories {
  StaffCategories._();

  static const household =
      TrackedCategory('Household', Icons.cleaning_services_outlined);
  static const childcare = TrackedCategory('Childcare', Icons.child_care_outlined);
  static const driving = TrackedCategory('Driving', Icons.directions_car_outlined);
  static const security = TrackedCategory('Security', Icons.shield_outlined);
  static const other = TrackedCategory('Other', Icons.more_horiz_rounded);

  static const values = [household, childcare, driving, security, other];
}
