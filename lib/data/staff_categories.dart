import 'package:flutter/material.dart';

import 'tracked_category.dart';

class StaffCategories {
  StaffCategories._();

  static const household = TrackedCategory(
    'household',
    Icons.cleaning_services_outlined,
  );
  static const childcare = TrackedCategory(
    'childcare',
    Icons.child_care_outlined,
  );
  static const driving = TrackedCategory(
    'driving',
    Icons.directions_car_outlined,
  );
  static const security = TrackedCategory('security', Icons.shield_outlined);
  static const other = TrackedCategory('other', Icons.more_horiz_rounded);

  static const values = [household, childcare, driving, security, other];
}
