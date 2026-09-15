import 'package:flutter/foundation.dart';
import '../l10n/strings.dart';
import 'bank_transaction_matcher.dart';
import 'item_payment_history.dart';
import 'item_status.dart';
import 'mock_bank_transaction.dart';
import 'subscriptions_store.dart';
import 'utilities_store.dart';
import 'staff_store.dart';
import 'app_settings.dart';
import 'monthly_review.dart';
import 'notice_read_state.dart';
import 'user_bank_accounts_store.dart';
import 'utility_anomaly_detection.dart';
import 'dart:async';
import 'dart:convert';

enum PaymentNoticeKind {
  itemAdded,
  paymentReminder,
  monthlyReview,
  utilityAnomaly,
}

class PaymentNotice {
  const PaymentNotice({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.reminder,
    this.kind = PaymentNoticeKind.itemAdded,
    this.itemId,
  });
  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool reminder;
  final PaymentNoticeKind kind;

  /// Set only on [PaymentNoticeKind.utilityAnomaly] notices — the
  /// [TrackedItem.id] of the utility bill to open when tapped.
  final String? itemId;
}

/// In-app demo inbox, fed by the same observable stores as the payment screens.
class NotificationsStore {
  NotificationsStore._() {
    refresh(seed: true);
    SubscriptionsStore.instance.subscriptions.addListener(refresh);
    UtilitiesStore.instance.items.addListener(refresh);
    StaffStore.instance.items.addListener(refresh);
    MonthlyReviewStore.instance.revision.addListener(refresh);
  }
  static final instance = NotificationsStore._();
  final notices = ValueNotifier<List<PaymentNotice>>([]);
  final readState = NoticeReadState();
  final Map<Object, String> _itemIds = Map.identity();
  final Set<Object> _seen = Set.identity();
  final Map<Object, Set<DateTime>> _reminded = Map.identity();

  /// The current-bill amount last notified about, per utility id — so an
  /// unchanged anomaly doesn't re-notify on every refresh tick, but a new
  /// bill that crosses the threshold again does.
  final Map<String, double> _lastAnomalyAmount = {};

  void refresh({bool seed = false}) {
    final now = DateTime.now();
    final additions = <PaymentNotice>[];
    void visit(
      Object identity,
      String name,
      String category,
      double amount,
      DateTime due, {
      required bool notificationsEnabled,
      required bool isActive,
    }) {
      if (!notificationsEnabled) return;
      final date = DateTime(due.year, due.month, due.day);
      final itemId = _itemIds.putIfAbsent(
        identity,
        () => jsonEncode([
          seed
              ? 'demo'
              : 'added-${now.microsecondsSinceEpoch}-${_itemIds.length}',
          category,
          name,
          amount,
        ]),
      );
      final formattedDate = '${date.day}/${date.month}/${date.year}';
      final categoryDisplay = Strings.categoryDisplay(category);
      if (_seen.add(identity)) {
        additions.add(
          PaymentNotice(
            id: 'added:$itemId',
            title: category == 'Subscriptions'
                ? Strings.t('notice_new_subscription')
                : Strings.t('notice_new_commitment'),
            message:
                '$name · $categoryDisplay\nSAR ${amount.toStringAsFixed(2)} · Next payment $formattedDate',
            createdAt: seed
                ? now.subtract(Duration(days: 7, seconds: _seen.length))
                : now,
            reminder: false,
          ),
        );
      }
      // Calendar subtraction avoids truncating 5 days to 4 due to time of day.
      final leadDays = AppSettings.instance.reminderDays;
      final reminderDate = DateTime(date.year, date.month, date.day - leadDays);
      if (isActive &&
          AppSettings.instance.paymentReminders &&
          !reminderDate.isAfter(now) &&
          (_reminded[identity] ??= {}).add(date)) {
        additions.add(
          PaymentNotice(
            id: 'reminder:$itemId:${itemId.contains('"demo"') ? 'seed' : date.toIso8601String()}',
            title: category == 'Subscriptions'
                ? Strings.t('notice_renewal_reminder')
                : Strings.t('notice_payment_reminder'),
            message:
                '$name · $categoryDisplay\nSAR ${amount.toStringAsFixed(2)} due $formattedDate\n${Strings.reminderLeadNote(leadDays)}',
            createdAt: reminderDate,
            reminder: true,
            kind: PaymentNoticeKind.paymentReminder,
          ),
        );
      }
    }

    for (final item in SubscriptionsStore.instance.subscriptions.value) {
      visit(
        item,
        item.name,
        'Subscriptions',
        item.amount,
        item.nextBillingDate,
        notificationsEnabled: item.notificationsEnabled,
        isActive: item.status == ItemStatus.active,
      );
    }
    for (final item in UtilitiesStore.instance.items.value) {
      visit(
        item,
        item.name,
        'Utilities',
        item.amount,
        item.nextBillingDate,
        notificationsEnabled: item.notificationsEnabled,
        isActive: item.status == ItemStatus.active,
      );
    }
    for (final item in StaffStore.instance.items.value) {
      visit(
        item,
        item.name,
        'Staff',
        item.amount,
        item.nextBillingDate,
        notificationsEnabled: item.notificationsEnabled,
        isActive: item.status == ItemStatus.active,
      );
    }
    final reviewStore = MonthlyReviewStore.instance;
    final reviewId = 'monthly-review:${reviewStore.currentPeriod}';
    final reviewIsDue =
        reviewStore.initialized &&
        AppSettings.instance.monthlyReviewReminders &&
        DateTime.now().day >= AppSettings.instance.monthlyReviewDay &&
        !reviewStore.isCurrentMonthComplete;
    if (reviewIsDue && !notices.value.any((notice) => notice.id == reviewId)) {
      additions.add(
        PaymentNotice(
          id: reviewId,
          title: Strings.t('monthly_review_notice_title'),
          message: Strings.t('monthly_review_notice_message'),
          createdAt: now,
          reminder: true,
          kind: PaymentNoticeKind.monthlyReview,
        ),
      );
    }
    final retained = !reviewIsDue
        ? notices.value.where((notice) => notice.id != reviewId).toList()
        : notices.value;
    if (additions.isNotEmpty) {
      notices.value = [...retained, ...additions]
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      readState.updateIds(notices.value.map((notice) => notice.id));
    } else if (retained.length != notices.value.length) {
      notices.value = retained;
      readState.updateIds(notices.value.map((notice) => notice.id));
    }

    // Fire-and-forget: unlike everything above, this needs a network call
    // (connected banks' transaction history), so it can't run synchronously
    // inline with the rest of refresh() without delaying — or, worse,
    // making callers await — every other notice update.
    unawaited(_refreshUtilityAnomalies());
  }

