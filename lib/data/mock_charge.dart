import 'package:flutter/material.dart';

import 'tracked_category.dart';

/// A mock recent transaction offered in the "from a previous transaction"
/// add flow for Utilities/Staff, mirroring [MockTransaction].
class MockCharge {
  const MockCharge({
    required this.merchant,
    required this.amount,
    required this.daysAgo,
    this.matchedName,
    this.matchedLogo,
    this.matchedIcon,
    this.matchedIconColor,
    this.matchedCategory,
  });

  final String merchant;
  final double amount;
  final int daysAgo;
  final String? matchedName;
  final String? matchedLogo;
  final IconData? matchedIcon;
  final Color? matchedIconColor;
  final TrackedCategory? matchedCategory;
}
