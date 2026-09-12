import 'package:flutter/material.dart';

import 'tracked_category.dart';

class UtilityCategories {
  UtilityCategories._();

  static const electricity = TrackedCategory('Electricity', Icons.bolt_outlined);
  static const water = TrackedCategory('Water', Icons.water_drop_outlined);
  static const internet = TrackedCategory('Internet', Icons.wifi_rounded);
  static const mobile = TrackedCategory('Mobile', Icons.smartphone_outlined);
  static const gas = TrackedCategory('Gas', Icons.local_fire_department_outlined);
  static const other = TrackedCategory('Other', Icons.more_horiz_rounded);

  static const values = [electricity, water, internet, mobile, gas, other];
}
