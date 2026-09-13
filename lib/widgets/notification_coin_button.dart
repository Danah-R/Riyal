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
    icon: SizedBox(
      width: 44,
      height: 44,
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
  );
}
