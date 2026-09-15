import 'package:flutter/material.dart';

import '../data/monthly_review.dart';
import '../data/tracked_category.dart';
import '../l10n/strings.dart';
import '../theme/app_theme.dart';

enum ItemSortMode { newest, mostUsed, leastUsed }

/// Filter/sort selection shared by the Subscriptions/Utilities/People list
/// screens — a plain value type so each screen just holds one of these in
/// state instead of several separate variables. Category is multi-select
/// (empty set = show all categories); sort is single-select.
class ItemFilterState {
  const ItemFilterState({
    this.categories = const {},
    this.showCancelled = true,
    this.sortMode,
  });

  final Set<TrackedCategory> categories;
  final bool showCancelled;
  final ItemSortMode? sortMode;

  bool get isActive =>
      categories.isNotEmpty || !showCancelled || sortMode != null;

  bool matches(TrackedCategory category) =>
      categories.isEmpty || categories.contains(category);

  ItemFilterState toggling(TrackedCategory category) {
    final next = {...categories};
    if (!next.remove(category)) next.add(category);
    return copyWith(categories: next);
  }

  ItemFilterState copyWith({
    Set<TrackedCategory>? categories,
    bool? showCancelled,
    ItemSortMode? sortMode,
    bool clearSortMode = false,
  }) => ItemFilterState(
    categories: categories ?? this.categories,
    showCancelled: showCancelled ?? this.showCancelled,
    sortMode: clearSortMode ? null : (sortMode ?? this.sortMode),
  );
}

/// How often an item was marked used in the current month's check-in
/// (see lib/data/monthly_review.dart), as a 0-3 rank for sorting — null
/// when the item hasn't been through this month's check-in yet, in which
/// case the caller should sort it after every ranked item regardless of
/// direction (unreviewed isn't the same as confirmed "not used").
int? usageRank(ReviewDomain domain, String name) {
  final snapshot = MonthlyReviewStore.instance.currentSnapshot;
  if (snapshot == null) return null;
  final id = '${domain.name}:${name.trim().toLowerCase()}';
  for (final answer in snapshot.answers) {
    if (answer.item.id == id) {
      return switch (answer.activity) {
        ReviewActivity.none => 0,
        ReviewActivity.low => 1,
        ReviewActivity.medium => 2,
        ReviewActivity.high => 3,
      };
    }
  }
  return null;
}

/// A small circular filter button — a gold dot appears once any
/// filter/sort is active, the same way the notification coin flags
/// unread notices. Sits at the end of the category chip row.
class FilterIconButton extends StatelessWidget {
  const FilterIconButton({super.key, required this.active, required this.onTap});

  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: active ? AppColors.gold : AppColors.cardBorder,
              ),
            ),
            child: Icon(
              Icons.tune_rounded,
              color: active ? AppColors.gold : AppColors.textPrimary,
              size: 18,
            ),
          ),
          if (active)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.background, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A row of multi-select category chips — several can be highlighted at
/// once, unlike [CategoryFilterBar] (used elsewhere for genuinely
/// single-select pickers, like an item's own category in its edit sheet).
/// Tapping a chip toggles its membership in [state.categories]; tapping
/// "All" clears the whole set.
class MultiCategoryChipsRow extends StatelessWidget {
  const MultiCategoryChipsRow({
    super.key,
    required this.categories,
    required this.state,
    required this.onChanged,
  });

