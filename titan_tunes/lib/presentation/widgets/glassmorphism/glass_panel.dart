import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:titan_tunes/core/app_theme.dart';

const double _kBlurLight  = 24.0;
const double _kBlurDark   = 22.0;
const int    _kAlphaLight = 200;
const int    _kAlphaDark  = 185;

// ─────────────────────────────────────────────────────────────────────────────
// GlassPanel — panneau glass style iOS
// ─────────────────────────────────────────────────────────────────────────────
class GlassPanel extends StatelessWidget {
  final Widget                 child;
  final EdgeInsetsGeometry     padding;
  final EdgeInsetsGeometry     margin;
  final BorderRadius           borderRadius;
  final Color?                 accentColor;
  final double?                blurSigma;

  const GlassPanel({
    super.key,
    required this.child,
    this.padding      = const EdgeInsets.all(18),
    this.margin       = EdgeInsets.zero,
    this.borderRadius = const BorderRadius.all(Radius.circular(26)),
    this.accentColor,
    this.blurSigma,
  });

  @override
  Widget build(BuildContext context) {
    final isDark     = Theme.of(context).brightness == Brightness.dark;
    final primary    = accentColor ?? Theme.of(context).colorScheme.primary;
    final sigma      = blurSigma ?? (isDark ? _kBlurDark : _kBlurLight);
    final glassColor = isDark
        ? AppColors.glassBgDark.withAlpha(_kAlphaDark)
        : AppColors.glassBgLight.withAlpha(_kAlphaLight);
    final nacreColor = isDark
        ? Colors.white.withAlpha(20)
        : Colors.white.withAlpha(180);

    return Padding(
      padding: margin,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: glassColor,
              borderRadius: borderRadius,
              border: Border.all(color: nacreColor, width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: primary.withAlpha(isDark ? 18 : 12),
                  blurRadius: 24, offset: const Offset(0, 8)),
                BoxShadow(
                  color: Colors.black.withAlpha(isDark ? 30 : 10),
                  blurRadius: 1, offset: const Offset(0, 1),
                  spreadRadius: -1),
              ],
            ),
            child: Material(color: Colors.transparent, child: child),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GlassCard — variante légère (moins de blur)
// ─────────────────────────────────────────────────────────────────────────────
class GlassCard extends StatelessWidget {
  final Widget                 child;
  final EdgeInsetsGeometry     padding;
  final BorderRadius?          borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding      = const EdgeInsets.all(14),
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final br = borderRadius ?? BorderRadius.circular(20);
    return ClipRRect(
      borderRadius: br,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withAlpha(12)
                : Colors.white.withAlpha(160),
            borderRadius: br,
            border: Border.all(
              color: isDark
                  ? Colors.white.withAlpha(18)
                  : Colors.white.withAlpha(200),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
