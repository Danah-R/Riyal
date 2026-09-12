import 'package:flutter/material.dart';

import '../data/subscription.dart';
import '../data/subscription_category.dart';
import '../data/subscriptions_store.dart';
import '../data/tracked_category.dart';
import '../theme/app_theme.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/logo_image.dart';
import 'add_subscription_sheet.dart';

enum _PageTab { subscriptions, analytics }

/// The Subscriptions tab's content. Lives inside [MainShell]'s
/// [IndexedStack] — no Scaffold/bottom nav of its own.
class SubscriptionsBody extends StatefulWidget {
  const SubscriptionsBody({super.key});

  @override
  State<SubscriptionsBody> createState() => _SubscriptionsBodyState();
}

class _SubscriptionsBodyState extends State<SubscriptionsBody> {
  _PageTab _tab = _PageTab.subscriptions;
  TrackedCategory? _category;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _TopTabs(
                    selected: _tab,
                    onChanged: (t) => setState(() => _tab = t),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => showAddSubscriptionSheet(context),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: AppColors.gold,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add_rounded,
                        color: Color(0xFF1B1F16), size: 26),
                  ),
                ),
              ],
            ),
            if (_tab == _PageTab.subscriptions) ...[
              const SizedBox(height: 16),
              CategoryFilterBar(
                categories: SubscriptionCategories.values,
                selected: _category,
                onChanged: (c) => setState(() => _category = c),
              ),
            ],
            const SizedBox(height: 16),
            Expanded(
              child: _tab == _PageTab.subscriptions
                  ? _SubscriptionsList(category: _category)
                  : const _AnalyticsPlaceholder(),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopTabs extends StatelessWidget {
  const _TopTabs({required this.selected, required this.onChanged});

  final _PageTab selected;
  final ValueChanged<_PageTab> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget tab(String label, _PageTab value) {
      final isSelected = selected == value;
      return GestureDetector(
        onTap: () => onChanged(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.gold : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF1B1F16) : AppColors.textSecondary,
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
          tab('Subscriptions', _PageTab.subscriptions),
          const SizedBox(width: 6),
          tab('Analytics', _PageTab.analytics),
        ],
      ),
    );
  }
}

class _SubscriptionsList extends StatelessWidget {
  const _SubscriptionsList({this.category});

  final TrackedCategory? category;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Subscription>>(
      valueListenable: SubscriptionsStore.instance.subscriptions,
      builder: (context, allSubs, _) {
        final subs = category == null
            ? allSubs
            : allSubs.where((s) => s.category == category).toList();

        if (allSubs.isEmpty) {
          return const Center(
            child: Text(
              'No subscriptions yet.\nTap + to add one.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          );
        }
        if (subs.isEmpty) {
          return Center(
            child: Text(
              'No ${category!.label.toLowerCase()} subscriptions yet.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.only(bottom: 130),
          itemCount: subs.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, i) => _SubscriptionTile(subscription: subs[i]),
        );
      },
    );
  }
}

class _SubscriptionTile extends StatelessWidget {
  const _SubscriptionTile({required this.subscription});

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
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
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
        ],
      ),
    );
  }
}

class _AnalyticsPlaceholder extends StatelessWidget {
  const _AnalyticsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Subscription>>(
      valueListenable: SubscriptionsStore.instance.subscriptions,
      builder: (context, subs, _) {
        final total = subs.fold<double>(0, (sum, s) => sum + s.monthlyAmount);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
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
                    'Estimated monthly total',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'SAR ${total.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'across ${subs.length} subscription${subs.length == 1 ? '' : 's'}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Expanded(
              child: Center(
                child: Text(
                  'Detailed spending breakdown\ncoming soon.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
