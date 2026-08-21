import 'package:flutter/material.dart';

/// Petite carte stat (Playlists / Titres).
class LibraryStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const LibraryStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withAlpha(55)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(color: theme.hintColor, fontSize: 12)),
        const SizedBox(height: 6),
        Text(value,
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.w900, color: color)),
      ]),
    );
  }
}

/// Chip de filtre (Toutes / Publiques / Privées).
class LibraryFilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final Color primaryColor;
  final VoidCallback onTap;

  const LibraryFilterChip({
    super.key,
    required this.label,
    required this.count,
    required this.selected,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: selected
          ? primaryColor.withAlpha(35)
          : theme.colorScheme.surface.withAlpha(130),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(label,
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: selected ? primaryColor : null)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: primaryColor.withAlpha(25),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text('$count',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: primaryColor)),
            ),
          ]),
        ),
      ),
    );
  }
}
