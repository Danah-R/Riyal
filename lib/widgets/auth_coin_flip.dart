import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Both authentication screens are faces of the same coin.
class AuthCoinFlip extends StatelessWidget {
  const AuthCoinFlip({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'authentication-coin',
      placeholderBuilder: (context, size, child) =>
          SizedBox(width: size.width, height: size.height),
      flightShuttleBuilder: (flightContext, animation, direction, from, to) {
        final front = (from.widget as Hero).child;
        final back = (to.widget as Hero).child;
        final reduceMotion = MediaQuery.disableAnimationsOf(flightContext);
        // Hero's flight animation is already curved differently on push/pop.
        // Drive rotation from the route clock so both directions use one curve.
        final routeContext = direction == HeroFlightDirection.push ? to : from;
        final rotationAnimation =
            ModalRoute.of(routeContext)?.animation ?? animation;
        return AnimatedBuilder(
          animation: rotationAnimation,
          builder: (context, _) {
            final progress = direction == HeroFlightDirection.push
                ? rotationAnimation.value
                : 1 - rotationAnimation.value;
            final t = Curves.easeInOutSine.transform(progress.clamp(0.0, 1.0));
            final showBack = t >= 0.5;
            // Swap faces edge-on, then keep the reverse face readable.
            final angle = reduceMotion ? 0.0 : math.pi * (showBack ? t - 1 : t);
            return IgnorePointer(
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0015)
                  ..rotateY(angle),
                child: Material(
                  type: MaterialType.transparency,
                  child: showBack ? back : front,
                ),
              ),
            );
          },
        );
      },
      child: child,
    );
  }
}

Route<void> authCoinRoute(Widget page) {
  return PageRouteBuilder<void>(
    transitionDuration: const Duration(milliseconds: 1200),
    reverseTransitionDuration: const Duration(milliseconds: 1200),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        child,
  );
}
