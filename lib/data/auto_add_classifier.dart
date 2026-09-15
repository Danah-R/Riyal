import 'package:flutter/material.dart';

import 'people_categories.dart';
import 'recurring_detection.dart';
import 'subscription_catalog.dart';
import 'tracked_category.dart';
import 'utility_catalog.dart';

enum AutoAddDomain { subscription, utility, person }

/// Where an auto-add-eligible recurring charge belongs, decided purely by
/// matching its merchant name against the subscription/utility reference
/// catalogs — regardless of the raw `mock_transactions.category` tag the
/// charge happened to be seeded with. No catalog match means it's treated
/// as a person-to-person payment with its role left for the user to fill
/// in, per the auto-add classification rule.
///
/// This is a different (and deliberately stricter) resolution than
/// `_resolveVisual` in lib/screens/accounts_screen.dart, which the manual
/// "possible" suggestion flow still uses — that one trusts the
/// transaction's own category tag first and only falls back to catalog
/// matching for a picture. Auto-add has no user in the loop to correct a
/// wrong guess, so it only ever calls something a subscription or utility
/// when the catalog itself confirms it.
class AutoAddClassification {
  const AutoAddClassification({
    required this.domain,
    required this.category,
    this.logoAsset,
    this.icon,
    this.iconColor,
  });

  final AutoAddDomain domain;
  final TrackedCategory category;
  final String? logoAsset;
  final IconData? icon;
  final Color? iconColor;
}

AutoAddClassification classifyForAutoAdd(DetectedSubscription suggestion) {
  final merchant = suggestion.merchantName.toUpperCase();

  // Utility catalog is checked first: STC/Mobily/Zain appear in both
  // catalogs (a telecom's postpaid plan is arguably either), but a mock
  // charge literally named "ZAIN MOBILE BILL" or "STC INTERNET BILL" is
  // unambiguously a utility bill, not a subscription.
  for (final entry in utilityCatalog) {
    if (merchant.contains(entry.name.toUpperCase())) {
      return AutoAddClassification(
        domain: AutoAddDomain.utility,
        category: entry.category,
        logoAsset: suggestion.logoAsset ?? entry.logoAsset,
        icon: entry.icon,
        iconColor: entry.iconColor,
      );
    }
  }

  for (final app in subscriptionCatalog) {
    if (merchant.contains(app.name.toUpperCase())) {
      return AutoAddClassification(
        domain: AutoAddDomain.subscription,
        category: app.category,
        logoAsset: suggestion.logoAsset ?? app.logoAsset,
      );
    }
  }

  return AutoAddClassification(
    domain: AutoAddDomain.person,
    category: PeopleCategories.unassigned,
    logoAsset: suggestion.logoAsset,
  );
}
