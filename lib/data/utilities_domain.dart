import 'tracked_domain.dart';
import 'utilities_store.dart';
import 'utility_catalog.dart';
import 'utility_categories.dart';
import 'utility_mock_charges.dart';

final utilitiesDomain = TrackedDomain(
  routeName: 'utilities',
  itemNounSingular: 'utility bill',
  addFromScratchTitle: 'Choose a provider',
  catalog: utilityCatalog,
  categories: UtilityCategories.values,
  store: UtilitiesStore.instance,
  mockCharges: utilityMockCharges,
);
