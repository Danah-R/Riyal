import 'dart:async';
import 'package:flutter/material.dart';
import '../data/notifications_store.dart';
import '../screens/notifications_screen.dart';
import '../theme/app_theme.dart';
import 'gold_coin_painter.dart';

class NotificationCoinButton extends StatefulWidget {
  const NotificationCoinButton({super.key});
  @override
  State<NotificationCoinButton> createState() => _NotificationCoinButtonState();
}

class _NotificationCoinButtonState extends State<NotificationCoinButton>
    with WidgetsBindingObserver {
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    NotificationsStore.instance.refresh();
    unawaited(NotificationsStore.instance.readState.initialize());
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => NotificationsStore.instance.refresh(),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      NotificationsStore.instance.refresh();
      unawaited(NotificationsStore.instance.readState.initialize());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: 'Notifications',
    onPressed: () => showNotificationsPreview(context),
    padding: EdgeInsets.zero,
    icon: ValueListenableBuilder<bool>(
      valueListenable: NotificationsStore.instance.readState.hasUnread,
      builder: (context, unread, _) => Semantics(
        label: unread ? 'Unread notifications' : 'Notifications',
        child: SizedBox(
          width: 44,
          height: 44,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: const NavCoinPainter(),
                  child: const Center(
                    child: Icon(
                      Icons.notifications_none_rounded,
                      color: AppColors.surface,
                      size: 23,
                    ),
                  ),
                ),
              ),
              if (unread)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.background,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}
