import 'package:flutter/material.dart';

import '../data/people_domain.dart';
import 'tracked_items_screen.dart';

/// The People tab's content. Lives inside [MainShell]'s [IndexedStack] — no
/// Scaffold/bottom nav of its own. Same layout as [SubscriptionsBody],
/// backed by [peopleDomain] instead.
class PeopleBody extends StatelessWidget {
  const PeopleBody({super.key});

  @override
  Widget build(BuildContext context) {
    return TrackedItemsScreen(domain: peopleDomain);
  }
}
