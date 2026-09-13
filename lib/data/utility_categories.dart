import 'package:flutter/material.dart';

import 'tracked_category.dart';

class UtilityCategories {
  UtilityCategories._();

  static const electricity = TrackedCategory(
    'electricity',
    Icons.bolt_outlined,
  );
  static const water = TrackedCategory('water', Icons.water_drop_outlined);
  static const internet = TrackedCategory('internet', Icons.wifi_rounded);
  static const mobile = TrackedCategory('mobile', Icons.smartphone_outlined);
  static const gas = TrackedCategory(
    'gas',
    Icons.local_fire_department_outlined,
  );
  static const other = TrackedCategory('other', Icons.more_horiz_rounded);

  static const values = [electricity, water, internet, mobile, gas, other];
}