  /// Flags utility bills whose latest charge is unusual relative to their
  /// own trailing history (see lib/data/utility_anomaly_detection.dart) and
  /// turns any newly-crossed threshold into a notice, same as every other
  /// notice kind above. Only bills matched against a connected bank's
  /// transaction history have enough data to evaluate — utilities added
  /// from scratch with no matching transactions are silently skipped, same
  /// as the "needs 3 prior bills" rule already requires.
  Future<void> _refreshUtilityAnomalies() async {
    if (UserBankAccountsStore.instance.accounts.value.isEmpty) return;
    final List<MockBankTransactionRow> allTransactions;
    try {
      allTransactions = await loadAllConnectedTransactions();
    } catch (error) {
      debugPrint('Utility anomaly check failed: $error');
      return;
    }

    final additions = <PaymentNotice>[];
    for (final item in UtilitiesStore.instance.items.value) {
      if (!item.notificationsEnabled) continue;
      final history = historyForItemName(allTransactions, item.name);
      if (history.isEmpty) continue;
      final anomaly = UtilityAnomalyDetector.detect(
        category: item.category,
        priorAmounts: history.skip(1).take(3).map((t) => t.amount).toList(),
        currentAmount: history.first.amount,
      );
      if (anomaly == null) continue;
      if (_lastAnomalyAmount[item.id] == anomaly.currentAmount) continue;
      _lastAnomalyAmount[item.id] = anomaly.currentAmount;

      additions.add(
        PaymentNotice(
          id: 'utility-anomaly:${item.id}:${anomaly.currentAmount}',
          title: Strings.t('notice_utility_anomaly_title'),
          message: Strings.utilityAnomalyMessage(
            name: item.name,
            currentAmount: anomaly.currentAmount,
            averageAmount: anomaly.trailingAverage,
            percentAbove: anomaly.percentAbove,
          ),
          createdAt: DateTime.now(),
          reminder: true,
          kind: PaymentNoticeKind.utilityAnomaly,
          itemId: item.id,
        ),
      );
    }
    if (additions.isEmpty) return;
    notices.value = [...notices.value, ...additions]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    readState.updateIds(notices.value.map((notice) => notice.id));
  }
}
