import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:titan_tunes/data/models/album.dart';
import 'package:titan_tunes/data/models/artiste.dart';
import 'package:titan_tunes/data/models/chanson.dart';
import 'package:titan_tunes/data/models/playlist.dart';
import 'package:titan_tunes/data/services/recherche_service.dart';
import 'package:titan_tunes/presentation/pages/artist_profile_page.dart';
import 'package:titan_tunes/presentation/pages/lecture/page_lecture_audio.dart';
import 'package:titan_tunes/presentation/widgets/glassmorphism_widgets.dart';
import 'package:titan_tunes/presentation/widgets/search/search_bar_field.dart';
import 'package:titan_tunes/presentation/widgets/search/search_filter_chips.dart';
import 'package:titan_tunes/presentation/widgets/search/search_genre_grid.dart';
import 'package:titan_tunes/presentation/widgets/search/search_result_tiles.dart';
import 'package:titan_tunes/providers/audio_provider.dart';

class SearchPage extends StatefulWidget {
  final List<Chanson> chansons;
  final RechercheService? rechercheService;
  const SearchPage({
    super.key,
    required this.chansons,
    this.rechercheService,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _ctrl      = TextEditingController();
  final FocusNode             _focusNode = FocusNode();

  String       _query       = '';
  SearchFilter _filter      = SearchFilter.tous;
  bool         _showResults = false;
  bool         _isSearchingBackend = false;

  // Résultats backend
  List<Chanson>  _backendChansons  = [];
  List<Artiste>  _backendArtistes  = [];
  List<Album>    _backendAlbums    = [];
  List<Playlist> _backendPlaylists = [];

  @override
  void dispose() {
    _ctrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ── Filtrage chansons ──────────────────────────────────────────────────
  List<Chanson> _filteredChansons(AudioProvider provider) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return [];
    final pool = provider.chansons.isNotEmpty ? provider.chansons : widget.chansons;
    return pool.where((c) {
      switch (_filter) {
        case SearchFilter.genre:
          return c.genres.any((g) => g.toLowerCase().contains(q));
        case SearchFilter.artiste:
          return c.artistName.toLowerCase().contains(q) ||
              c.artisteId.toLowerCase().contains(q);
        case SearchFilter.label:
          final a = provider.artistes.firstWhere(
            (a) => a.id == c.artisteId,
            orElse: () => Artiste(
                id: '', name: '', label: '', country: '',
                followers: 0, pictureUrl: '', genres: []),
          );
          return a.label.toLowerCase().contains(q);
        case SearchFilter.tous:
          return c.title.toLowerCase().contains(q) ||
              c.artistName.toLowerCase().contains(q) ||
              c.genres.any((g) => g.toLowerCase().contains(q));
      }
    }).toList();
  }

  // ── Filtrage artistes ──────────────────────────────────────────────────
  List<Artiste> _filteredArtistes(AudioProvider provider) {
    if (_filter != SearchFilter.artiste && _filter != SearchFilter.tous) {
      return [];
    }
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return [];
    return provider.artistes
        .where((a) => a.name.toLowerCase().contains(q))
        .toList();
  }

  // ── Actions ────────────────────────────────────────────────────────────
  void _submitSearch(String value) {
    final q = value.trim();
    if (q.isEmpty) return;
    context.read<AudioProvider>().addSearchHistory(q);
    setState(() { _query = q; _showResults = true; });
    _focusNode.unfocus();
    _searchBackend(q);
  }

  Future<void> _searchBackend(String query) async {
    if (widget.rechercheService == null) return;
    setState(() => _isSearchingBackend = true);
    try {
      final result = await widget.rechercheService!.rechercheGlobale(
        query,
        limit: 20,
      );
      if (result != null && mounted) {
        setState(() {
          _backendChansons  = result.chansons;
          _backendArtistes  = result.artistes;
          _backendAlbums    = result.albums;
          _backendPlaylists = result.playlists;
          _isSearchingBackend = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isSearchingBackend = false);
    }
  }

  void _applyHistory(String q) {
    _ctrl.text = q;
    _submitSearch(q);
  }

  void _playChanson(Chanson chanson) {
    context.read<AudioProvider>().playChanson(chanson);
    Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const PageLectureAudio()));
  }

  void _openArtiste(Artiste artiste) {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ArtistProfilePage(artist: artiste)));
  }

