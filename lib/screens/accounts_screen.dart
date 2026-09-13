import 'package:flutter/material.dart';
import 'package:lean_sdk_flutter/lean_sdk_flutter.dart';

import '../data/bank_account.dart';
import '../data/bank_accounts_store.dart';
import '../data/bank_transaction.dart';
import '../data/lean_customer_store.dart';
import '../data/lean_service.dart';
import '../data/recurring_detection.dart';
import '../data/subscription.dart';
import '../data/subscriptions_store.dart';
import '../l10n/strings.dart';
import '../theme/app_theme.dart';
import '../widgets/coin_back_button.dart';
import '../widgets/logo_image.dart';
import 'lean_connect_screen.dart';

/// Real bank accounts connected via Lean — replaces what used to be a
/// hardcoded mock list. Reachable from Settings.
class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  bool _connecting = false;
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
    final accounts = BankAccountsStore.instance.accounts.value;
    if (accounts.isEmpty) return;
    final deviceId = await LeanCustomerStore.instance.getOrCreateDeviceId();
    final transactions = <BankTransaction>[];
    for (final account in accounts) {
      try {
        final json = await LeanService.instance.fetchTransactions(
          entityId: account.entityId,
          deviceId: deviceId,
        );
        transactions.addAll(
          BankTransaction.fromLeanJson(entityId: account.entityId, json: json),
        );
      } catch (_) {
        // Data may not be ready yet for a just-connected account; the user
        // can pull to refresh later. Not fatal to the rest of the screen.
      }
    }
    if (mounted) {
      _suggestions.value = RecurringDetectionEngine.detect(transactions);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _addAccount() async {
    setState(() => _connecting = true);
    try {
      final deviceId = await LeanCustomerStore.instance.getOrCreateDeviceId();
      // Idempotent server-side: the Edge Function reuses the existing Lean
      // customer for this device (via the `lean_customers` table) instead
      // of creating a new one every time.
      final customerId = await LeanService.instance.createCustomer(deviceId);
      final accessToken = await LeanService.instance.getConnectToken(
        customerId,
      );
      if (!mounted) return;

      final response = await Navigator.of(context).push<LeanResponse>(
        MaterialPageRoute<LeanResponse>(
          builder: (_) => LeanConnectScreen(
            customerId: customerId,
            accessToken: accessToken,
          ),
        ),
      );
      if (response == null) return; // backed out of the connect screen

      if (response.status.toUpperCase() != 'SUCCESS') {
        _showMessage(
          response.status.toUpperCase() == 'CANCELLED'
              ? Strings.t('lean_cancelled')
              : (response.message ?? Strings.t('lean_connect_failed')),
        );
        return;
      }

      await _resolveAndStoreAccount(deviceId);
      await _refreshSuggestions();
    } on LeanServiceException catch (error) {
      _showMessage(error.message);
    } catch (_) {
      _showMessage(Strings.t('lean_connect_failed'));
    } finally {
      if (mounted) setState(() => _connecting = false);
    }
  }

  /// The connect widget's callback doesn't carry an entity_id, and Lean's
  /// data may take a moment to become available after a sandbox login
  /// finishes — poll both lookups a few times with backoff rather than
  /// failing immediately. The Edge Function upserts the account into
  /// Supabase as a side effect of the accounts fetch, so once that
  /// succeeds we just re-read `bank_accounts` for the canonical row.
  Future<void> _resolveAndStoreAccount(String deviceId) async {
    String? entityId;
    for (var attempt = 0; attempt < 5 && entityId == null; attempt++) {
      if (attempt > 0) await Future.delayed(const Duration(seconds: 2));
      entityId = await LeanService.instance.latestEntityId(deviceId);
    }
    if (entityId == null) {
      _showMessage(Strings.t('lean_entity_not_found'));
      return;
    }

    for (var attempt = 0; attempt < 5; attempt++) {
      if (attempt > 0) await Future.delayed(const Duration(seconds: 2));
      try {
        await LeanService.instance.fetchAccounts(
          entityId: entityId,
          deviceId: deviceId,
        );
        break;
      } catch (_) {
        // keep retrying — data isn't ready yet
      }
    }

    await BankAccountsStore.instance.load();
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

  void _openAccountDetails(BankAccount account) {
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
              const SizedBox(height: 18),
              _StatusRow(status: account.status),
              const SizedBox(height: 6),
              Text(
                account.lastSyncedAt != null
                    ? Strings.f(
                        'last_synced',
                        _formatTimestamp(account.lastSyncedAt!),
                      )
                    : Strings.t('never_synced'),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
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
                    await BankAccountsStore.instance.remove(account.entityId);
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

  String _formatTimestamp(DateTime time) =>
      '${time.day}/${time.month}/${time.year}';

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
              child: ValueListenableBuilder<List<BankAccount>>(
                valueListenable: BankAccountsStore.instance.accounts,
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
                  onPressed: _connecting ? null : _addAccount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: const Color(0xFF1B1F16),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: _connecting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF1B1F16),
                          ),
                        )
                      : const Icon(Icons.add_rounded),
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

  final BankAccount account;
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
            const LogoImage(icon: Icons.account_balance_rounded, size: 44),
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
            _StatusRow(status: account.status),
          ],
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.status});

  final BankAccountStatus status;

  @override
  Widget build(BuildContext context) {
    final (color, key) = switch (status) {
      BankAccountStatus.connected => (
        AppColors.subscriptions,
        'account_status_connected',
      ),
      BankAccountStatus.syncing => (AppColors.gold, 'account_status_syncing'),
      BankAccountStatus.error => (
        const Color(0xFFEF4444),
        'account_status_error',
      ),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(Strings.t(key), style: TextStyle(color: color, fontSize: 12.5)),
      ],
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
