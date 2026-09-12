import 'package:flutter/material.dart';

import '../data/home_data.dart';
import '../theme/app_theme.dart';
import '../widgets/app_icon.dart';
import 'bottom_nav.dart';
import 'subscriptions_srcreen.dart';
import 'utilities_screen.dart';
import 'staff_screen.dart';
import 'analytics_screen.dart';

enum SpendingTab { subscriptions, utilities, staff }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  SpendingTab _tab = SpendingTab.subscriptions;
  int _navIndex = 0;

  void _openCategory(SpendingTab tab) {
    setState(() => _tab = tab);
    final Widget screen = switch (tab) {
      SpendingTab.subscriptions => const SubscriptionsScreen(),
      SpendingTab.utilities => const UtilitiesScreen(),
      SpendingTab.staff => const StaffScreen(),
    };
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            _TopBar(),
            const SizedBox(height: 24),

            const SizedBox(height: 20),
            _TabSelector(selected: _tab, onChanged: _openCategory),
            const SizedBox(height: 16),
            const _SpendingCard(),
            const SizedBox(height: 28),
            const _SectionHeader(title: 'Overview'),
            const SizedBox(height: 14),
            const _OverviewBar(),
            const SizedBox(height: 16),
            const _OverviewStats(),
            const SizedBox(height: 28),
            const _SectionHeader(title: 'Upcoming renewals'),
            const SizedBox(height: 14),
            ...upcomingRenewals.map(
              (r) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _RenewalTile(renewal: r),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: const NavFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNav(
        index: _navIndex,
        onTap: (i) {
          if (i == 2) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const AnalyticsScreen()),
            );
          } else {
            setState(() => _navIndex = i);
          }
        },
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.gold, width: 1.4),
          ),
          child: const AppIcon(
            assetPath: 'assets/icons/app_logo.svg',
            size: 26,
          ),
        ),
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surface,
          ),
          child: const Icon(
            Icons.notifications_none_rounded,
            color: AppColors.textPrimary,
            size: 22,
          ),
        ),
      ],
    );
  }
}

class _TabSelector extends StatelessWidget {
  const _TabSelector({required this.selected, required this.onChanged});

  final SpendingTab selected;
  final ValueChanged<SpendingTab> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget tab(String label, SpendingTab value) {
      final isSelected = selected == value;
      return GestureDetector(
        onTap: () => onChanged(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.gold : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? const Color(0xFF1B1F16)
                  : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        tab('Subscriptions', SpendingTab.subscriptions),
        const SizedBox(width: 6),
        tab('Utilities', SpendingTab.utilities),
        const SizedBox(width: 6),
        tab('Staff', SpendingTab.staff),
      ],
    );
  }
}

class _SpendingCard extends StatelessWidget {
  const _SpendingCard();

  @override
  Widget build(BuildContext context) {
    final progress = (subscriptionsSpent / subscriptionsBudget).clamp(0.0, 1.0);
    final left = subscriptionsBudget - subscriptionsSpent;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "This month's spending\non subscriptions",
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SAR ${subscriptionsSpent.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.gold, size: 26),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.trackBackground,
              valueColor: const AlwaysStoppedAnimation(AppColors.gold),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'of SAR ${subscriptionsBudget.toStringAsFixed(0)} budget',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              Text(
                'SAR ${left.toStringAsFixed(0)} left',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Text(
          'See all',
          style: TextStyle(
            color: AppColors.gold,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _OverviewBar extends StatelessWidget {
  const _OverviewBar();

  @override
  Widget build(BuildContext context) {
    final total = overview.fold<double>(0, (sum, c) => sum + c.amount);
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 14,
        child: Row(
          children: overview
              .map(
                (c) => Expanded(
                  flex: (c.amount / total * 1000).round(),
                  child: Container(color: Color(c.color)),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _OverviewStats extends StatelessWidget {
  const _OverviewStats();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: overview
          .map(
            (c) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Color(c.color),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'SAR ${c.amount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      c.label,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _RenewalTile extends StatelessWidget {
  const _RenewalTile({required this.renewal});

  final Renewal renewal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          AppIcon(assetPath: renewal.iconAsset, size: 44),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  renewal.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Renews in ${renewal.renewsInDays} days',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'SAR ${renewal.amount.toStringAsFixed(0)}',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: AppColors.trackBackground,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.gold,
              size: 17,
            ),
          ),
        ],
      ),
    );
  }
}
