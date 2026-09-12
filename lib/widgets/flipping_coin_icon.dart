import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'gold_coin_painter.dart';

/// A small cartoon coin (see [NavCoinPainter]) that continuously flips in
/// place between a profile icon and a settings icon for as long as it's on
/// screen — no tap needed to trigger it.
class FlippingCoinIcon extends StatefulWidget {
  const FlippingCoinIcon({super.key, this.size = 44});

  final double size;

  @override
  State<FlippingCoinIcon> createState() => _FlippingCoinIconState();
}

class _FlippingCoinIconState extends State<FlippingCoinIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _showingProfile = true;
  Timer? _delayTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scheduleNextFlip();
  }

  void _scheduleNextFlip() {
    _delayTimer = Timer(const Duration(seconds: 3), () async {
      if (!mounted) return;
      await _controller.forward(from: 0);
      if (!mounted) return;
      setState(() => _showingProfile = !_showingProfile);
      _controller.value = 0;
      _scheduleNextFlip();
    });
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        final showingBack = t >= 0.5;
        // Same edge-on swap trick as the auth coin flip: the jump from +90°
        // to -90° happens exactly when the coin is edge-on (invisible), so
        // it reads as one continuous rotation instead of a mirrored flip.
        final angle = math.pi * (showingBack ? t - 1 : t);
        final isProfileFace = showingBack ? !_showingProfile : _showingProfile;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0015)
            ..rotateY(angle),
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: CustomPaint(
              painter: const NavCoinPainter(),
              child: Center(
                child: Icon(
                  isProfileFace
                      ? Icons.person_outline_rounded
                      : Icons.settings_outlined,
                  color: AppColors.surface,
                  size: widget.size * 0.46,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
