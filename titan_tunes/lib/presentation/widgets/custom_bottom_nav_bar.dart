import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titan_tunes/core/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CustomBottomNavBar — 5 onglets, barre glassmorphique flottante style iOS
//   Accueil / Rechercher / Découvrir / Tendances / Profil
// ─────────────────────────────────────────────────────────────────────────────
class CustomBottomNavBar extends StatelessWidget {
  final int   currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final muted   = isDark ? Colors.white.withAlpha(100) : AppColors.mutedLight;

    const items = [
      _Item(CupertinoIcons.house,           CupertinoIcons.house_fill,       'Accueil'),
      _Item(CupertinoIcons.search,          CupertinoIcons.search,            'Rechercher'),
      _Item(CupertinoIcons.compass,         CupertinoIcons.compass_fill,     'Découvrir'),
      _Item(CupertinoIcons.flame,           CupertinoIcons.flame_fill,       'Tendances'),
      _Item(CupertinoIcons.person,          CupertinoIcons.person_fill,      'Profil'),
    ];

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              height: 62,
              decoration: BoxDecoration(
                // Fond glass iOS
                color: isDark
                    ? Colors.black.withAlpha(160)
                    : Colors.white.withAlpha(200),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withAlpha(22)
                      : Colors.white.withAlpha(200),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withAlpha(100)
                        : Colors.black.withAlpha(20),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: List.generate(items.length, (i) {
                  final sel = i == currentIndex;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onTap(i),
                      behavior: HitTestBehavior.opaque,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Pastille active
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOut,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: sel ? primary.withAlpha(220) : Colors.transparent,
                              borderRadius: BorderRadius.circular(99),
                              boxShadow: sel ? [
                                BoxShadow(
                                  color: primary.withAlpha(80),
                                  blurRadius: 12, offset: const Offset(0, 4))
                              ] : null,
                            ),
                            child: Icon(
                              sel ? items[i].activeIcon : items[i].icon,
                              color: sel ? Colors.white : muted,
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: 2),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                              color: sel ? primary : muted,
                            ),
                            child: Text(items[i].label),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Item {
  final IconData icon;
  final IconData activeIcon;
  final String   label;
  const _Item(this.icon, this.activeIcon, this.label);
}
