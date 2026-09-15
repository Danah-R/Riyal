import 'package:flutter/material.dart';

import '../data/tracked_category.dart';
import '../data/tracked_domain.dart';
import '../data/tracked_item.dart';
import '../l10n/strings.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';
import '../widgets/capsule_tab_selector.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/circle_icon_button.dart';
import '../widgets/inline_search_field.dart';
import '../widgets/logo_image.dart';
import 'add_tracked_item_sheet.dart';
import 'analytics_screen.dart';
import 'tracked_item_view_screen.dart';

enum _PageTab { items, analytics }

/// The Utilities/Staff tabs' content — same layout as the Subscriptions
/// page ([SubscriptionsBody]), driven by a [TrackedDomain] instead.
class TrackedItemsScreen extends StatefulWidget {
  const TrackedItemsScreen({super.key, required this.domain});

  final TrackedDomain domain;

  @override
  State<TrackedItemsScreen> createState() => _TrackedItemsScreenState();
}

class _TrackedItemsScreenState extends State<TrackedItemsScreen> {
  _PageTab _tab = _PageTab.items;
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
                    hintText: widget.domain.searchHint,
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
                              widget.domain.displayTitle,
                              _PageTab.items,
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
                      if (_tab == _PageTab.items) ...[
                        const SizedBox(width: 12),
                        CircleIconButton(
                          icon: Icons.search_rounded,
                          onTap: () => setState(() => _searching = true),
                        ),
                      ],
                    ],
                  ),
                if (_tab == _PageTab.items) ...[
                  const SizedBox(height: 16),
                  CategoryFilterBar(
                    categories: widget.domain.categories,
                    selected: _category,
                    onChanged: (c) => setState(() => _category = c),
                  ),
                ],
                const SizedBox(height: 16),
                Expanded(
                  child: _tab == _PageTab.items
                      ? _TrackedItemsList(
                          domain: widget.domain,
                          category: _category,
                          query: _query,
                        )
                      : AnalyticsContent(
                          category: widget.domain.analyticsCategoryKey,
                          showCategoryPicker: false,
                          horizontalPadding: 0,
                          bottomPadding: 120,
                        ),
                ),
              ],
            ),
          ),
          if (_tab == _PageTab.items)
            Positioned(
              right: 20,
              bottom: 130,
              child: CircleIconButton(
                icon: Icons.add_rounded,
                background: AppColors.gold,
                iconColor: AppColors.goldForeground,
                size: 44,
                onTap: () => showAddTrackedItemSheet(context, widget.domain),
              ),
            ),
        ],
      ),
    );
  }
}

class _TrackedItemsList extends StatelessWidget {
  const _TrackedItemsList({
    required this.domain,
    this.category,
    this.query = '',
  });

  final TrackedDomain domain;
  final TrackedCategory? category;
  final String query;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<TrackedItem>>(
      valueListenable: domain.store.items,
      builder: (context, allItems, _) {
        var items = category == null
            ? allItems
            : allItems.where((s) => s.category == category).toList();
        if (query.trim().isNotEmpty) {
          items = items
              .where(
                (s) =>
                    s.name.toLowerCase().contains(query.trim().toLowerCase()),
              )
              .toList();
        }

        if (allItems.isEmpty) {
          return Center(
            child: Text(
              Strings.emptyDomainMessage(domain.itemNounPlural),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          );
        }
        if (items.isEmpty) {
          return Center(
            child: Text(
              query.trim().isNotEmpty
                  ? Strings.noMatchMessage(domain.itemNounPlural, query)
                  : Strings.noCategoryMessage(
                      category!.label,
                      domain.itemNounPlural,
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
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, i) =>
              _TrackedItemTile(domain: domain, item: items[i]),
        );
      },
    );
  }
}

class _TrackedItemTile extends StatelessWidget {
  const _TrackedItemTile({required this.domain, required this.item});

  final TrackedDomain domain;
  final TrackedItem item;

  @override
  Widget build(BuildContext context) {
    final s = item;
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) =>
              TrackedItemViewScreen(domain: domain, itemId: s.id),
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
            LogoImage(
              assetPath: s.logoAsset,
              icon: s.icon,
              iconColor: s.iconColor,
              size: 44,
            ),
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
