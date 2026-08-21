import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:titan_tunes/data/models/chanson.dart';
import 'package:titan_tunes/data/models/playlist.dart';
import 'package:titan_tunes/presentation/widgets/app_network_image.dart';
import 'package:titan_tunes/presentation/widgets/glassmorphism_widgets.dart';
import 'package:titan_tunes/presentation/widgets/lecture/dictaphone_bar.dart';
import 'package:titan_tunes/presentation/widgets/lecture/player_tabs.dart';
import 'package:titan_tunes/providers/audio_provider.dart';
import 'package:titan_tunes/providers/auth_provider.dart';

class PageLectureAudio extends StatefulWidget {
  const PageLectureAudio({super.key});

  @override
  State<PageLectureAudio> createState() => _PageLectureAudioState();
}

class _PageLectureAudioState extends State<PageLectureAudio>
    with TickerProviderStateMixin {
  late final AnimationController _waveController;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _waveController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AudioProvider>();
    final auth = context.watch<AuthProvider>();
    final chanson = provider.currentChanson;
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final muted = theme.textTheme.bodySmall?.color ?? theme.hintColor;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: PageBackground(
          child: chanson == null
              ? _EmptyNowPlaying(theme: theme)
              : ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
                  children: [
                    Row(
                      children: [
                        _RoundIconButton(
                          icon: Icons.arrow_back_ios_new_rounded,
                          onTap: () => Navigator.of(context).pop(),
                        ),
                        const Spacer(),
                        Text(
                          'Lecture en cours',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        _RoundIconButton(
                          icon: Icons.more_horiz,
                          onTap: () => _showPlaybackOptions(
                            context,
                            provider,
                            auth,
                            chanson,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Center(
                      child: Container(
                        width: 240,
                        height: 240,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: primary.withAlpha(45),
                              blurRadius: 30,
                              offset: const Offset(0, 18),
                            ),
                          ],
                        ),
                        child: AppNetworkImage(
                          url: chanson.coverUrl,
                          width: 240,
                          height: 240,
                          borderRadius: BorderRadius.circular(28),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            chanson.title,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            chanson.artistName.isNotEmpty
                                ? chanson.artistName
                                : chanson.artisteId,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _RoundIconButton(
                          icon: Icons.shuffle_rounded,
                          onTap: () =>
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Lecture aléatoire bientôt disponible.',
                                  ),
                                ),
                              ),
                        ),
                        const SizedBox(width: 12),
                        _RoundIconButton(
                          icon: Icons.skip_previous_rounded,
                          onTap: () => _playPrevious(context, provider),
                        ),
                        const SizedBox(width: 16),
                        FilledButton(
                          onPressed: provider.togglePlayPause,
                          style: FilledButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(18),
                          ),
                          child: Icon(
                            provider.isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        _RoundIconButton(
                          icon: Icons.skip_next_rounded,
                          onTap: () => _playNext(context, provider),
                        ),
                        const SizedBox(width: 12),
                        _RoundIconButton(
                          icon: Icons.repeat_rounded,
                          onTap: () =>
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Répétition bientôt disponible.',
                                  ),
                                ),
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    DictaphoneBar(
                      provider: provider,
                      primary: primary,
                      secondary: theme.colorScheme.secondary,
                      isDark: theme.brightness == Brightness.dark,
                      waveCtrl: _waveController,
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => provider.toggleFavorite(chanson),
                            icon: Icon(
                              chanson.isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                            ),
                            label: const Text('Favori'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final messenger = ScaffoldMessenger.maybeOf(
                                context,
                              );
                              final message = await provider
                                  .downloadCurrentChanson(
                                    isSubscribed: auth.isSubscribed,
                                    subscriptionExpiryAt:
                                        auth.subscriptionExpiryAt,
                                  );
                              if (!context.mounted) return;
                              messenger?.showSnackBar(
                                SnackBar(content: Text(message)),
                              );
                            },
                            icon: const Icon(Icons.download_outlined),
                            label: Text(
                              auth.isSubscribed
                                  ? 'Télécharger'
                                  : 'Abonnez-vous',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    TabBar(
                      controller: _tabController,
                      labelColor: primary,
                      unselectedLabelColor: muted,
                      indicatorColor: primary,
                      tabs: const [
                        Tab(text: 'Paroles'),
                        Tab(text: 'Suivant'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 260,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          LyricsTab(
                            chanson: chanson,
                            fg: theme.colorScheme.onSurface,
                          ),
                          QueueTab(
                            chanson: chanson,
                            provider: provider,
                            primary: primary,
                            fg: theme.colorScheme.onSurface,
                            muted: muted,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    GlassPanel(
                      accentColor: theme.colorScheme.secondary,
                      borderRadius: BorderRadius.circular(24),
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const CircleAvatar(
                              child: Icon(Icons.album_outlined),
                            ),
                            title: const Text('Album'),
                            subtitle: Text(chanson.albumId),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const CircleAvatar(
                              child: Icon(Icons.category_outlined),
                            ),
                            title: const Text('Genres'),
                            subtitle: Text(chanson.genres.join(' • ')),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> _showPlaybackOptions(
    BuildContext context,
    AudioProvider provider,
    AuthProvider auth,
    Chanson chanson,
  ) async {
    final messenger = ScaffoldMessenger.maybeOf(context);

    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Theme.of(sheetContext).dividerColor,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.download_rounded),
                  title: const Text('Télécharger la chanson'),
                  onTap: () async {
                    final message = await provider.downloadCurrentChanson(
                      isSubscribed: auth.isSubscribed,
                      subscriptionExpiryAt: auth.subscriptionExpiryAt,
                    );
                    if (!context.mounted) return;
                    Navigator.of(sheetContext).pop();
                    messenger?.showSnackBar(SnackBar(content: Text(message)));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.playlist_add_rounded),
                  title: const Text('Ajouter à une playlist'),
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    await _addToPlaylist(context, provider, chanson);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.favorite_rounded),
                  title: Text(
                    chanson.isFavorite
                        ? 'Retirer des favoris'
                        : 'Ajouter aux favoris',
                  ),
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    await provider.toggleFavorite(chanson);
                    messenger?.showSnackBar(
                      SnackBar(
                        content: Text(
                          chanson.isFavorite
                              ? 'Chanson retirée des favoris.'
                              : 'Chanson ajoutée aux favoris.',
                        ),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.shuffle_rounded),
                  title: const Text('Lecture aléatoire'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    provider.toggleShuffle();
                    messenger?.showSnackBar(
                      SnackBar(
                        content: Text(
                          provider.shuffleEnabled
                              ? 'Lecture aléatoire activée.'
                              : 'Lecture aléatoire désactivée.',
                        ),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.repeat_rounded),
                  title: const Text('Répéter la chanson'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    provider.cycleLoopMode();
                    messenger?.showSnackBar(
                      SnackBar(
                        content: Text(
                          provider.loopMode == LoopMode.off
                              ? 'Boucle désactivée.'
                              : provider.loopMode == LoopMode.one
                              ? 'Répétition activée.'
                              : 'Lecture en boucle de la liste.',
                        ),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.share_rounded),
                  title: const Text('Partager la chanson'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    messenger?.showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Partage de la chanson prêt à être ajouté.',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _addToPlaylist(
    BuildContext context,
    AudioProvider provider,
    Chanson chanson,
  ) async {
    final playlists = provider.playlists;
    if (playlists.isEmpty) {
      final title = await _promptPlaylistName(context);
      if (title == null || title.trim().isEmpty) return;
      final created = await provider.createPlaylist(
        title,
        'Créée depuis le lecteur audio',
      );
      if (created == null) {
        if (!context.mounted) return;
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          const SnackBar(content: Text('Impossible de créer la playlist.')),
        );
        return;
      }
      await provider.addSongToPlaylist(created.id, chanson.id);
      if (!context.mounted) return;
      ScaffoldMessenger.maybeOf(
        context,
      )?.showSnackBar(SnackBar(content: Text('Ajouté à "${created.title}".')));
      return;
    }

    final selected = await showDialog<Playlist>(
      context: context,
      builder: (dialogContext) {
        return SimpleDialog(
          title: const Text('Choisir une playlist'),
          children: [
            ...playlists.map(
              (playlist) => SimpleDialogOption(
                onPressed: () => Navigator.of(dialogContext).pop(playlist),
                child: Text(playlist.title),
              ),
            ),
            const Divider(),
            SimpleDialogOption(
              onPressed: () async {
                final title = await _promptPlaylistName(dialogContext);
                if (!dialogContext.mounted) return;
                if (title == null || title.trim().isEmpty) {
                  Navigator.of(dialogContext).pop();
                  return;
                }
                final created = await provider.createPlaylist(
                  title,
                  'Créée depuis le lecteur audio',
                );
                if (!dialogContext.mounted) return;
                Navigator.of(dialogContext).pop(created);
              },
              child: const Row(
                children: [
                  Icon(Icons.add_circle_outline_rounded),
                  SizedBox(width: 8),
                  Text('Créer une nouvelle playlist'),
                ],
              ),
            ),
          ],
        );
      },
    );

    if (selected == null || selected.id.isEmpty) return;
    if (selected.chansonIds.contains(chanson.id)) {
      if (!context.mounted) return;
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text('Déjà dans "${selected.title}".')),
      );
      return;
    }

    await provider.addSongToPlaylist(selected.id, chanson.id);
    if (!context.mounted) return;
    ScaffoldMessenger.maybeOf(
      context,
    )?.showSnackBar(SnackBar(content: Text('Ajouté à "${selected.title}".')));
  }

  Future<String?> _promptPlaylistName(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Nouvelle playlist'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Nom de la playlist'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(controller.text.trim()),
              child: const Text('Créer'),
            ),
          ],
        );
      },
    );

    return result;
  }
}

class _EmptyNowPlaying extends StatelessWidget {
  final ThemeData theme;

  const _EmptyNowPlaying({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: GlassPanel(
          accentColor: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.music_note_outlined, size: 56),
              const SizedBox(height: 12),
              Text(
                'Aucune musique en lecture',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Lancez un morceau depuis la bibliothèque, les tendances ou la recherche.',
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Retour'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface.withAlpha(80),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(padding: const EdgeInsets.all(12), child: Icon(icon)),
      ),
    );
  }
}

Future<void> _playPrevious(BuildContext context, AudioProvider provider) async {
  if (provider.chansons.isEmpty || provider.currentChanson == null) return;
  final index = provider.chansons.indexWhere(
    (song) => song.id == provider.currentChanson!.id,
  );
  if (index <= 0) return;
  await provider.playChanson(provider.chansons[index - 1]);
}

Future<void> _playNext(BuildContext context, AudioProvider provider) async {
  if (provider.chansons.isEmpty || provider.currentChanson == null) return;
  final index = provider.chansons.indexWhere(
    (song) => song.id == provider.currentChanson!.id,
  );
  if (index < 0 || index >= provider.chansons.length - 1) return;
  await provider.playChanson(provider.chansons[index + 1]);
}
