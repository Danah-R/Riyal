import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_theme.dart';
import '../widgets/gold_coin_painter.dart';
import '../widgets/hero_tags.dart';
import 'main_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) _goHome();
    });
  }

  Future<void> _goHome() async {
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 550),
        pageBuilder: (_, _, _) => const MainShell(),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final t = _controller.value;

              final coinFade = Interval(
                0,
                0.18,
                curve: Curves.easeOut,
              ).transform(t.clamp(0, 1));
              final coinScale = Interval(
                0,
                0.32,
                curve: Curves.easeOutBack,
              ).transform(t.clamp(0, 1));
              final coinSettle = Interval(
                0,
                0.42,
                curve: Curves.easeOutCubic,
              ).transform(t.clamp(0, 1));
              final tiltAngle = (1 - coinSettle) * -0.5;

              final orbitFadeIn = Interval(
                0.12,
                0.34,
                curve: Curves.easeOut,
              ).transform(t.clamp(0, 1));
              final orbitFadeOut = Interval(
                0.5,
                0.68,
                curve: Curves.easeIn,
              ).transform(t.clamp(0, 1));
              final orbitOpacity = orbitFadeIn * (1 - orbitFadeOut);
              final orbitRotation = t * math.pi * 0.7;

              final titleT = Interval(
                0.5,
                0.72,
                curve: Curves.easeOut,
              ).transform(t.clamp(0, 1));
              final taglineT = Interval(
                0.68,
                0.9,
                curve: Curves.easeOut,
              ).transform(t.clamp(0, 1));

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 220,
                    height: 220,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Opacity(
                          opacity: orbitOpacity,
                          child: CustomPaint(
                            size: const Size(220, 220),
                            painter: _OrbitPainter(rotation: orbitRotation),
                          ),
                        ),
                        Opacity(
                          opacity: coinFade,
                          child: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.0025)
                              ..rotateY(tiltAngle),
                            child: Transform.scale(
                              scale: coinScale,
                              child: Hero(
                                tag: heroAppCoinTag,
                                child: SizedBox(
                                  width: 132,
                                  height: 132,
                                  child: CustomPaint(
                                    painter: const NavCoinPainter(),
                                    child: Center(
                                      child: SvgPicture.asset(
                                        'assets/icons/saudi_riyal.svg',
                                        width: 132 * 0.4,
                                        colorFilter: const ColorFilter.mode(
                                          AppColors.surface,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Opacity(
                    opacity: titleT,
                    child: Transform.translate(
                      offset: Offset(0, (1 - titleT) * 12),
                      child: const Text(
                        'R I Y A L',
                        style: TextStyle(
                          color: AppColors.gold,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 6,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Opacity(
                    opacity: taglineT,
                    child: Transform.translate(
                      offset: Offset(0, (1 - taglineT) * 10),
                      child: const Text(
                        'Know where your money goes.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Faint, slowly-rotating orbit rings with a single marker dot each —
/// evokes recurring payments cycling around the coin without ever reading
/// as decoration-heavy.
class _OrbitPainter extends CustomPainter {
  const _OrbitPainter({required this.rotation});

  final double rotation;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final rings = [
      (radius: size.shortestSide * 0.36, alpha: 0.22, spin: 1.0),
      (radius: size.shortestSide * 0.47, alpha: 0.14, spin: -0.7),
    ];

    for (final ring in rings) {
      canvas.drawCircle(
        center,
        ring.radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.1
          ..color = AppColors.gold.withValues(alpha: ring.alpha),
      );

      final angle = rotation * ring.spin;
      final markerCenter =
          center + Offset(math.cos(angle), math.sin(angle)) * ring.radius;
      canvas.drawCircle(
        markerCenter,
        2.6,
        Paint()..color = AppColors.gold.withValues(alpha: ring.alpha * 3.2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) =>
      oldDelegate.rotation != rotation;
}
