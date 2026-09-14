import 'package:flutter/material.dart';

import '../data/bank_transaction_matcher.dart';
import '../data/recurring_detection.dart';
import '../data/subscription.dart';
import '../data/subscriptions_store.dart';
import '../data/user_bank_account.dart';
import '../data/user_bank_accounts_store.dart';
import '../l10n/strings.dart';
import '../theme/app_theme.dart';
import '../widgets/coin_back_button.dart';
import '../widgets/logo_image.dart';
import 'connect_bank_screen.dart';

/// Connected mock bank accounts — replaces what used to be Lean-backed.
/// Reachable from Settings.
class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  final _suggestions = ValueNotifier<List<DetectedSubscription>>([]);

  @override
  void initState() {
    super.initState();
    _refreshSuggestions();
  }

  @override
  void dispose() {
    _suggestions.dispose();
    super.dispose();
  }

  Future<void> _refreshSuggestions() async {
    final transactions = await loadAllConnectedTransactions();
    if (mounted) {
      _suggestions.value = RecurringDetectionEngine.detect(transactions);
    }
  }

  Future<void> _addAccount() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const ConnectBankScreen()),
    );
    await _refreshSuggestions();
  }

  void _addSuggestion(DetectedSubscription suggestion) {
    SubscriptionsStore.instance.add(
      Subscription(
        name: suggestion.merchantName,
        logoAsset: null,
        amount: suggestion.amount,
        cycle: suggestion.cycle,
        nextBillingDate: suggestion.suggestedNextBillingDate,
      ),
    );
    _suggestions.value = _suggestions.value
        .where((s) => s != suggestion)
        .toList();
  }

  void _openAccountDetails(UserBankAccount account) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  LogoImage(icon: Icons.account_balance_rounded, size: 44),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          account.bankName,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          account.maskedAccountNumber,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFEF4444),
                  ),
                  onPressed: () async {
                    Navigator.pop(sheetContext);
                    await UserBankAccountsStore.instance.remove(account.id);
                    await _refreshSuggestions();
                  },
                  icon: const Icon(Icons.link_off_rounded, size: 20),
                  label: Text(Strings.t('disconnect')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        leading: const CoinBackButton(),
        title: Text(Strings.t('accounts_title')),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ValueListenableBuilder<List<UserBankAccount>>(
                valueListenable: UserBankAccountsStore.instance.accounts,
                builder: (context, accounts, _) => ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  children: [
                    if (accounts.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 60),
                        child: Center(
                          child: Text(
                            Strings.t('no_accounts_yet'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                    else
                      for (final account in accounts)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _AccountTile(
                            account: account,
                            onTap: () => _openAccountDetails(account),
                          ),
                        ),
                    ValueListenableBuilder<List<DetectedSubscription>>(
                      valueListenable: _suggestions,
                      builder: (context, suggestions, _) {
                        if (suggestions.isEmpty) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Strings.t('suggested_subscriptions'),
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                Strings.t('suggested_subscriptions_sub'),
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12.5,
                                ),
                              ),
                              const SizedBox(height: 14),
                              for (final suggestion in suggestions)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _SuggestionTile(
                                    suggestion: suggestion,
                                    onAdd: () => _addSuggestion(suggestion),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _addAccount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: const Color(0xFF1B1F16),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(
                    Strings.t('add_account'),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({required this.account, required this.onTap});

  final UserBankAccount account;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: account.bankPrimaryColor,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.account_balance_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.bankName,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    account.maskedAccountNumber,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.check_circle_rounded,
              color: AppColors.subscriptions,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({required this.suggestion, required this.onAdd});

  final DetectedSubscription suggestion;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  suggestion.merchantName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'SAR ${suggestion.amount.toStringAsFixed(0)} · '
                  '${Strings.f('occurrences_count', '${suggestion.occurrences}')}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          TextButton(
            onPressed: onAdd,
            style: TextButton.styleFrom(foregroundColor: AppColors.gold),
            child: Text(Strings.t('add_suggestion')),
          ),
        ],
      ),
    );
  }
}
