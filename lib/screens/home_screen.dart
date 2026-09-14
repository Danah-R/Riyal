import 'package:flutter/material.dart';

import '../data/home_data.dart';
import '../data/monthly_review.dart';
import '../data/subscription.dart';
import '../data/subscriptions_store.dart';
import '../l10n/strings.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';
import '../widgets/profile_menu_button.dart';
import '../widgets/notification_coin_button.dart';
import '../widgets/logo_image.dart';
import '../widgets/card_logo_watermark.dart';
import 'analytics_screen.dart';
import 'monthly_review_screen.dart';

enum _HomeTab { overview, analytics }

/// The Home tab's content. Lives inside [MainShell]'s [IndexedStack], so it
/// has no Scaffold/bottom nav of its own — the shell provides those once for
/// all tabs.
class HomeBody extends StatefulWidget {
  const HomeBody({super.key});

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  _HomeTab _tab = _HomeTab.overview;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TopBar(),
            const SizedBox(height: 16),
            _HomeTabSelector(
              selected: _tab,
              onChanged: (t) => setState(() => _tab = t),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _tab == _HomeTab.overview
                  ? ListView(
                      padding: const EdgeInsets.only(bottom: 130),
                      children: [
                        const _SpendingCard(),
                        const SizedBox(height: 16),
                        const _MonthlyReviewCard(),
                        const SizedBox(height: 28),
                        _SectionHeader(
                          title: Strings.t('overview'),
                          onSeeAll: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const AnalyticsScreen(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const _OverviewBar(),
                        const SizedBox(height: 16),
                        const _OverviewStats(),
                        const SizedBox(height: 28),
                        _SectionHeader(
                          title: Strings.t('upcoming_renewals'),
                          onSeeAll: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const AnalyticsScreen(
                                category: 'Subscriptions',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const _UpcomingRenewals(),
                      ],
                    )
                  : const AnalyticsContent(
                      horizontalPadding: 0,
                      bottomPadding: 130,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthlyReviewCard extends StatelessWidget {
  const _MonthlyReviewCard();

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<int>(
    valueListenable: MonthlyReviewStore.instance.revision,
    builder: (context, _, child) {
      final completed = MonthlyReviewStore.instance.isCurrentMonthComplete;
      return InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const MonthlyReviewScreen()),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: completed ? AppColors.cardBorder : AppColors.goldDark,
            ),
          ),
          child: Stack(
            children: [
              const CardLogoWatermark(corner: WatermarkCorner.bottomEnd),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: AppColors.trackBackground,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      completed
                          ? Icons.check_circle_outline
                          : Icons.assignment_outlined,
                      color: AppColors.gold,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          completed
                              ? Strings.t('monthly_review_completed')
                              : Strings.t('monthly_review_card_title'),
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          completed
                              ? Strings.t('monthly_review_completed_sub')
                              : Strings.t('monthly_review_card_sub'),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.gold),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [const ProfileMenuButton(), const NotificationCoinButton()],
    );
  }
}

class _HomeTabSelector extends StatelessWidget {
  const _HomeTabSelector({required this.selected, required this.onChanged});

  final _HomeTab selected;
  final ValueChanged<_HomeTab> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget tab(String label, _HomeTab value) {
      final isSelected = selected == value;
      return GestureDetector(
        onTap: () => onChanged(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.gold : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? const Color(0xFF1B1F16)
                  : AppColors.textSecondary,
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
          tab(Strings.t('overview'), _HomeTab.overview),
          const SizedBox(width: 6),
          tab(Strings.t('analytics_tab'), _HomeTab.analytics),
        ],
      ),
    );
  }
}

class _SpendingCard extends StatelessWidget {
  const _SpendingCard();

  @override
  Widget build(BuildContext context) {
    final progress = (subscriptionsSpent / subscriptionsBudget).clamp(0.0, 1.0);
    final left = subscriptionsBudget - subscriptionsSpent;

    return Container(
      padding: const EdgeInsets.all(20),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Stack(
        children: [
          const CardLogoWatermark(corner: WatermarkCorner.topEnd),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Strings.t('spending_heading'),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '⃁${subscriptionsSpent.toStringAsFixed(0)}',
                    style: AppTypography.amount(
                      color: AppColors.textPrimary,
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            const AnalyticsScreen(category: 'Subscriptions'),
                      ),
                    ),
                    child: const Icon(
                      Icons.chevron_right,
                      color: AppColors.gold,
                      size: 26,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: AppColors.trackBackground,
                  valueColor: const AlwaysStoppedAnimation(AppColors.gold),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      Strings.f(
                        'of_sar_budget',
                        subscriptionsBudget.toStringAsFixed(0),
                      ),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    Strings.f('sar_left', left.toStringAsFixed(0)),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.onSeeAll});

  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onSeeAll,
          child: Text(
            Strings.t('see_all'),
            style: const TextStyle(
              color: AppColors.gold,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _OverviewBar extends StatelessWidget {
  const _OverviewBar();

  @override
  Widget build(BuildContext context) {
    final total = overview.fold<double>(0, (sum, c) => sum + c.amount);
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 14,
        child: Row(
          children: overview
              .map(
                (c) => Expanded(
                  flex: (c.amount / total * 1000).round(),
                  child: Container(color: Color(c.color)),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _OverviewStats extends StatelessWidget {
  const _OverviewStats();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: overview
          .map(
            (c) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Color(c.color),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            '⃁${c.amount.toStringAsFixed(0)}',
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.amount(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Strings.categoryDisplay(c.label),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _UpcomingRenewals extends StatefulWidget {
  const _UpcomingRenewals();

  @override
  State<_UpcomingRenewals> createState() => _UpcomingRenewalsState();
}

class _UpcomingRenewalsState extends State<_UpcomingRenewals> {
  final _pageController = PageController();
  int _monthOffset = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToMonth(int offset) {
    _pageController.animateToPage(
      offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
    );
  }

  void _showDayRenewals(List<Subscription> daySubs, DateTime day) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${day.day} ${Strings.monthAbbrev(day.month)} ${day.year}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              for (final s in daySubs)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _RenewalTile(subscription: s),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Subscription>>(
      valueListenable: SubscriptionsStore.instance.subscriptions,
      builder: (context, subs, _) {
        if (subs.isEmpty) {
          return Text(
            Strings.t('no_subscriptions_yet_short'),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          );
        }
        final now = DateTime.now();
        final displayedMonth = DateTime(now.year, now.month + _monthOffset);
        return Container(
          padding: const EdgeInsets.all(12),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Stack(
            children: [
              const CardLogoWatermark(corner: WatermarkCorner.bottomEnd),
              Column(
                children: [
                  SizedBox(
                    height: 26,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _CalendarNavButton(
                          icon: Icons.chevron_left_rounded,
                          onTap: _monthOffset > 0
                              ? () => _goToMonth(_monthOffset - 1)
                              : null,
                        ),
                        Text(
                          '${Strings.monthAbbrev(displayedMonth.month)} '
                          '${displayedMonth.year}',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        _CalendarNavButton(
                          icon: Icons.chevron_right_rounded,
                          onTap: () => _goToMonth(_monthOffset + 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    height: 230,
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (i) => setState(() => _monthOffset = i),
                      itemBuilder: (context, index) => _MonthGrid(
                        month: DateTime(now.year, now.month + index),
                        subscriptions: subs,
                        onDayTap: _showDayRenewals,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.subscriptions,
    required this.onDayTap,
  });

  final DateTime month;
  final List<Subscription> subscriptions;
  final void Function(List<Subscription> daySubs, DateTime day) onDayTap;

  List<Subscription> _subscriptionsOn(int day) => subscriptions
      .where(
        (s) =>
            s.nextBillingDate.year == month.year &&
            s.nextBillingDate.month == month.month &&
            s.nextBillingDate.day == day,
      )
      .toList();

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    // DateTime.weekday: Monday=1..Sunday=7. Calendar starts on Sunday, so
    // Sunday needs 0 leading blanks, Monday 1, ... Saturday 6.
    final leading = DateTime(month.year, month.month, 1).weekday % 7;
    final totalCells = leading + daysInMonth;
    final rows = (totalCells / 7).ceil();
    final today = DateTime.now();

    return Column(
      children: [
        Row(
          children: [
            for (var w = 0; w < 7; w++)
              Expanded(
                child: Center(
                  child: Text(
                    Strings.weekdayAbbrev(w),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 2),
        for (var r = 0; r < rows; r++)
          Expanded(
            child: Row(
              children: [
                for (var c = 0; c < 7; c++)
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        final dayNum = r * 7 + c - leading + 1;
                        if (dayNum < 1 || dayNum > daysInMonth) {
                          return const SizedBox.shrink();
                        }
                        final daySubs = _subscriptionsOn(dayNum);
                        final isToday =
                            today.year == month.year &&
                            today.month == month.month &&
                            today.day == dayNum;
                        return GestureDetector(
                          onTap: daySubs.isEmpty
                              ? null
                              : () => onDayTap(
                                  daySubs,
                                  DateTime(month.year, month.month, dayNum),
                                ),
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 1,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: isToday
                                  ? AppColors.gold.withValues(alpha: 0.15)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: isToday
                                  ? Border.all(color: AppColors.gold)
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '$dayNum',
                                  style: TextStyle(
                                    color: isToday
                                        ? AppColors.gold
                                        : AppColors.textPrimary,
                                    fontSize: 10,
                                    fontWeight: isToday
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                                if (daySubs.isNotEmpty) ...[
                                  const SizedBox(height: 1),
                                  _DayLogos(subscriptions: daySubs),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Up to 2 overlapping circular logos for a calendar day, plus a "+N"
/// circle if more subscriptions renew that same day.
class _DayLogos extends StatelessWidget {
  const _DayLogos({required this.subscriptions});

  final List<Subscription> subscriptions;

  static const _logoSize = 20.0;
  static const _overlap = 13.0;

  @override
  Widget build(BuildContext context) {
    final shown = subscriptions.take(2).toList();
    final overflow = subscriptions.length - shown.length;
    final width =
        _logoSize + _overlap * (shown.length - 1 + (overflow > 0 ? 1 : 0));

    return SizedBox(
      height: _logoSize,
      width: width,
      child: Stack(
        children: [
          for (var i = 0; i < shown.length; i++)
            Positioned(
              left: i * _overlap,
              child: LogoImage(
                assetPath: shown[i].logoAsset,
                size: _logoSize,
                radius: _logoSize / 2,
              ),
            ),
          if (overflow > 0)
            Positioned(
              left: shown.length * _overlap,
              child: Container(
                width: _logoSize,
                height: _logoSize,
                decoration: const BoxDecoration(
                  color: AppColors.trackBackground,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '+$overflow',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CalendarNavButton extends StatelessWidget {
  const _CalendarNavButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        icon,
        size: 22,
        color: enabled
            ? AppColors.gold
            : AppColors.textSecondary.withValues(alpha: 0.3),
      ),
    );
  }
}

class _RenewalTile extends StatelessWidget {
  const _RenewalTile({required this.subscription});

  final Subscription subscription;

  @override
  Widget build(BuildContext context) {
    final s = subscription;
    return Container(
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
          const SizedBox(width: 10),
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: AppColors.trackBackground,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.gold,
              size: 17,
            ),
          ),
        ],
      ),
    );
  }
}
