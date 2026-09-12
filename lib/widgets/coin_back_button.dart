import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'gold_coin_painter.dart';

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
          child: SizedBox(
            width: 40,
            height: 40,
            child: CustomPaint(
              painter: const NavCoinPainter(),
              child: Center(
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(math.cos(angle) < 0 ? math.pi : 0),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: AppColors.surface,
                    size: 21,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}
