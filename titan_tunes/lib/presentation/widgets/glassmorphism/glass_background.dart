import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:titan_tunes/core/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PageBackground — fond dégradé avec orbes lumineux floutés
// ─────────────────────────────────────────────────────────────────────────────
class PageBackground extends StatelessWidget {
  final Widget child;
  const PageBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final primary   = Theme.of(context).colorScheme.primary;
    final secondary = Theme.of(context).colorScheme.secondary;

    final bgColors = isDark
        ? [AppColors.bgDark, const Color(0xFF13131E), const Color(0xFF0F0F18)]
        : [AppColors.bgLight, const Color(0xFFF5F0FF), const Color(0xFFF0FDFA)];

    return Stack(fit: StackFit.expand, children: [
      Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: bgColors,
          ),
        ),
      ),
      Positioned(top: -80, left: -60,
          child: GlowOrb(size: 260, color: primary.withAlpha(isDark ? 55 : 38))),
      Positioned(top: 100, right: -70,
          child: GlowOrb(size: 200, color: secondary.withAlpha(isDark ? 45 : 30))),
      Positioned(bottom: -90, left: 30,
          child: GlowOrb(size: 280, color: primary.withAlpha(isDark ? 35 : 22))),
      Positioned.fill(child: child),
    ]);
  }
}

/// Orbe lumineux flouté décoratif.
class GlowOrb extends StatelessWidget {
  final double size;
  final Color  color;
  const GlowOrb({super.key, required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
        child: Container(
          width: size, height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color, color.withAlpha(0)],
              stops: const [0.1, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}
