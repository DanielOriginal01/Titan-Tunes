import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:titan_tunes/presentation/widgets/glassmorphism_widgets.dart';
import 'package:titan_tunes/presentation/widgets/library/library_song_tile.dart';
import 'package:titan_tunes/providers/audio_provider.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AudioProvider>();
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Historique d\'écoute',
            style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (provider.history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: 'Effacer l\'historique',
              onPressed: () => _confirmClearHistory(context, provider),
            ),
        ],
      ),
      body: SafeArea(
        child: PageBackground(
          child: provider.history.isEmpty
              ? Center(
                  child: GlassPanel(
                    accentColor: primaryColor,
                    child: const Text('Aucun titre écouté récemment.'),
                  ),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  itemCount: provider.history.length,
                  itemBuilder: (context, index) {
                    final item = provider.history[index];
                    return Dismissible(
                      key: Key(item.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Colors.redAccent.withAlpha(50),
                        child: const Icon(Icons.delete_rounded, color: Colors.white),
                      ),
                      onDismissed: (_) => provider.removeHistoryItem(item.id),
                      child: LibrarySongTile(
                        song: item.chanson,
                        primaryColor: primaryColor,
                        onPlay: () => provider.playChanson(item.chanson),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  void _confirmClearHistory(BuildContext context, AudioProvider provider) {
    showDialog(
      context: context,
      builder: (dlg) => AlertDialog(
        title: const Text('Effacer l\'historique'),
        content: const Text('Voulez-vous vraiment effacer tout votre historique d\'écoute ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dlg),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              provider.clearHistory();
              Navigator.pop(dlg);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Effacer'),
          ),
        ],
      ),
    );
  }
}