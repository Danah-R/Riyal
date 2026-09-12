import 'package:flutter/material.dart';

/// A filterable category shared by the Subscriptions, Utilities, and Staff
/// pages. Each page defines its own fixed list of these (see
/// [SubscriptionCategories] etc.) so the filter chips and catalog can be
/// domain-specific while sharing one implementation.
class TrackedCategory {
  const TrackedCategory(this.label, this.icon);

  final String label;
  final IconData icon;
}
