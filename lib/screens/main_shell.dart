import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'bottom_nav.dart';
import 'home_screen.dart';
import 'staff_screen.dart';
import 'subscriptions_screen.dart';
import 'utilities_screen.dart';
import 'riyal_bot_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  void _goToTab(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: IndexedStack(
        index: _index,
        children: [
          const HomeBody(),
          const SubscriptionsBody(),
          const UtilitiesBody(),
          const StaffBody(),
        ],
      ),
      floatingActionButton: NavFab(
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const RiyalBotScreen())),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNav(index: _index, onTap: _goToTab),
    );
  }
}
