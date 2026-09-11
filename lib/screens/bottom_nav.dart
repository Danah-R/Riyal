import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/app_icon.dart';

class BottomNav extends StatelessWidget {
  const BottomNav({super.key, required this.index, required this.onTap});

  final int index;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              NavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                isActive: index == 0,
                onTap: () => onTap(0),
              ),
              NavItem(
                icon: Icons.payments_outlined,
                label: 'Payments',
                isActive: index == 1,
                onTap: () => onTap(1),
              ),
              const SizedBox(width: 56),
              NavItem(
                icon: Icons.bar_chart_rounded,
                label: 'Analytics',
                isActive: index == 2,
                onTap: () => onTap(2),
              ),
              NavItem(
                icon: Icons.person_outline_rounded,
                label: 'Profile',
                isActive: index == 3,
                onTap: () => onTap(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NavItem extends StatelessWidget {
  const NavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.gold : AppColors.textSecondary;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontSize: 11)),
        ],
      ),
    );
  }
}

class NavFab extends StatelessWidget {
  const NavFab({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.gold,
        shape: BoxShape.circle,
      ),
      child: const AppIcon(assetPath: 'assets/icons/app_logo.svg', size: 30),
    );
  }
}
