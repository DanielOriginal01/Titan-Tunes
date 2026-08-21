import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:titan_tunes/data/models/chanson.dart';
import 'package:titan_tunes/presentation/widgets/glassmorphism_widgets.dart';
import 'package:titan_tunes/presentation/widgets/library/library_song_tile.dart';
import 'package:titan_tunes/providers/audio_provider.dart';

class DownloadsPage extends StatelessWidget {
  const DownloadsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AudioProvider>();
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    final totalSize = provider.downloads.fold<int>(
      0,
      (sum, item) => sum + item.sizeBytes,
    );
    final totalSizeMb = totalSize / (1024 * 1024);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Téléchargements',
            style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: PageBackground(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            children: [
              GlassPanel(
                accentColor: primaryColor,
                child: Row(
                  children: [
                    Icon(Icons.sd_storage_rounded, color: primaryColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Stockage utilisé',
                            style: theme.textTheme.bodySmall,
                          ),
                          Text(
                            '${totalSizeMb.toStringAsFixed(1)} MB (${provider.downloads.length} titres)',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              if (provider.downloads.isEmpty)
                GlassPanel(
                  accentColor: primaryColor,
                  child: const Text('Aucun titre téléchargé en local.'),
                )
              else
                ...provider.downloads.map((item) {
                  final chanson = provider.chansons.firstWhere(
                    (c) => c.id == item.chansonId,
                    orElse: () => Chanson.empty().copyWith(
                      id: item.chansonId,
                      title: item.titre,
                      artistName: item.artisteName,
                      coverUrl: item.coverUrl,
                    ),
                  );
                  final daysLeft = item.daysRemaining;
                  return Dismissible(
                    key: Key(item.chansonId),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: Colors.redAccent.withAlpha(50),
                      child: const Icon(Icons.delete_forever_rounded, color: Colors.white),
                    ),
                    onDismissed: (_) => provider.removeDownload(item.chansonId),
                    child: LibrarySongTile(
                      song: chanson,
                      primaryColor: primaryColor,
                      subtitle: '$daysLeft jour(s) restant(s)',
                      onPlay: () => provider.playChanson(chanson),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}
