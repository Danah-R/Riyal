import 'package:flutter/material.dart';

import '../data/subscription.dart';
import '../data/subscription_category.dart';
import '../data/subscriptions_store.dart';
import '../data/tracked_category.dart';
import '../l10n/strings.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';
import '../widgets/capsule_tab_selector.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/circle_icon_button.dart';
import '../widgets/inline_search_field.dart';
import '../widgets/logo_image.dart';
import 'add_subscription_sheet.dart';
import 'analytics_screen.dart';
import 'subscription_view_screen.dart';

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
  bool _searching = false;
  String _query = '';

  void _stopSearching() => setState(() {
    _searching = false;
    _query = '';
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_searching)
                  InlineSearchField(
                    autofocus: true,
                    hintText: Strings.t('search_hint_subscriptions'),
                    onChanged: (v) => setState(() => _query = v),
                    onClose: _stopSearching,
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: CapsuleTabSelector<_PageTab>(
                          options: [
                            CapsuleTabOption(
                              Strings.t('nav_subscriptions'),
                              _PageTab.subscriptions,
                            ),
                            CapsuleTabOption(
                              Strings.t('analytics_tab'),
                              _PageTab.analytics,
                            ),
                          ],
                          selected: _tab,
                          onChanged: (t) => setState(() => _tab = t),
                        ),
                      ),
                      if (_tab == _PageTab.subscriptions) ...[
                        const SizedBox(width: 12),
                        CircleIconButton(
                          icon: Icons.search_rounded,
                          onTap: () => setState(() => _searching = true),
                        ),
                      ],
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
                      ? _SubscriptionsList(category: _category, query: _query)
                      : const AnalyticsContent(
                          category: 'Subscriptions',
                          showCategoryPicker: false,
                          horizontalPadding: 0,
                          bottomPadding: 120,
                        ),
                ),
              ],
            ),
          ),
          if (_tab == _PageTab.subscriptions)
            Positioned(
              right: 20,
              bottom: 130,
              child: CircleIconButton(
                icon: Icons.add_rounded,
                background: AppColors.gold,
                iconColor: AppColors.goldForeground,
                size: 44,
                onTap: () => showAddSubscriptionSheet(context),
              ),
            ),
        ],
      ),
    );
  }
}

class _SubscriptionsList extends StatelessWidget {
  const _SubscriptionsList({this.category, this.query = ''});

  final TrackedCategory? category;
  final String query;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Subscription>>(
      valueListenable: SubscriptionsStore.instance.subscriptions,
      builder: (context, allSubs, _) {
        var subs = category == null
            ? allSubs
            : allSubs.where((s) => s.category == category).toList();
        if (query.trim().isNotEmpty) {
          subs = subs
              .where(
                (s) =>
                    s.name.toLowerCase().contains(query.trim().toLowerCase()),
              )
              .toList();
        }

        final subscriptionsNoun = Strings.t('nav_subscriptions').toLowerCase();
        if (allSubs.isEmpty) {
          return Center(
            child: Text(
              Strings.emptyDomainMessage(subscriptionsNoun),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          );
        }
        if (subs.isEmpty) {
          return Center(
            child: Text(
              query.trim().isNotEmpty
                  ? Strings.noMatchMessage(subscriptionsNoun, query)
                  : Strings.noCategoryMessage(
                      category!.label,
                      subscriptionsNoun,
                    ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.only(bottom: 190),
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
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => SubscriptionViewScreen(subscriptionId: s.id),
        ),
      ),
      child: Container(
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
                    Strings.renewsIn(s.renewsInDays),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '⃁${s.amount.toStringAsFixed(0)}',
              style: AppTypography.amount(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
