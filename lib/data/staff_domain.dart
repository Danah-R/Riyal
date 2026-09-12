import 'staff_catalog.dart';
import 'staff_categories.dart';
import 'staff_mock_charges.dart';
import 'staff_store.dart';
import 'tracked_domain.dart';

final staffDomain = TrackedDomain(
  routeName: 'staff',
  itemNounSingular: 'staff member',
  addFromScratchTitle: 'Choose a role',
  catalog: staffCatalog,
  categories: StaffCategories.values,
  store: StaffStore.instance,
  mockCharges: staffMockCharges,
);