  final List<TrackedCategory> categories;
  final ItemFilterState state;
  final ValueChanged<ItemFilterState> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget chip({
      required String label,
      required IconData? icon,
      required bool isSelected,
      required VoidCallback onTap,
    }) {
      return GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.gold : AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? AppColors.gold : AppColors.cardBorder,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 13,
                  color: isSelected
                      ? AppColors.goldForeground
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? AppColors.goldForeground
                      : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 32,
      child: Row(
        children: [
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length + 1,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                if (i == 0) {
                  return chip(
                    label: Strings.t('category_all'),
                    icon: null,
                    isSelected: state.categories.isEmpty,
                    onTap: () =>
                        onChanged(state.copyWith(categories: const {})),
                  );
                }
                final category = categories[i - 1];
                return chip(
                  label: category.label,
                  icon: category.icon,
                  isSelected: state.categories.contains(category),
                  onTap: () => onChanged(state.toggling(category)),
                );
              },
            ),
          ),
          const SizedBox(width: 10),
          FilterIconButton(
            active: state.isActive,
            onTap: () => showItemFilterSheet(
              context: context,
              categories: categories,
              state: state,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

/// Opens the shared filter/sort sheet — category (all the subcategories,
/// multi-select), a "show cancelled" toggle, and a sort mode. Stays open
/// across taps so several filters can be combined in one visit;
/// [onChanged] fires (and the underlying list re-filters live) on every
/// change.
Future<void> showItemFilterSheet({
  required BuildContext context,
  required List<TrackedCategory> categories,
  required ItemFilterState state,
  required ValueChanged<ItemFilterState> onChanged,
}) {
  // Declared here, one level above StatefulBuilder, so it survives
  // setSheetState() rebuilds instead of resetting to the original `state`
  // argument on every tap (which was the bug: selections never appeared
  // highlighted because each rebuild re-initialized from the stale value).
  var current = state;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => StatefulBuilder(
      builder: (sheetContext, setSheetState) {
        void update(ItemFilterState next) {
          current = next;
          onChanged(next);
          setSheetState(() {});
        }

        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              20 + MediaQuery.of(sheetContext).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.cardBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    Strings.t('filter_sheet_title'),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _SectionLabel(Strings.t('category_field')),
                  const SizedBox(height: 8),
                  _FilterRow(
                    label: Strings.t('category_all'),
                    isChecked: current.categories.isEmpty,
                    checkStyle: _CheckStyle.radio,
                    onTap: () => update(current.copyWith(categories: const {})),
                  ),
                  for (final category in categories)
                    _FilterRow(
                      label: category.label,
                      icon: category.icon,
                      isChecked: current.categories.contains(category),
                      checkStyle: _CheckStyle.checkbox,
                      onTap: () => update(current.toggling(category)),
                    ),
                  const SizedBox(height: 10),
                  _FilterToggleRow(
                    label: Strings.t('show_cancelled_label'),
                    value: current.showCancelled,
                    onChanged: (v) => update(current.copyWith(showCancelled: v)),
                  ),
                  const SizedBox(height: 18),
                  _SectionLabel(Strings.t('sort_by_label')),
                  const SizedBox(height: 8),
                  _FilterRow(
                    label: Strings.t('sort_newest'),
                    isChecked: current.sortMode == ItemSortMode.newest,
                    checkStyle: _CheckStyle.radio,
                    onTap: () => update(
                      current.sortMode == ItemSortMode.newest
                          ? current.copyWith(clearSortMode: true)
                          : current.copyWith(sortMode: ItemSortMode.newest),
                    ),
                  ),
                  _FilterRow(
                    label: Strings.t('sort_most_used'),
                    isChecked: current.sortMode == ItemSortMode.mostUsed,
                    checkStyle: _CheckStyle.radio,
                    onTap: () => update(
                      current.sortMode == ItemSortMode.mostUsed
                          ? current.copyWith(clearSortMode: true)
                          : current.copyWith(sortMode: ItemSortMode.mostUsed),
                    ),
                  ),
                  _FilterRow(
                    label: Strings.t('sort_least_used'),
                    isChecked: current.sortMode == ItemSortMode.leastUsed,
                    checkStyle: _CheckStyle.radio,
                    onTap: () => update(
                      current.sortMode == ItemSortMode.leastUsed
                          ? current.copyWith(clearSortMode: true)
                          : current.copyWith(sortMode: ItemSortMode.leastUsed),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      color: AppColors.textSecondary,
      fontSize: 12.5,
      fontWeight: FontWeight.w600,
    ),
  );
}

enum _CheckStyle { radio, checkbox }

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.label,
    required this.isChecked,
    required this.onTap,
    required this.checkStyle,
    this.icon,
  });

  final String label;
  final IconData? icon;
  final bool isChecked;
  final _CheckStyle checkStyle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final indicator = switch (checkStyle) {
      _CheckStyle.radio => isChecked
          ? Icons.radio_button_checked_rounded
          : Icons.radio_button_unchecked_rounded,
      _CheckStyle.checkbox => isChecked
          ? Icons.check_box_rounded
          : Icons.check_box_outline_blank_rounded,
    };
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isChecked ? AppColors.gold : AppColors.textSecondary,
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isChecked
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: isChecked ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
            Icon(
              indicator,
              size: 18,
              color: isChecked ? AppColors.gold : AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterToggleRow extends StatelessWidget {
  const _FilterToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      Switch(value: value, onChanged: onChanged, activeThumbColor: AppColors.gold),
    ],
  );
}
