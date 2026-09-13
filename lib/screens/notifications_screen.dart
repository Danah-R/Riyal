import 'dart:async';
import 'package:flutter/material.dart';
import '../data/notifications_store.dart';
import '../l10n/strings.dart';
import '../theme/app_theme.dart';
import '../widgets/coin_back_button.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(
      leading: const CoinBackButton(),
      title: Text(Strings.t('notifications_title')),
      backgroundColor: AppColors.background,
    ),
    body: ValueListenableBuilder<List<PaymentNotice>>(
      valueListenable: NotificationsStore.instance.notices,
      builder: (context, notices, _) => notices.isEmpty
          ? Center(child: Text(Strings.t('no_notifications_yet')))
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: notices.length,
              separatorBuilder: (_, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  NoticeTile(notice: notices[index]),
            ),
    ),
  );
}

class NoticeTile extends StatelessWidget {
  const NoticeTile({super.key, required this.notice});
  final PaymentNotice notice;
  @override
  Widget build(BuildContext context) {
    final date = notice.createdAt;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            notice.reminder
                ? Icons.notifications_active_outlined
                : Icons.add_card_rounded,
            color: AppColors.gold,
            size: 23,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notice.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  notice.message,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.5,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${date.day}/${date.month}/${date.year} · ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(color: AppColors.gold, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> showNotificationsPreview(BuildContext context) async {
  NotificationsStore.instance.refresh();
  unawaited(NotificationsStore.instance.readState.markOpened());
  if (!context.mounted) return;
  final anchor = context.findRenderObject() as RenderBox;
  var expanded = false;
  await showDialog<void>(
    context: context,
    useSafeArea: false,
    barrierColor: Colors.black.withValues(alpha: 0.18),
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setPopupState) => LayoutBuilder(
        builder: (context, constraints) {
          final media = MediaQuery.of(context);
          final position = anchor.attached
              ? anchor.localToGlobal(Offset.zero)
              : Offset.zero;
          final width = (constraints.maxWidth - 24).clamp(0.0, 440.0);
          final left =
              (position.dx + (anchor.attached ? anchor.size.width : 44) - width)
                  .clamp(
                    12.0,
                    (constraints.maxWidth - width - 12).clamp(
                      12.0,
                      double.infinity,
                    ),
                  );
          final bottom =
              constraints.maxHeight -
              media.padding.bottom -
              media.viewInsets.bottom -
              12;
          final top =
              (position.dy + (anchor.attached ? anchor.size.height : 44) + 8)
                  .clamp(
                    media.padding.top + 8,
                    bottom.clamp(media.padding.top + 8, double.infinity),
                  );
          final height = (bottom - top).clamp(0.0, expanded ? 650.0 : 480.0);
          return Stack(
            children: [
              Positioned(
                left: left,
                top: top,
                width: width,
                child: Material(
                  color: AppColors.background,
                  elevation: 12,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                    side: const BorderSide(color: AppColors.cardBorder),
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: height),
                    child: ValueListenableBuilder<List<PaymentNotice>>(
                      valueListenable: NotificationsStore.instance.notices,
                      builder: (context, notices, _) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 18,
                              right: 6,
                              top: 6,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    expanded
                                        ? Strings.t('all_notifications')
                                        : Strings.t('notifications_title'),
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  tooltip: Strings.t('close'),
                                  onPressed: () => Navigator.pop(dialogContext),
                                  icon: const Icon(
                                    Icons.close,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Flexible(
                            child: notices.isEmpty
                                ? Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Text(
                                      Strings.t('no_notifications_yet'),
                                    ),
                                  )
                                : ListView.separated(
                                    shrinkWrap: true,
                                    padding: const EdgeInsets.fromLTRB(
                                      12,
                                      8,
                                      12,
                                      12,
                                    ),
                                    itemCount: expanded
                                        ? notices.length
                                        : notices.take(3).length,
                                    separatorBuilder: (_, index) =>
                                        const SizedBox(height: 10),
                                    itemBuilder: (context, index) =>
                                        NoticeTile(notice: notices[index]),
                                  ),
                          ),
                          if (notices.length > 3)
                            Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  right: 12,
                                  bottom: 6,
                                ),
                                child: TextButton(
                                  onPressed: () =>
                                      setPopupState(() => expanded = !expanded),
                                  child: Text(
                                    expanded
                                        ? Strings.t('show_less')
                                        : Strings.t('see_all'),
                                    style: const TextStyle(
                                      color: AppColors.gold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}
