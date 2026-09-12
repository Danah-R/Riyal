import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_theme.dart';

/// Renders a subscription/bill/staff-role "logo" tile: a real image asset
/// (SVG or raster) on a white backing, or — when there's no photo, as for
/// most utility providers and every staff role — a colored circle with a
/// Material icon instead.
class LogoImage extends StatelessWidget {
  const LogoImage({
    super.key,
    this.assetPath,
    this.icon,
    this.iconColor,
    this.size = 44,
    this.radius,
  });

  final String? assetPath;
  final IconData? icon;
  final Color? iconColor;
  final double size;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final path = assetPath;
    if (path == null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius ?? size * 0.28),
        child: Container(
          width: size,
          height: size,
          color: iconColor ?? AppColors.trackBackground,
          child: Icon(
            icon ?? Icons.apps_rounded,
            color: AppColors.textPrimary,
            size: size * 0.52,
          ),
        ),
      );
    }

    final content = path.toLowerCase().endsWith('.svg')
        ? SvgPicture.asset(
            path,
            fit: BoxFit.cover,
            placeholderBuilder: (_) => _fallbackIcon(),
          )
        : Image.asset(
            path,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _fallbackIcon(),
          );

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius ?? size * 0.28),
      child: Container(
        width: size,
        height: size,
        color: Colors.white,
        child: content,
      ),
    );
  }

  Widget _fallbackIcon() {
    return const Icon(Icons.apps_rounded, color: AppColors.trackBackground);
  }
}
