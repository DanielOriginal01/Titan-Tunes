import 'package:flutter/material.dart';
import 'package:titan_tunes/data/models/chanson.dart';
import 'package:titan_tunes/presentation/widgets/app_network_image.dart';
import 'package:titan_tunes/providers/audio_provider.dart';

// ── Onglet Paroles ────────────────────────────────────────────────────────────
class LyricsTab extends StatelessWidget {
  final Chanson chanson;
  final Color fg;
  const LyricsTab({super.key, required this.chanson, required this.fg});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    physics: const BouncingScrollPhysics(),
    padding: const EdgeInsets.fromLTRB(22, 14, 22, 100),
    child: Text(
      chanson.lyrics.isNotEmpty
          ? chanson.lyrics
          : 'Aucune parole disponible pour ce morceau.',
      style: TextStyle(
        fontSize: 15,
        color: fg.withAlpha(200),
        height: 1.85,
        fontStyle: FontStyle.italic,
      ),
    ),
  );
}

// ── Onglet File d'attente ─────────────────────────────────────────────────────
class QueueTab extends StatelessWidget {
  final Chanson chanson;
  final AudioProvider provider;
  final Color primary;
  final Color fg;
  final Color muted;

  const QueueTab({
    super.key,
    required this.chanson,
    required this.provider,
    required this.primary,
    required this.fg,
    required this.muted,
  });

  @override
  Widget build(BuildContext context) => ListView.builder(
    physics: const BouncingScrollPhysics(),
    padding: const EdgeInsets.symmetric(vertical: 6),
    itemCount: provider.chansons.length,
    itemBuilder: (_, i) {
      final s = provider.chansons[i];
      final current = s.id == chanson.id;
      return ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
        leading: AppNetworkImage(
          url: s.coverUrl,
          width: 40,
          height: 40,
          borderRadius: BorderRadius.circular(8),
        ),
        title: Text(
          s.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: current ? primary : fg,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          s.artistName,
          style: TextStyle(fontSize: 11, color: muted),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: current
            ? Icon(Icons.equalizer_rounded, color: primary, size: 20)
            : null,
        onTap: () => provider.playChanson(s),
      );
    },
  );
}
