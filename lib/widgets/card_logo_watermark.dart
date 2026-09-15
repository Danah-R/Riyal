import 'package:flutter/material.dart';

/// Which corner of the card the watermark leans into.
enum WatermarkCorner { topEnd, bottomEnd }

/// A large, barely-there watermark of the actual Riyal app icon tucked
/// into a corner of a big card's background — a quiet brand touch on hero
/// cards throughout the app. Purely decorative: wrapped in
/// [ExcludeSemantics] and ignored for hit-testing.
///
/// Unlike a flat monochrome icon, [assets/icon/app_icon.png] is a full
/// color image with no transparency, so it's shown at low opacity as-is
/// rather than tinted with a [ColorFilter] (which would just flatten it
/// into a solid block).
///
/// Sits flush in the card's corner — place as the first (unpadded) child
/// of a [Stack] whose sibling content carries its own [Padding], and
/// whose enclosing [Container] has `clipBehavior: Clip.antiAlias` set, so
/// only the very tip of the coin gets clipped by the card's own rounded
/// corner (not sliced by a straight edge, and not floating inset from
/// the sides either).
class CardLogoWatermark extends StatelessWidget {
  const CardLogoWatermark({
    super.key,
    this.corner = WatermarkCorner.bottomEnd,
    this.size = 130,
    this.opacity = 0.1,
  });

  final WatermarkCorner corner;
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    const offset = 0.0;
    return Positioned(
      top: corner == WatermarkCorner.topEnd ? offset : null,
      bottom: corner == WatermarkCorner.bottomEnd ? offset : null,
      right: offset,
      child: IgnorePointer(
        child: ExcludeSemantics(
          child: Opacity(
            opacity: opacity,
            // A circular clip would leave the corners of this square empty
            // (a circle never reaches a square's corners) instead of
            // filling the watermark's full bounds, so this stays a plain
            // (softly rounded) square — zoomed in enough that the app
            // icon's own background/border falls outside the crop
            // entirely, leaving just the coin filling every edge.
            child: ClipRRect(
              borderRadius: BorderRadius.circular(size * 0.16),
              child: SizedBox(
                width: size,
                height: size,
                child: Transform.scale(
                  scale: 2.2,
                  child: Image.asset(
                    'assets/icon/app_icon.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
