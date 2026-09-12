import 'package:flutter/material.dart';

import '../data/tracked_category.dart';
import '../data/tracked_domain.dart';
import '../data/tracked_item.dart';
import '../theme/app_theme.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/logo_image.dart';
import 'add_tracked_item_sheet.dart';

enum _PageTab { items, analytics }

/// The Utilities/Staff tabs' content — same layout as the Subscriptions
/// page ([SubscriptionsBody]), driven by a [TrackedDomain] instead.
class TrackedItemsScreen extends StatefulWidget {
  const TrackedItemsScreen({super.key, required this.title, required this.domain});

  final String title;
  final TrackedDomain domain;

  @override
  State<TrackedItemsScreen> createState() => _TrackedItemsScreenState();
}

class _TrackedItemsScreenState extends State<TrackedItemsScreen> {
  _PageTab _tab = _PageTab.items;
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
                    title: widget.title,
                    selected: _tab,
                    onChanged: (t) => setState(() => _tab = t),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => showAddTrackedItemSheet(context, widget.domain),
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
                  ? _TrackedItemsList(domain: widget.domain, category: _category)
                  : _AnalyticsPlaceholder(domain: widget.domain),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopTabs extends StatelessWidget {
  const _TopTabs({required this.title, required this.selected, required this.onChanged});

  final String title;
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
          tab(title, _PageTab.items),
          const SizedBox(width: 6),
          tab('Analytics', _PageTab.analytics),
        ],
      ),
    );
  }
}

class _TrackedItemsList extends StatelessWidget {
  const _TrackedItemsList({required this.domain, this.category});

  final TrackedDomain domain;
  final TrackedCategory? category;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<TrackedItem>>(
      valueListenable: domain.store.items,
      builder: (context, allItems, _) {
        final items = category == null
            ? allItems
            : allItems.where((s) => s.category == category).toList();

        if (allItems.isEmpty) {
          return Center(
            child: Text(
              'No ${domain.itemNounSingular}s yet.\nTap + to add one.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          );
        }
        if (items.isEmpty) {
          return Center(
            child: Text(
              'No ${category!.label.toLowerCase()} ${domain.itemNounSingular}s yet.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.only(bottom: 130),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, i) => _TrackedItemTile(item: items[i]),
        );
      },
    );
  }
}

class _TrackedItemTile extends StatelessWidget {
  const _TrackedItemTile({required this.item});

  final TrackedItem item;

  @override
  Widget build(BuildContext context) {
    final s = item;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          LogoImage(assetPath: s.logoAsset, icon: s.icon, iconColor: s.iconColor, size: 44),
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
  const _AnalyticsPlaceholder({required this.domain});

  final TrackedDomain domain;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<TrackedItem>>(
      valueListenable: domain.store.items,
      builder: (context, items, _) {
        final total = items.fold<double>(0, (sum, s) => sum + s.monthlyAmount);
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
                    'across ${items.length} ${items.length == 1 ? domain.itemNounSingular : '${domain.itemNounSingular}s'}',
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
