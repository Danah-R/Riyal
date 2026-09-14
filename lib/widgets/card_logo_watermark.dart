import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_theme.dart';

/// Which corner of the card the watermark leans into.
enum WatermarkCorner { topEnd, bottomEnd }

/// A large, barely-there riyal watermark tucked into a corner of a big
/// card's background — the same technique the login/signup coin already
/// uses (see [AuthCoinFlip]'s big translucent riyal symbol), reused here
/// as a quiet brand touch on hero cards throughout the app. Purely
/// decorative: wrapped in [ExcludeSemantics] and ignored for hit-testing.
///
/// Place as the first child of a [Stack] inside a card whose outer
/// [Container]/[DecoratedBox] has `clipBehavior: Clip.antiAlias` set, so
/// the watermark's overflow gets clipped to the card's rounded corners.
class CardLogoWatermark extends StatelessWidget {
  const CardLogoWatermark({
    super.key,
    this.corner = WatermarkCorner.bottomEnd,
    this.size = 130,
    this.opacity = 0.06,
  });

  final WatermarkCorner corner;
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final offset = -size * 0.22;
    return Positioned(
      top: corner == WatermarkCorner.topEnd ? offset : null,
      bottom: corner == WatermarkCorner.bottomEnd ? offset : null,
      right: offset,
      child: IgnorePointer(
        child: ExcludeSemantics(
          child: Opacity(
            opacity: opacity,
            child: SvgPicture.asset(
              'assets/icons/saudi_riyal.svg',
              width: size,
              colorFilter: const ColorFilter.mode(
                AppColors.textPrimary,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
