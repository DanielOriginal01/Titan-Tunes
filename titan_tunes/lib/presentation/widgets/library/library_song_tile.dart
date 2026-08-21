import 'package:flutter/material.dart';
import 'package:titan_tunes/data/models/chanson.dart';
import 'package:titan_tunes/presentation/widgets/app_network_image.dart';
import 'package:titan_tunes/presentation/widgets/glassmorphism_widgets.dart';

/// Tile d'une chanson dans le détail d'une playlist.
class LibrarySongTile extends StatelessWidget {
  final Chanson song;
  final Color primaryColor;
  final VoidCallback onPlay;
  final String? subtitle;

  const LibrarySongTile({
    super.key,
    required this.song,
    required this.primaryColor,
    required this.onPlay,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final displaySubtitle = subtitle ??
        (song.artistName.isNotEmpty ? song.artistName : song.artisteId);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassPanel(
        accentColor: primaryColor,
        padding: const EdgeInsets.all(10),
        borderRadius: BorderRadius.circular(22),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: AppNetworkImage(
            url: song.coverUrl,
            width: 52,
            height: 52,
            borderRadius: BorderRadius.circular(14),
          ),
          title: Text(song.title,
              maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(
            displaySubtitle,
            maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: Container(
            decoration: BoxDecoration(
                color: primaryColor.withAlpha(20), shape: BoxShape.circle),
            child: IconButton(
              icon: Icon(Icons.play_arrow_rounded, color: primaryColor),
              onPressed: onPlay,
            ),
          ),
        ),
      ),
    );
  }
}
