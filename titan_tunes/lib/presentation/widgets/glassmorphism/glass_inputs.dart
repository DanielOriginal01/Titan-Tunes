import 'package:flutter/material.dart';
import 'package:titan_tunes/core/app_theme.dart';
import 'package:titan_tunes/presentation/widgets/glassmorphism/glass_panel.dart';

// ─────────────────────────────────────────────────────────────────────────────
// GlassTextField
// ─────────────────────────────────────────────────────────────────────────────
class GlassTextField extends StatelessWidget {
  final TextEditingController controller;
  final String            hint;
  final IconData          icon;
  final bool              obscureText;
  final Widget?           suffixIcon;
  final String?           prefixText;
  final TextInputType?    keyboardType;

  const GlassTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText  = false,
    this.suffixIcon,
    this.prefixText,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final fg      = isDark ? Colors.white : AppColors.textLight;
    final mutedFg = fg.withAlpha(isDark ? 140 : 160);

    return GlassPanel(
      borderRadius: BorderRadius.circular(20),
      accentColor: primary,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: TextField(
        controller:     controller,
        obscureText:    obscureText,
        keyboardType:   keyboardType,
        style: TextStyle(color: fg, fontSize: 15),
        decoration: InputDecoration(
          hintText:          hint,
          hintStyle:         TextStyle(color: mutedFg, fontSize: 15),
          prefixIcon:        Icon(icon, color: primary, size: 20),
          prefixText:        prefixText,
          suffixIcon:        suffixIcon,
          filled:            false,
          border:            InputBorder.none,
          enabledBorder:     InputBorder.none,
          focusedBorder:     InputBorder.none,
          contentPadding:    const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GlassPrimaryButton
// ─────────────────────────────────────────────────────────────────────────────
class GlassPrimaryButton extends StatelessWidget {
  final String       label;
  final VoidCallback onPressed;
  const GlassPrimaryButton(
      {super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:  primary,
          foregroundColor:  Colors.white,
          minimumSize:      const Size.fromHeight(52),
          elevation:        0,
          shadowColor:      primary.withAlpha(60),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(label,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GlassOutlinedButton
// ─────────────────────────────────────────────────────────────────────────────
class GlassOutlinedButton extends StatelessWidget {
  final String       label;
  final Widget       icon;
  final VoidCallback onPressed;
  const GlassOutlinedButton(
      {super.key, required this.label, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return SizedBox(
      height: 50,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: icon, label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary.withAlpha(160), width: 1.4),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GlassActionTile
// ─────────────────────────────────────────────────────────────────────────────
class GlassActionTile extends StatelessWidget {
  final IconData icon;
  final String   label;
  final Color?   iconColor;
  final String?  imageUrl;
  const GlassActionTile({
    super.key, required this.icon, required this.label,
    this.iconColor, this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return GlassPanel(
      padding: const EdgeInsets.all(14),
      borderRadius: BorderRadius.circular(20),
      child: Row(children: [
        if (imageUrl != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(imageUrl!,
              width: 40, height: 40, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Icon(icon, color: iconColor ?? primary)))
        else
          Icon(icon, color: iconColor ?? primary),
        const SizedBox(width: 12),
        Expanded(child: Text(label)),
      ]),
    );
  }
}
