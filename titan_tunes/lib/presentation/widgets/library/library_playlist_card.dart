import 'package:flutter/material.dart';
import 'package:titan_tunes/data/models/playlist.dart';
import 'package:titan_tunes/presentation/widgets/glassmorphism_widgets.dart';

/// Carte horizontale d'une playlist dans la liste scrollable.
class LibraryPlaylistCard extends StatelessWidget {
  final Playlist playlist;
  final bool isSelected;
  final Color primaryColor;
  final VoidCallback onTap;

  const LibraryPlaylistCard({
    super.key,
    required this.playlist,
    required this.isSelected,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 214,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? primaryColor : primaryColor.withAlpha(40),
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: GlassPanel(
          accentColor: isSelected ? primaryColor : primaryColor.withAlpha(80),
          borderRadius: BorderRadius.circular(24),
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                child: Text(
                  playlist.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: isSelected ? primaryColor : null,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                playlist.isPublic
                    ? Icons.public_rounded
                    : Icons.lock_outline_rounded,
                size: 16,
                color: primaryColor,
              ),
            ]),
            const SizedBox(height: 8),
            Text(playlist.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12)),
            const Spacer(),
            Row(children: [
              Icon(Icons.queue_music_rounded, size: 14, color: primaryColor),
              const SizedBox(width: 4),
              Text('${playlist.chansonIds.length} titres',
                style: TextStyle(
                    fontSize: 12, color: primaryColor, fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 2),
            Text('Créée le ${_fmt(playlist.createdAt)}',
              style: TextStyle(fontSize: 11, color: Theme.of(context).hintColor)),
          ]),
        ),
      ),
    );
  }

  static String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year}';
}
