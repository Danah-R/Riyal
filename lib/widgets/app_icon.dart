import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppIcon extends StatelessWidget {
  const AppIcon({super.key, required this.assetPath, this.size = 40});

  final String assetPath;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.28),
      child: SvgPicture.asset(
        assetPath,
        width: size,
        height: size,
      ),
    );
  }
}
