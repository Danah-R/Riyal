import 'catalog_entry.dart';
import 'mock_charge.dart';
import 'tracked_category.dart';
import 'tracked_item.dart';

/// Everything a page needs to reuse the generic Subscriptions-style UI for
/// a different domain (Utilities, Staff, ...): its catalog, categories,
/// store, and mock "recent charges".
class TrackedDomain {
  const TrackedDomain({
    required this.routeName,
    required this.itemNounSingular,
    required this.addFromScratchTitle,
    required this.catalog,
    required this.categories,
    required this.store,
    required this.mockCharges,
  });

  /// Used to pop the add-flow back to this domain's root screen.
  final String routeName;

  /// e.g. "utility bill" / "staff member" — used in empty-state copy.
  final String itemNounSingular;

  /// e.g. "Choose a provider" / "Choose a role".
  final String addFromScratchTitle;

  final List<CatalogEntry> catalog;
  final List<TrackedCategory> categories;
  final TrackedItemsStore store;
  final List<MockCharge> mockCharges;
}
