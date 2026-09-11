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
            Color(0xFFFFEBA5),
            AppColors.goldDark,
            Color(0xFFFFE8A1),
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
          ..color = (i.isEven ? const Color(0xFFFFE6A0) : AppColors.goldDark)
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
            Color(0xFFFFE7A0),
            Color(0xFFFFF4CF),
            AppColors.gold,
            Color(0xFFF0D48F),
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
              ? const Color(0xFFFFF1BA)
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
