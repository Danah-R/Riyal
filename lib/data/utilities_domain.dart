import 'tracked_domain.dart';
import 'utilities_store.dart';
import 'utility_catalog.dart';
import 'utility_categories.dart';
import 'utility_mock_charges.dart';

final utilitiesDomain = TrackedDomain(
  routeName: 'utilities',
  nounKey: 'utility_bill',
  analyticsCategoryKey: 'Utilities',
  catalog: utilityCatalog,
  categories: UtilityCategories.values,
  store: UtilitiesStore.instance,
  mockCharges: utilityMockCharges,
  mockTransactionCategory: 'utility',
);
