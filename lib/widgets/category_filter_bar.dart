import 'package:flutter/material.dart';

import '../data/tracked_category.dart';
import '../l10n/strings.dart';
import '../theme/app_theme.dart';

class CategoryFilterBar extends StatelessWidget {
  const CategoryFilterBar({
    super.key,
    required this.categories,
    required this.selected,
    required this.onChanged,
    this.showAll = true,
  });

  final List<TrackedCategory> categories;
  final TrackedCategory? selected;
  final ValueChanged<TrackedCategory?> onChanged;
  final bool showAll;

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
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + (showAll ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          if (showAll) {
            if (i == 0) {
              return chip(
                label: Strings.t('category_all'),
                icon: null,
                isSelected: selected == null,
                onTap: () => onChanged(null),
              );
            }
            final category = categories[i - 1];
            return chip(
              label: category.label,
              icon: category.icon,
              isSelected: selected == category,
              onTap: () => onChanged(category),
            );
          }
          final category = categories[i];
          return chip(
            label: category.label,
            icon: category.icon,
            isSelected: selected == category,
            onTap: () => onChanged(category),
          );
        },
      ),
    );
  }
}
