import 'package:flutter/material.dart';

import 'tracked_category.dart';

class SubscriptionCategories {
  SubscriptionCategories._();

  static const entertainment = TrackedCategory('Entertainment', Icons.movie_outlined);
  static const ai = TrackedCategory('AI', Icons.smart_toy_outlined);
  static const productivity =
      TrackedCategory('Productivity', Icons.work_outline_rounded);
  static const cloudStorage = TrackedCategory('Cloud & Storage', Icons.cloud_outlined);
  static const fitnessWellness =
      TrackedCategory('Fitness & Wellness', Icons.fitness_center_rounded);
  static const education = TrackedCategory('Education', Icons.school_outlined);
  static const shoppingDelivery =
      TrackedCategory('Shopping & Delivery', Icons.local_shipping_outlined);
  static const other = TrackedCategory('Other', Icons.more_horiz_rounded);

  static const values = [
    entertainment,
    ai,
    productivity,
    cloudStorage,
    fitnessWellness,
    education,
    shoppingDelivery,
    other,
  ];
}
