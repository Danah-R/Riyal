import 'people_catalog.dart';
import 'people_categories.dart';
import 'people_store.dart';
import 'tracked_domain.dart';

final peopleDomain = TrackedDomain(
  routeName: 'people',
  nounKey: 'people_member',
  analyticsCategoryKey: 'People',
  catalog: peopleCatalog,
  categories: PeopleCategories.values,
  store: PeopleStore.instance,
);
