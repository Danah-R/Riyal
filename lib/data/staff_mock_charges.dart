import 'package:flutter/material.dart';

import 'mock_charge.dart';
import 'staff_categories.dart';

const List<MockCharge> staffMockCharges = [
  MockCharge(
    merchant: 'BANK TRANSFER - DRIVER SALARY',
    amount: 400,
    daysAgo: 25,
    matchedName: 'Driver',
    matchedIcon: Icons.directions_car_outlined,
    matchedIconColor: Color(0xFF37474F),
    matchedCategory: StaffCategories.driving,
  ),
  MockCharge(
    merchant: 'BANK TRANSFER - HOUSEKEEPER',
    amount: 250,
    daysAgo: 20,
    matchedName: 'Housekeeper',
    matchedIcon: Icons.cleaning_services_outlined,
    matchedIconColor: Color(0xFF6B7A3A),
    matchedCategory: StaffCategories.household,
  ),
  MockCharge(merchant: 'ATM WITHDRAWAL', amount: 500, daysAgo: 3),
];
