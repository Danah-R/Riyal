import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CoinBackButton extends StatefulWidget {
  const CoinBackButton({super.key});
  @override
  State<CoinBackButton> createState() => _CoinBackButtonState();
}

class _CoinBackButtonState extends State<CoinBackButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 750),
  );
  bool _busy = false;
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _back() async {
    if (_busy) return;
    _busy = true;
    if (!MediaQuery.disableAnimationsOf(context)) {
      try {
        await _controller.forward().orCancel;
      } on TickerCanceled {
        return;
      }
    }
    if (!mounted) return;
    await Navigator.of(context).maybePop();
    if (mounted) {
      _controller.reset();
      _busy = false;
    }
  }

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: 'Back',
    onPressed: _back,
    padding: const EdgeInsets.all(6),
    icon: AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final angle =
            Curves.easeInOutSine.transform(_controller.value) * math.pi * 2;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.002)
            ..rotateY(angle),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFEBA5),
                  AppColors.gold,
                  AppColors.goldDark,
                  Color(0xFFFFEBA5),
                ],
                stops: [0, 0.4, 0.8, 1],
              ),
              border: Border.all(color: const Color(0xFFFFEBA5), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.18),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(3),
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.goldDark),
              ),
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(math.cos(angle) < 0 ? math.pi : 0),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.background,
                  size: 21,
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}
