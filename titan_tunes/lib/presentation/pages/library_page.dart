import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:titan_tunes/data/models/playlist.dart';
import 'package:titan_tunes/presentation/widgets/glassmorphism_widgets.dart';
import 'package:titan_tunes/presentation/widgets/library/library_playlist_card.dart';
import 'package:titan_tunes/presentation/widgets/library/library_song_tile.dart';
import 'package:titan_tunes/presentation/widgets/library/library_stat_card.dart';
import 'package:titan_tunes/providers/audio_provider.dart';
import 'package:titan_tunes/providers/auth_provider.dart';
import 'package:titan_tunes/presentation/pages/history_page.dart';
import 'package:titan_tunes/presentation/pages/downloads_page.dart';

enum _LibraryFilter { toutes, publiques, privees }

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});
  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  String? _selectedPlaylistId;
  _LibraryFilter _activeFilter = _LibraryFilter.toutes;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.watch<AudioProvider>();
    if (_selectedPlaylistId == null && provider.playlists.isNotEmpty) {
      _selectedPlaylistId = provider.playlists.first.id;
    }
    if (_selectedPlaylistId != null &&
        provider.playlists.isNotEmpty &&
        provider.playlists.every((p) => p.id != _selectedPlaylistId)) {
      _selectedPlaylistId = provider.playlists.first.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AudioProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    final ordered = _sorted(provider.playlists);
    final visible = _filtered(ordered);
    final selected = visible.isEmpty
        ? null
        : provider.playlists.firstWhere(
            (p) => p.id == _selectedPlaylistId,
            orElse: () => visible.first);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Retour',
        ),
        title: const Text('Bibliothèque',
            style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        top: false,
        child: PageBackground(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
            children: [
              // Header
              const GlassPageHeader(
                title: 'Bibliothèque',
                subtitle:
                    'Retrouvez vos playlists et améliorez-les à tout moment.',
                tag: 'Playlists',
              ),
              const SizedBox(height: 16),

              // Stats
              Row(children: [
                Expanded(
                    child: LibraryStatCard(
                  label: 'Playlists',
                  value: '${provider.playlists.length}',
                  color: primaryColor,
                )),
                const SizedBox(width: 12),
                Expanded(
                    child: LibraryStatCard(
                  label: 'Titres',
                  value:
                      '${provider.playlists.fold<int>(0, (s, p) => s + p.chansonIds.length)}',
                  color: primaryColor,
                )),
              ]),
              const SizedBox(height: 16),

              // Filtres
              Wrap(spacing: 10, runSpacing: 10, children: [
                LibraryFilterChip(
                  label: 'Toutes',
                  count: provider.playlists.length,
                  selected: _activeFilter == _LibraryFilter.toutes,
                  primaryColor: primaryColor,
                  onTap: () =>
                      setState(() => _activeFilter = _LibraryFilter.toutes),
                ),
                LibraryFilterChip(
                  label: 'Publiques',
                  count: provider.playlists.where((p) => p.isPublic).length,
                  selected: _activeFilter == _LibraryFilter.publiques,
                  primaryColor: primaryColor,
                  onTap: () =>
                      setState(() => _activeFilter = _LibraryFilter.publiques),
                ),
                LibraryFilterChip(
                  label: 'Privées',
                  count: provider.playlists.where((p) => !p.isPublic).length,
                  selected: _activeFilter == _LibraryFilter.privees,
                  primaryColor: primaryColor,
                  onTap: () =>
                      setState(() => _activeFilter = _LibraryFilter.privees),
                ),
              ]),
              const SizedBox(height: 14),

              // Bouton nouvelle playlist
              GlassPanel(
                accentColor: primaryColor,
                child: Row(children: [
                  Icon(Icons.library_music_outlined, color: primaryColor),
                  const SizedBox(width: 10),
                  const Expanded(
                      child: Text(
                          'Créez, visualisez et améliorez vos playlists.')),
                  ElevatedButton.icon(
                    onPressed: () => _showEditor(context, provider),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Nouvelle'),
                  ),
                ]),
              ),
              const SizedBox(height: 20),

              // Titre section Playlists
              _SectionTitle(
                  label: 'Mes playlists', primaryColor: primaryColor),
              const SizedBox(height: 10),

              // Liste horizontale des Playlists
              if (visible.isEmpty)
                GlassPanel(
                  accentColor: primaryColor,
                  child: Text(_activeFilter == _LibraryFilter.toutes
                      ? 'Aucune playlist pour le moment.'
                      : 'Aucune playlist ne correspond à ce filtre.'),
                )
              else
                SizedBox(
                  height: 178,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: visible.length,
                    separatorBuilder: (ctx, idx) => const SizedBox(width: 12),
                    itemBuilder: (_, i) => LibraryPlaylistCard(
                      playlist: visible[i],
                      isSelected: visible[i].id == selected?.id,
                      primaryColor: primaryColor,
                      onTap: () =>
                          setState(() => _selectedPlaylistId = visible[i].id),
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              // ── NOUVELLE SECTION : Raccourcis Historique & Téléchargements ──
              _SectionTitle(
                  label: 'Accès rapide', primaryColor: primaryColor),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionButton(
                      icon: Icons.history_rounded,
                      label: 'Historique',
                      subtitle: 'Écoutés récemment',
                      primaryColor: primaryColor,
                      onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (ctx) => HistoryPage()),
                      );
                    },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionButton(
                      icon: Icons.download_for_offline_rounded,
                      label: 'Téléchargements',
                      subtitle: 'Mode hors-ligne',
                      primaryColor: primaryColor,
                      onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (ctx) => DownloadsPage()),
                      );
                    },
                    ),
                  ),
                ],
              ),

              // Détail playlist sélectionnée
              if (selected != null) ...[
                const SizedBox(height: 20),
                Row(children: [
                  _SectionTitle(
                      label: 'Détails de la playlist',
                      primaryColor: primaryColor),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () =>
                        _showEditor(context, provider, playlist: selected),
                    icon: Icon(Icons.edit_rounded,
                        size: 16, color: primaryColor),
                    label: Text('Améliorer',
                        style: TextStyle(color: primaryColor)),
                  ),
                ]),
                const SizedBox(height: 10),
                GlassPanel(
                  accentColor: primaryColor,
                  child: Column(children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                          backgroundColor: primaryColor.withAlpha(30),
                          child: Icon(Icons.queue_music_rounded,
                              color: primaryColor)),
                      title: Text(selected.title),
                      subtitle: Text(selected.isPublic
                          ? 'Playlist publique'
                          : 'Playlist privée'),
                      trailing: Text('${selected.chansonIds.length} titres',
                          style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.w700)),
                    ),
                    Divider(height: 1, color: primaryColor.withAlpha(35)),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(selected.description,
                            style: theme.textTheme.bodyMedium),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 18),
                _SectionTitle(
                    label: 'Titres de la playlist', primaryColor: primaryColor),
                const SizedBox(height: 10),
                if (selected.chansonIds.isEmpty)
                  GlassPanel(
                    accentColor: primaryColor,
                    child: const Text(
                        'Cette playlist ne contient encore aucun titre.'),
                  )
                else
                  ...selected.chansonIds.map((id) {
                    final song = provider.chansons.firstWhere(
                      (s) => s.id == id,
                      orElse: () => provider.chansons.first,
                    );
                    return LibrarySongTile(
                      song: song,
                      primaryColor: primaryColor,
                      onPlay: () => provider.playChanson(song),
                    );
                  }),
              ],

              const SizedBox(height: 24),
              Center(
                child: Text('powered by NITCH-Corp',
                    style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white38 : Colors.black38)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Dialogue éditeur playlist ──────────────────────────────────────────
  Future<void> _showEditor(BuildContext context, AudioProvider provider,
      {Playlist? playlist}) async {
    final auth = context.read<AuthProvider>();

    // Blocage création playlist pour invités
    if (playlist == null && auth.isGuest) {
      showDialog(
        context: context,
        builder: (dlg) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Compte Requis'),
          content: const Text(
              'Créez un compte ou connectez-vous pour créer des playlists.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(dlg).pop(),
                child: const Text('Plus tard')),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dlg).pop();
                Navigator.of(context).pushNamed('/login');
              },
              child: const Text('Se connecter'),
            ),
          ],
        ),
      );
      return;
    }

    // Blocage création playlist pour non-abonnés
    if (playlist == null && !auth.isSubscribed) {
      showDialog(
        context: context,
        builder: (dlg) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Abonnement Requis'),
          content: const Text(
              'La création de playlist est réservée aux abonnés Titan Premium.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(dlg).pop(),
                child: const Text('Plus tard')),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dlg).pop();
                Navigator.of(context).pushNamed('/subscription');
              },
              child: const Text('Voir les offres'),
            ),
          ],
        ),
      );
      return;
    }

    final titleCtrl = TextEditingController(text: playlist?.title ?? '');
    final descCtrl = TextEditingController(text: playlist?.description ?? '');
    bool isPublic = playlist?.isPublic ?? true;

    await showDialog<void>(
      context: context,
      builder: (dlg) => AlertDialog(
        title: Text(playlist == null
            ? 'Créer une playlist'
            : 'Améliorer la playlist'),
        content: StatefulBuilder(
          builder: (_, set) => SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Titre')),
              const SizedBox(height: 12),
              TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Playlist publique'),
                value: isPublic,
                onChanged: (v) => set(() => isPublic = v),
              ),
            ]),
          ),
        ),
        actions: [
          if (playlist != null)
            TextButton(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (cdlg) => AlertDialog(
                    title: const Text('Supprimer la playlist'),
                    content: Text(
                        'Voulez-vous vraiment supprimer « ${playlist.title} » ?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(cdlg).pop(false),
                        child: const Text('Annuler'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.of(cdlg).pop(true),
                        style: FilledButton.styleFrom(
                            backgroundColor: Colors.redAccent),
                        child: const Text('Supprimer'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await provider.deletePlaylist(playlist.id);
                  if (mounted) {
                    setState(() {
                      _selectedPlaylistId = null;
                    });
                  }
                  if (dlg.mounted) Navigator.of(dlg).pop();
                }
              },
              child: const Text('Supprimer',
                  style: TextStyle(color: Colors.redAccent)),
            ),
          TextButton(
              onPressed: () => Navigator.of(dlg).pop(),
              child: const Text('Annuler')),
          FilledButton(
              onPressed: () async {
                final t = titleCtrl.text.trim();
                final d = descCtrl.text.trim();
                if (t.isEmpty || d.isEmpty) return;

                if (playlist == null) {
                  await provider.createPlaylist(t, d);
                } else {
                  final updated = playlist.copyWith(
                    title: t,
                    description: d,
                    isPublic: isPublic,
                  );
                  provider.updatePlaylist(playlist.id, updated);
                }

                if (dlg.mounted) Navigator.of(dlg).pop();
              },
              child: const Text('Enregistrer')),
        ],
      ),
    );
  }

  List<Playlist> _sorted(List<Playlist> list) {
    final s = [...list];
    s.sort((a, b) {
      final d = b.createdAt.compareTo(a.createdAt);
      return d != 0
          ? d
          : a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });
    return s;
  }

  List<Playlist> _filtered(List<Playlist> list) => switch (_activeFilter) {
        _LibraryFilter.toutes => list,
        _LibraryFilter.publiques => list.where((p) => p.isPublic).toList(),
        _LibraryFilter.privees => list.where((p) => !p.isPublic).toList(),
      };
}

// ── Titre de section ───────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String label;
  final Color primaryColor;
  const _SectionTitle({required this.label, required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 4,
        height: 18,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
            color: primaryColor, borderRadius: BorderRadius.circular(4)),
      ),
      Text(label,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w800)),
    ]);
  }
}

// ── Widget Bouton d'accès rapide (Historique & Téléchargements) ──────────────
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color primaryColor;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: GlassPanel(
          accentColor: primaryColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: primaryColor.withAlpha(30),
                child: Icon(icon, color: primaryColor, size: 22),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.color
                          ?.withOpacity(0.6),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}