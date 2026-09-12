import 'package:flutter/material.dart';

import '../data/staff_domain.dart';
import 'tracked_items_screen.dart';

/// The Staff tab's content. Lives inside [MainShell]'s [IndexedStack] — no
/// Scaffold/bottom nav of its own. Same layout as [SubscriptionsBody],
/// backed by [staffDomain] instead.
class StaffBody extends StatelessWidget {
  const StaffBody({super.key});

  @override
  Widget build(BuildContext context) {
    return TrackedItemsScreen(title: 'Staff', domain: staffDomain);
  }
}
