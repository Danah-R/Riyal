import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Replaces a page's top tab row while searching — a text field plus a
/// close button to return to the tabs.
class InlineSearchField extends StatelessWidget {
  const InlineSearchField({
    super.key,
    required this.onChanged,
    required this.onClose,
    required this.hintText,
    this.autofocus = false,
  });

  final ValueChanged<String> onChanged;
  final VoidCallback onClose;
  final String hintText;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            autofocus: autofocus,
            onChanged: onChanged,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: AppColors.textSecondary),
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.textSecondary,
              ),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: onClose,
          icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
        ),
      ],
    );
  }
}
