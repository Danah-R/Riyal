import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GoldCoinPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.gold,
            AppColors.goldDark,
            Color(0xFFC2A458),
            Color(0xFF806024),
          ],
          stops: [0, 0.35, 0.65, 1],
        ).createShader(rect),
    );
    for (var i = 0; i < 160; i++) {
      final angle = i * math.pi * 2 / 160;
      final direction = Offset(math.cos(angle), math.sin(angle));
      canvas.drawLine(
        center + direction * (radius - 7),
        center + direction * (radius - 1),
        Paint()
          ..color = (i.isEven ? AppColors.gold : AppColors.goldDark)
          ..strokeWidth = 1.5,
      );
    }
    canvas.drawCircle(
      center,
      radius - 9,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFB58B42),
            Color(0xFFC2A458),
            Color(0xFFD3BE7E),
            AppColors.gold,
            Color(0xFFC2A458),
            Color(0xFFB18A42),
          ],
          stops: [0, 0.2, 0.38, 0.64, 0.82, 1],
        ).createShader(rect),
    );
    for (final inset in [10.0, 14.0, 23.0, 26.0]) {
      canvas.drawCircle(
        center,
        radius - inset,
        Paint()
          ..color = (inset == 10 || inset == 23
              ? const Color(0xFFD3BE7E)
              : AppColors.goldDark)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
    }
    // Fine engraved diamonds around the rim.
    for (var i = 0; i < 64; i++) {
      final angle = i * math.pi * 2 / 64;
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);
      final r = radius - 19;
      final path = Path()
        ..moveTo(r - 3, 0)
        ..lineTo(r, -3)
        ..lineTo(r + 3, 0)
        ..lineTo(r, 3)
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..color = AppColors.goldDark.withValues(alpha: 0.65)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.7,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant GoldCoinPainter oldDelegate) => false;
}

/// A small, flat-shaded "cartoon coin" treatment for icon-sized circles
/// (e.g. the nav bar's floating action button) — solid fill colors and
/// chunky rim notches outlined in a soft bronze, not black. Deliberately
/// avoids the metallic gradient shine [GoldCoinPainter] uses for the big
/// auth-screen coin; at ~50px that shine just reads as a blurry glow, and
/// flat cel-shading reads clearer at this size anyway.
class NavCoinPainter extends CustomPainter {
  const NavCoinPainter();

  static const _outline = Color(0xFFB08D4C);
  static const _rim = Color(0xFFE3C989);
  static const _face = AppColors.gold;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;

    // Outer rim, flat fill + bold outline.
    canvas.drawCircle(center, radius, Paint()..color = _rim);
    canvas.drawCircle(
      center,
      radius - 1.2,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..color = _outline,
    );

    // Chunky, evenly-spaced ridge notches — flat color, no shading.
    const tickCount = 16;
    final tickInner = radius * 0.86;
    final tickOuter = radius - 1.6;
    for (var i = 0; i < tickCount; i++) {
      final angle = i * math.pi * 2 / tickCount;
      final direction = Offset(math.cos(angle), math.sin(angle));
      canvas.drawLine(
        center + direction * tickInner,
        center + direction * tickOuter,
        Paint()
          ..color = _outline
          ..strokeWidth = 2.6
          ..strokeCap = StrokeCap.round,
      );
    }

    // Inner face, flat fill + bold outline separating it from the rim.
    final faceRadius = radius * 0.78;
    canvas.drawCircle(center, faceRadius, Paint()..color = _face);
    canvas.drawCircle(
      center,
      faceRadius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..color = _outline,
    );
  }

  @override
  bool shouldRepaint(covariant NavCoinPainter oldDelegate) => false;
}