  @override
  Widget build(BuildContext context) {
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final primary  = Theme.of(context).colorScheme.primary;
    final provider = context.watch<AudioProvider>();
    final history  = provider.searchHistory;
    final chansons = _filteredChansons(provider);
    final artistes = _filteredArtistes(provider);
    final displayArtistes = _backendArtistes.isNotEmpty
      ? _backendArtistes
      : artistes;
    final displayChansons = _backendChansons.isNotEmpty
      ? _backendChansons
      : chansons;

    return PageBackground(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          // Header
          const GlassPageHeader(
            title: 'Rechercher',
            subtitle: 'Trouvez une chanson, un artiste, un genre ou un label.',
            tag: 'Explorer',
          ),
          const SizedBox(height: 20),

          // Barre de recherche
          SearchBarField(
            controller: _ctrl,
            focusNode:  _focusNode,
            query:      _query,
            primary:    primary,
            isDark:     isDark,
            onChanged: (v) => setState(() {
              _query = v;
              if (v.trim().isEmpty) _showResults = false;
            }),
            onSubmitted: _submitSearch,
            onClear: () {
              _ctrl.clear();
              setState(() { _query = ''; _showResults = false; });
            },
          ),
          const SizedBox(height: 14),

          // Chips filtre
          SearchFilterChips(
            selected:   _filter,
            primary:    primary,
            isDark:     isDark,
            onSelected: (f) => setState(() {
              _filter = f;
              if (_query.isNotEmpty) _showResults = true;
            }),
          ),
          const SizedBox(height: 22),

          // ── ÉTAT 1 : repos ─────────────────────────────────────────────
          if (!_showResults && _query.trim().isEmpty) ...[
            if (history.isNotEmpty) ...[
              SearchSectionHeader(
                label: 'Historique',
                primary: primary,
                trailing: TextButton(
                  onPressed: () => provider.clearSearchHistory(),
                  style: TextButton.styleFrom(
                    foregroundColor: primary,
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                  child: const Text('Effacer',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 10),
              ...history.map((h) => SearchHistoryTile(
                query:    h,
                primary:  primary,
                isDark:   isDark,
                onTap:    () => _applyHistory(h),
                onDelete: () => provider.removeSearchHistory(h),
              )),
              const SizedBox(height: 22),
            ],
            SearchSectionHeader(label: 'Explorer les genres', primary: primary),
            const SizedBox(height: 12),
            SearchGenreGrid(
              isDark: isDark,
              onGenreTap: (lbl) {
                _ctrl.text = lbl;
                setState(() { _query = lbl; _filter = SearchFilter.genre; });
                _submitSearch(lbl);
              },
            ),

          // ── ÉTAT 2 : frappe en cours ────────────────────────────────────
          ] else if (!_showResults && _query.trim().isNotEmpty) ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Appuyez sur Entrée pour chercher « ${_query.trim()} »',
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.black45,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

          // ── ÉTAT 3 : résultats ──────────────────────────────────────────
          ] else ...[
            // Indicateur de recherche backend
            if (_isSearchingBackend)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: primary,
                    ),
                  ),
                ),
              ),
            // Utiliser les résultats backend si disponibles, sinon local
            if (displayArtistes.isNotEmpty) ...[
              SearchSectionHeader(
                  label: '${displayArtistes.length} artiste(s)', primary: primary),
              const SizedBox(height: 10),
              SizedBox(
                height: 118,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: displayArtistes.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 14),
                  itemBuilder: (_, i) => SearchArtistChip(
                    artiste: displayArtistes[i],
                    primary: primary,
                    onTap:   () => _openArtiste(displayArtistes[i]),
                  ),
                ),
              ),
              const SizedBox(height: 22),
            ],
            SearchSectionHeader(
                label: '${displayChansons.length} titre(s)', primary: primary),
            const SizedBox(height: 10),
            if (displayChansons.isEmpty && !_isSearchingBackend)
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 8),
                child: Center(
                  child: Text(
                    'Aucun résultat pour « ${_query.trim()} »',
                    style: TextStyle(
                        color: isDark ? Colors.white38 : Colors.black38),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              ...displayChansons.map((c) => SearchSongTile(
                chanson:   c,
                primary:   primary,
                isDark:    isDark,
                artistes:  provider.artistes,
                onPlay:    () => _playChanson(c),
                onArtistTap: () {
                  final a = provider.artistes.firstWhere(
                    (a) => a.id == c.artisteId,
                    orElse: () => Artiste(
                        id: '', name: c.artistName, label: '',
                        country: '', followers: 0,
                        pictureUrl: '', genres: []),
                  );
                  if (a.id.isNotEmpty) _openArtiste(a);
                },
              )),
          ],

          const SizedBox(height: 32),
          Center(
            child: Text('powered by NITCH-Corp',
              style: TextStyle(fontSize: 12,
                  color: isDark ? Colors.white38 : Colors.black38)),
          ),
        ],
      ),
    );
  }
}