import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Titan Tunes — Palette de couleurs
//
// Thème CLAIR  : Titan Orange #FF6B00 + Ambre #F59E0B + fond blanc chaud #FAFAF9
// Thème SOMBRE : Bleu Titan #1E5EFF (inchangé) + surfaces sombres #0F0F13
// ─────────────────────────────────────────────────────────────────────────────
class AppColors {
  // ── Logos ─────────────────────────────────────────────────────────────────
  static const Color logoOrange = Color(0xFFFF6B00);
  static const Color logoBlue   = Color(0xFF1E5EFF);

  // ── Primaire par thème ────────────────────────────────────────────────────
  /// Clair : Orange éclatant Titan #FF6B00
  static const Color primaryLight  = Color(0xFFFF6B00);
  /// Sombre : Bleu logo Titan #1E5EFF (inchangé)
  static const Color primaryDark   = Color(0xFF1E5EFF);

  // ── Accents thème clair ───────────────────────────────────────────────────
  static const Color orangeDark    = Color(0xFFE55A00);  // nuance orange foncé
  static const Color orangeLight   = Color(0xFFFF8533);  // nuance orange clair
  static const Color orange100     = Color(0xFFFFEDD5);  // surface orange tintée
  static const Color orange50      = Color(0xFFFFF7ED);  // fond chaud
  static const Color amber         = Color(0xFFF59E0B);  // accent chaud
  static const Color teal          = Color(0xFF0D9488);  // secondaire équilibré
  static const Color rose          = Color(0xFFE11D48);  // erreur / favoris

  // ── Accents thème sombre ──────────────────────────────────────────────────
  static const Color accentSkyBlue    = Color(0xFF4F8EFF);
  static const Color accentDeepOrange = Color(0xFFFF6B00);

  // ── Backgrounds ───────────────────────────────────────────────────────────
  static const Color bgLight      = Color(0xFFF8F9FA);  // fond clair moderne
  static const Color bgDark       = Color(0xFF0F0F13);  // noir quasi-pur
  static const Color cardLight    = Color(0xFFFFFFFF);
  static const Color cardDark     = Color(0xFF1C1C24);
  static const Color surfaceDark2 = Color(0xFF252530);

  // ── Textes ────────────────────────────────────────────────────────────────
  static const Color textLight   = Color(0xFF18181B);
  static const Color textDark    = Color(0xFFFAFAFA);
  static const Color mutedLight  = Color(0xFF71717A);
  static const Color mutedDark   = Color(0xFF9E9EA7);

  // ── Dividers ──────────────────────────────────────────────────────────────
  static const Color divider     = Color(0xFFE4E4E7);
  static const Color dividerDark = Color(0xFF27272A);

  // ── Glass iOS ────────────────────────────────────────────────────────────
  static const Color glassBgLight     = Color(0xDDFFFFFF);
  static const Color glassBgDark      = Color(0xDD1C1C24);
  static const Color glassBorderLight = Color(0x33FFFFFF);
  static const Color glassBorderDark  = Color(0x22FFFFFF);

  // ── Rétrocompatibilité ─────────────────────────────────────────────────────
  static const Color primaryBlue     = logoBlue;
  static const Color accentOrange    = logoOrange;
  static const Color accentBlue      = logoBlue;
  static const Color darkAccentGreen = Color(0xFFB9E73B);
  static const Color black           = textLight;
  static const Color darkSurface     = bgDark;
  static const Color darkCard        = cardDark;
  static const Color white           = Color(0xFFFFFFFF);
  static const Color lightSurface    = bgLight;
  static const Color lightCard       = cardLight;
  static const Color lightGrey       = divider;
  static const Color mediumGrey      = mutedLight;
  static const Color softOrange      = Color(0xFFFFF7ED);
  static const Color softBlue        = Color(0xFFEFF6FF);
}

// ─────────────────────────────────────────────────────────────────────────────
class AppTheme {
  static ThemeData buildTheme({
    required Brightness brightness,
    Color? primaryColor,
    Color? accentColor,
  }) {
    final isDark  = brightness == Brightness.dark;
    final primary = primaryColor ?? (isDark ? AppColors.primaryDark : AppColors.primaryLight);
    final accent  = accentColor  ?? (isDark ? AppColors.accentSkyBlue : AppColors.amber);
    final bg      = isDark ? AppColors.bgDark    : AppColors.bgLight;
    final card    = isDark ? AppColors.cardDark  : AppColors.cardLight;
    final onBg    = isDark ? AppColors.textDark  : AppColors.textLight;

    final scheme = ColorScheme.fromSeed(
      seedColor:  primary,
      brightness: brightness,
    ).copyWith(
      primary:      primary,
      onPrimary:    Colors.white,
      secondary:    accent,
      onSecondary:  Colors.white,
      tertiary:     isDark ? AppColors.accentSkyBlue : AppColors.amber,
      surface:      bg,
      onSurface:    onBg,
      outline:      isDark ? AppColors.dividerDark : AppColors.divider,
      error:        AppColors.rose,
    );

    return ThemeData(
      useMaterial3: true,
      brightness:   brightness,
      colorScheme:  scheme,
      scaffoldBackgroundColor: bg,
      primaryColor: primary,

      // ── AppBar ─────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: onBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 17, fontWeight: FontWeight.w700, color: onBg),
        iconTheme: IconThemeData(color: onBg),
      ),

      // ── Cards ──────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),

      // ── Dividers ───────────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: isDark ? AppColors.dividerDark : AppColors.divider,
        thickness: 0.6,
        space: 0,
      ),

      // ── Inputs ─────────────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.surfaceDark2 : AppColors.orange100.withAlpha(80),
        hintStyle: TextStyle(
            color: isDark ? AppColors.mutedDark : AppColors.mutedLight,
            fontSize: 14),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
              color: isDark ? AppColors.dividerDark : AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
              color: isDark ? AppColors.dividerDark : AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primary, width: 1.8),
        ),
      ),

      // ── Texte ──────────────────────────────────────────────────────────────
      textTheme: (isDark
              ? Typography.material2021().white
              : Typography.material2021().black)
          .apply(bodyColor: onBg, displayColor: onBg),

      // ── Icônes ─────────────────────────────────────────────────────────────
      iconTheme: IconThemeData(
        color: isDark ? AppColors.mutedDark : AppColors.mutedLight,
      ),

      // ── Boutons ────────────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary.withAlpha(160)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primary),
      ),

      // ── Chips ──────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: primary.withAlpha(15),
        selectedColor: primary,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        side: BorderSide(color: primary.withAlpha(50)),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),

      // ── Progress ───────────────────────────────────────────────────────────
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: primary.withAlpha(25),
      ),

      // ── Switch ─────────────────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? primary
              : AppColors.mutedLight,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? primary.withAlpha(80)
              : AppColors.mutedLight.withAlpha(40),
        ),
      ),

      // ── Slider ─────────────────────────────────────────────────────────────
      sliderTheme: SliderThemeData(
        activeTrackColor: primary,
        inactiveTrackColor: primary.withAlpha(25),
        thumbColor: primary,
        overlayColor: primary.withAlpha(25),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
      ),

      // ── BottomNav ──────────────────────────────────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: primary,
        unselectedItemColor:
            isDark ? AppColors.mutedDark : AppColors.mutedLight,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle:
            const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
      ),

      // ── ListTile ───────────────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: Colors.transparent,
      ),
    );
  }

  static ThemeData lightTheme = buildTheme(brightness: Brightness.light);
  static ThemeData darkTheme  = buildTheme(brightness: Brightness.dark);
}
