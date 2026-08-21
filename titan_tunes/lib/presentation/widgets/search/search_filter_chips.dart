import 'package:flutter/material.dart';

enum SearchFilter { tous, genre, artiste, label }

/// Rangée de chips de filtre : Tous / Genre / Artiste / Label.
class SearchFilterChips extends StatelessWidget {
  final SearchFilter selected;
  final Color primary;
  final bool isDark;
  final ValueChanged<SearchFilter> onSelected;

  const SearchFilterChips({
    super.key,
    required this.selected,
    required this.primary,
    required this.isDark,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: SearchFilter.values.map((f) {
          final label = switch (f) {
            SearchFilter.tous    => 'Tous',
            SearchFilter.genre   => 'Genre',
            SearchFilter.artiste => 'Artiste',
            SearchFilter.label   => 'Label',
          };
          final icon = switch (f) {
            SearchFilter.tous    => Icons.apps_rounded,
            SearchFilter.genre   => Icons.category_outlined,
            SearchFilter.artiste => Icons.person_outline_rounded,
            SearchFilter.label   => Icons.business_outlined,
          };
          final isSelected = selected == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onSelected(f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? primary
                      : primary.withAlpha(isDark ? 30 : 18),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(
                    color: isSelected
                        ? primary
                        : primary.withAlpha(isDark ? 70 : 50),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(icon, size: 14,
                      color: isSelected ? Colors.white : primary),
                  const SizedBox(width: 6),
                  Text(label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : primary,
                    )),
                ]),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
