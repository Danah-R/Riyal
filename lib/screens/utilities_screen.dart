import 'package:flutter/material.dart';

import '../data/utilities_domain.dart';
import 'tracked_items_screen.dart';

/// The Utilities tab's content. Lives inside [MainShell]'s [IndexedStack] —
/// no Scaffold/bottom nav of its own. Same layout as [SubscriptionsBody],
/// backed by [utilitiesDomain] instead.
class UtilitiesBody extends StatelessWidget {
  const UtilitiesBody({super.key});

  @override
  Widget build(BuildContext context) {
    return TrackedItemsScreen(domain: utilitiesDomain);
  }
}
