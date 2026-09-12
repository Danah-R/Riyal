import 'package:flutter/material.dart';

import 'mock_charge.dart';
import 'utility_categories.dart';

const List<MockCharge> utilityMockCharges = [
  MockCharge(
    merchant: 'SEC ELECTRICITY BILL',
    amount: 150,
    daysAgo: 4,
    matchedName: 'Saudi Electricity Company',
    matchedIcon: Icons.bolt_outlined,
    matchedIconColor: Color(0xFFB8860B),
    matchedCategory: UtilityCategories.electricity,
  ),
  MockCharge(
    merchant: 'STC FIBER INTERNET',
    amount: 250,
    daysAgo: 10,
    matchedName: 'STC',
    matchedLogo: 'lib/assets/logos/stc.jpeg',
    matchedCategory: UtilityCategories.internet,
  ),
  MockCharge(
    merchant: 'NATIONAL WATER CO',
    amount: 70,
    daysAgo: 18,
    matchedName: 'National Water Company',
    matchedIcon: Icons.water_drop_outlined,
    matchedIconColor: Color(0xFF2B6CB0),
    matchedCategory: UtilityCategories.water,
  ),
  MockCharge(
    merchant: 'PANDA HYPERMARKET',
    amount: 96,
    daysAgo: 2,
  ),
];
