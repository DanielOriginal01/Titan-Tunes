import 'package:flutter/material.dart';

/// Grille 2 colonnes de tuiles genres colorées.
class SearchGenreGrid extends StatelessWidget {
  final bool isDark;
  final ValueChanged<String> onGenreTap;

  static const List<Map<String, Object>> genreTiles = [
    {'label': 'Afrobeat',     'color': Color(0xFF7B2FBE)},
    {'label': 'Hip-Hop',      'color': Color(0xFFD84315)},
    {'label': 'Gospel',       'color': Color(0xFF1565C0)},
    {'label': 'Pop',          'color': Color(0xFFF9A825)},
    {'label': 'Jazz',         'color': Color(0xFF4E342E)},
    {'label': 'Electro',      'color': Color(0xFF1B5E20)},
    {'label': 'Coupé-Décalé', 'color': Color(0xFFAD1457)},
    {'label': 'Highlife',     'color': Color(0xFF00695C)},
  ];

  const SearchGenreGrid({
    super.key,
    required this.isDark,
    required this.onGenreTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.2,
      children: genreTiles.map((genre) {
        final lbl = genre['label'] as String;
        final col = genre['color'] as Color;
        return GestureDetector(
          onTap: () => onGenreTap(lbl),
          child: Container(
            decoration: BoxDecoration(
              color: col.withAlpha(isDark ? 40 : 22),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: col.withAlpha(isDark ? 80 : 60)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
            child: Row(children: [
              Container(
                width: 10, height: 10,
                decoration: BoxDecoration(color: col, shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(lbl,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: col,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ]),
          ),
        );
      }).toList(),
    );
  }
}
