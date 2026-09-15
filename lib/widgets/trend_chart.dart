import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../theme/app_theme.dart';

/// A line/area chart over a series of amounts, oldest to newest — the same
/// hand-rolled painting approach as analytics_screen.dart's `_TrendPainter`
/// (this app has no charting package dependency), pulled out into a
/// reusable widget so the subscription/utility details pages can each show
/// their own history without a new dependency or a duplicated painter.
class TrendChart extends StatelessWidget {
  const TrendChart({
    super.key,
    required this.values,
    this.color = AppColors.gold,
    this.height = 140,
  });

  /// Oldest first, newest last.
  final List<double> values;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (values.length < 2) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            Strings.t('not_enough_history'),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
      );
    }
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(painter: _TrendChartPainter(values, color)),
    );
  }
}

class _TrendChartPainter extends CustomPainter {
  _TrendChartPainter(this.values, this.color);
  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final highest = values.reduce(math.max).abs();
    final maxValue = highest <= 0
        ? 1.0
        : (highest / 500).ceil() * 500.0;
    final height = size.height - 24;
    final width = size.width - 48;
    for (var i = 0; i <= 2; i++) {
      final y = 12 + height * i / 2;
      canvas.drawLine(
        Offset(42, y),
        Offset(size.width, y),
        Paint()
          ..color = AppColors.cardBorder
          ..strokeWidth = 0.6,
      );
      final label = TextPainter(
        text: TextSpan(
          text: (maxValue * (1 - i / 2)).toStringAsFixed(0),
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      label.paint(canvas, Offset(0, y - 6));
    }
    final points = List.generate(
      values.length,
      (i) => Offset(
        42 + width * i / (values.length - 1),
        12 + height * (1 - values[i] / maxValue),
      ),
    );
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    final area = Path.from(path)
      ..lineTo(points.last.dx, size.height - 12)
      ..lineTo(points.first.dx, size.height - 12)
      ..close();
    canvas.drawPath(
      area,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.22), color.withValues(alpha: 0)],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeJoin = StrokeJoin.round,
    );
    for (final p in points) {
      canvas.drawCircle(p, 4, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(covariant _TrendChartPainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.color != color;
}
