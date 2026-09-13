import 'package:flutter/material.dart';

import '../l10n/strings.dart';

/// A filterable category shared by the Subscriptions, Utilities, and Staff
/// pages. Each page defines its own fixed list of these (see
/// [SubscriptionCategories] etc.) so the filter chips and catalog can be
/// domain-specific while sharing one implementation.
class TrackedCategory {
  const TrackedCategory(this.key, this.icon);

  /// Stable English identifier (e.g. 'entertainment'), used to look up the
  /// localized [label] and never itself shown on screen.
  final String key;
  final IconData icon;

  /// Localized display text — re-evaluated on every read, so it always
  /// reflects the current app language.
  String get label => Strings.t('category_$key');
}
