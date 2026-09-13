import 'package:flutter/material.dart';
import '../widgets/coin_back_button.dart';

import '../data/subscription.dart' show BillingCycle;
import '../data/tracked_category.dart';
import '../data/tracked_domain.dart';
import '../data/tracked_item.dart';
import '../l10n/strings.dart';
import '../theme/app_theme.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/logo_image.dart';

class TrackedItemDetailsScreen extends StatefulWidget {
  const TrackedItemDetailsScreen({
    super.key,
    required this.domain,
    required this.name,
    this.logoAsset,
    this.icon,
    this.iconColor,
    this.initialAmount,
    this.initialCategory,
  });

  final TrackedDomain domain;
  final String name;
  final String? logoAsset;
  final IconData? icon;
  final Color? iconColor;
  final double? initialAmount;
  final TrackedCategory? initialCategory;

  @override
  State<TrackedItemDetailsScreen> createState() =>
      _TrackedItemDetailsScreenState();
}

class _TrackedItemDetailsScreenState extends State<TrackedItemDetailsScreen> {
  late final TextEditingController _amountController = TextEditingController(
    text: widget.initialAmount != null
        ? widget.initialAmount!.toStringAsFixed(0)
        : '',
  );
  BillingCycle _cycle = BillingCycle.monthly;
  DateTime _nextBillingDate = DateTime.now().add(const Duration(days: 30));
  late TrackedCategory _category =
      widget.initialCategory ?? widget.domain.categories.last;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _nextBillingDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) setState(() => _nextBillingDate = picked);
  }

  void _save() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    widget.domain.store.add(
      TrackedItem(
        name: widget.name,
        logoAsset: widget.logoAsset,
        icon: widget.icon,
        iconColor: widget.iconColor,
        amount: amount,
        cycle: _cycle,
        nextBillingDate: _nextBillingDate,
        category: _category,
      ),
    );
    // MainShell (with this domain's tab already selected) is always the
    // root route, so popping back to it just means popping to the first route.
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CoinBackButton(),
                  Expanded(
                    child: Text(
                      Strings.t('details'),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: [
                    Row(
                      children: [
                        LogoImage(
                          assetPath: widget.logoAsset,
                          icon: widget.icon,
                          iconColor: widget.iconColor,
                          size: 56,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            widget.name,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Text(
                      Strings.t('amount_sar'),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        hintText: '0',
                        hintStyle: const TextStyle(
                          color: AppColors.textSecondary,
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      Strings.t('billing_cycle'),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _CycleOption(
                            label: Strings.t('monthly'),
                            isSelected: _cycle == BillingCycle.monthly,
                            onTap: () =>
                                setState(() => _cycle = BillingCycle.monthly),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _CycleOption(
                            label: Strings.t('yearly'),
                            isSelected: _cycle == BillingCycle.yearly,
                            onTap: () =>
                                setState(() => _cycle = BillingCycle.yearly),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Text(
                      Strings.t('category_field'),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CategoryFilterBar(
                      categories: widget.domain.categories,
                      showAll: false,
                      selected: _category,
                      onChanged: (c) =>
                          setState(() => _category = c ?? _category),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      Strings.t('next_billing_date'),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              color: AppColors.gold,
                              size: 18,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${_nextBillingDate.year}-${_nextBillingDate.month.toString().padLeft(2, '0')}-${_nextBillingDate.day.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: const Color(0xFF1B1F16),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    Strings.addA(widget.domain.itemNounSingular),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CycleOption extends StatelessWidget {
  const _CycleOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.gold : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? const Color(0xFF1B1F16)
                : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
