import 'staff_catalog.dart';
import 'staff_categories.dart';
import 'staff_store.dart';
import 'tracked_domain.dart';

final staffDomain = TrackedDomain(
  routeName: 'staff',
  nounKey: 'staff_member',
  analyticsCategoryKey: 'Staff',
  catalog: staffCatalog,
  categories: StaffCategories.values,
  store: StaffStore.instance,
);
