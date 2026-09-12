import 'mock_charge.dart';
import 'utility_categories.dart';

const List<MockCharge> utilityMockCharges = [
  MockCharge(
    merchant: 'SEC ELECTRICITY BILL',
    amount: 150,
    daysAgo: 4,
    matchedName: 'Saudi Electricity Company',
    matchedLogo: 'lib/assets/logos/1696007538-89-saudi-electricity-company.jpg',
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
    matchedLogo: 'lib/assets/logos/saudi water comp.png',
    matchedCategory: UtilityCategories.water,
  ),
  MockCharge(
    merchant: 'PANDA HYPERMARKET',
    amount: 96,
    daysAgo: 2,
  ),
];
