import 'package:flutter/material.dart';

import '../data/home_data.dart';
import '../data/subscription.dart';
import '../data/subscriptions_store.dart';
import '../theme/app_theme.dart';
import '../widgets/flipping_coin_icon.dart';
import '../widgets/logo_image.dart';
import 'analytics_screen.dart';

enum SpendingTab { subscriptions, utilities, staff }

/// The Home tab's content. Lives inside [MainShell]'s [IndexedStack], so it
/// has no Scaffold/bottom nav of its own — the shell provides those once for
/// all tabs. Tapping a category pill switches the shell's active tab instead
/// of pushing a new route.
class HomeBody extends StatefulWidget {
  const HomeBody({super.key, required this.onNavigateToTab});

  /// Called with the shell's tab index (1 = Subscriptions, 2 = Utilities,
  /// 3 = Staff) when a category pill is tapped.
  final ValueChanged<int> onNavigateToTab;

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  SpendingTab _tab = SpendingTab.subscriptions;

  void _selectTab(SpendingTab tab) {
    setState(() => _tab = tab);
    final index = switch (tab) {
      SpendingTab.subscriptions => 1,
      SpendingTab.utilities => 2,
      SpendingTab.staff => 3,
    };
    widget.onNavigateToTab(index);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 130),
        children: [
          _TopBar(),
          const SizedBox(height: 24),

          const SizedBox(height: 20),
          _TabSelector(selected: _tab, onChanged: _selectTab),
          const SizedBox(height: 16),
          const _SpendingCard(),
          const SizedBox(height: 28),
          _SectionHeader(
            title: 'Overview',
            onSeeAll: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const AnalyticsScreen()),
            ),
          ),
          const SizedBox(height: 14),
          const _OverviewBar(),
          const SizedBox(height: 16),
          const _OverviewStats(),
          const SizedBox(height: 28),
          _SectionHeader(
            title: 'Upcoming renewals',
            onSeeAll: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const AnalyticsScreen(category: 'Subscriptions'),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const _UpcomingRenewals(),
        ],
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
        const FlippingCoinIcon(),
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

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          tab('Subscriptions', SpendingTab.subscriptions),
          const SizedBox(width: 6),
          tab('Utilities', SpendingTab.utilities),
          const SizedBox(width: 6),
          tab('Staff', SpendingTab.staff),
        ],
      ),
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
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const AnalyticsScreen(category: 'Subscriptions'),
                  ),
                ),
                child: const Icon(Icons.chevron_right, color: AppColors.gold, size: 26),
              ),
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
            children: [
              Expanded(
                child: Text(
                  'of SAR ${subscriptionsBudget.toStringAsFixed(0)} budget',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 8),
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
  const _SectionHeader({required this.title, this.onSeeAll});

  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onSeeAll,
          child: const Text(
            'See all',
            style: TextStyle(
              color: AppColors.gold,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
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
                        Flexible(
                          child: Text(
                            'SAR ${c.amount.toStringAsFixed(0)}',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
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

class _UpcomingRenewals extends StatelessWidget {
  const _UpcomingRenewals();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Subscription>>(
      valueListenable: SubscriptionsStore.instance.subscriptions,
      builder: (context, subs, _) {
        if (subs.isEmpty) {
          return const Text(
            'No subscriptions yet.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          );
        }
        final upcoming = [...subs]
          ..sort((a, b) => a.renewsInDays.compareTo(b.renewsInDays));
        return Column(
          children: upcoming
              .take(5)
              .map(
                (s) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _RenewalTile(subscription: s),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _RenewalTile extends StatelessWidget {
  const _RenewalTile({required this.subscription});

  final Subscription subscription;

  @override
  Widget build(BuildContext context) {
    final s = subscription;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          LogoImage(assetPath: s.logoAsset, size: 44),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  s.renewsInDays <= 0
                      ? 'Renews today'
                      : 'Renews in ${s.renewsInDays} days',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'SAR ${s.amount.toStringAsFixed(0)}',
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
