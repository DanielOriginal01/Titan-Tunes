import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:titan_tunes/core/app_theme.dart';
import 'package:titan_tunes/data/services/recherche_service.dart';
import 'package:titan_tunes/presentation/pages/lecture/page_lecture_audio.dart';
import 'package:titan_tunes/presentation/pages/search_page.dart';
import 'package:titan_tunes/presentation/widgets/home/home_ad_carousel.dart';
import 'package:titan_tunes/presentation/widgets/home/home_artist_grid.dart';
import 'package:titan_tunes/presentation/widgets/home/home_featured_banner.dart';
import 'package:titan_tunes/providers/audio_provider.dart';
import 'package:titan_tunes/providers/auth_provider.dart';
import 'package:titan_tunes/providers/banniere_provider.dart';

/// Page d'accueil — bannière featured, onglets News/Artistes, playlists.
class HomeOverviewPage extends StatefulWidget {
  const HomeOverviewPage({super.key});
  @override
  State<HomeOverviewPage> createState() => _HomeOverviewPageState();
}

class _HomeOverviewPageState extends State<HomeOverviewPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  // ── Gestion du tap sur une bannière ───────────────────────────────────────
  void _handleBanniereTab(BuildContext context, banniere) {
    final lien = banniere.lienCible as String?;
    if (lien == null || lien.isEmpty) return;
    if (lien.startsWith('/')) {
      Navigator.of(context).pushNamed(lien);
    }
  }

  /// Construit l'avatar sans déclencher l'assertion CircleAvatar.
  /// onBackgroundImageError n'est passé QUE quand backgroundImage != null.
  Widget _buildAvatar(AuthProvider auth, Color primary) {
    final ImageProvider? img = auth.avatarBytes != null
        ? MemoryImage(auth.avatarBytes!)
        : auth.avatarUrl != null
        ? (auth.avatarUrl!.startsWith('http')
              ? NetworkImage(auth.avatarUrl!)
              : AssetImage(auth.avatarUrl!) as ImageProvider)
        : null;

    return CircleAvatar(
      radius: 20,
      backgroundColor: primary.withAlpha(20),
      backgroundImage: img,
      // onBackgroundImageError uniquement si une image est fournie
      onBackgroundImageError: img != null ? (e, s) {} : null,
      child: img == null
          ? Text(
              auth.userInitials,
              style: TextStyle(color: primary, fontWeight: FontWeight.w700),
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AudioProvider>();
    final auth = context.watch<AuthProvider>();
    final bannieres = context.watch<BanniereProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;
    final fg = isDark ? Colors.white : Colors.black;
    final muted = isDark ? Colors.white54 : Colors.black45;

    final featured = provider.chansons.isNotEmpty
        ? provider.chansons.first
        : null;
    final artists = provider.artistes.take(6).toList();
    final playlists = provider.playlists.take(4).toList();

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── AppBar recherche + avatar ──────────────────────────────────
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SearchPage(
                              chansons: provider.chansons,
                              rechercheService: context.read<RechercheService?>(),
                            ),
                          ),
                        ),
                        child: Container(
                          height: 42,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.cardDark
                                : AppColors.cardLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.dividerDark
                                  : AppColors.divider,
                            ),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 12),
                              Icon(Icons.search, color: muted, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Search…',
                                style: TextStyle(color: muted, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pushNamed('/profile'),
                      child: _buildAvatar(auth, primary),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () =>
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Menu rapide bientôt disponible.'),
                            ),
                          ),
                      icon: Icon(Icons.more_vert_rounded, color: muted),
                      tooltip: 'Plus d’options',
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Bannière featured ──────────────────────────────────────────
          if (featured != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
                child: HomeFeaturedBanner(
                  chanson: featured,
                  primary: primary,
                  isDark: isDark,
                  onTap: () {
                    context.read<AudioProvider>().playChanson(featured);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PageLectureAudio(),
                      ),
                    );
                  },
                ),
              ),
            ),

          // ── Carrousel publicités & événements ────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 18, 0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 18,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        Text(
                          'Actualités & Événements',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: fg,
                          ),
                        ),
                        const Spacer(),
                        if (bannieres.isLoading)
                          SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: primary,
                            ),
                          )
                        else
                          GestureDetector(
                            onTap: () => bannieres.refresh(),
                            child: Icon(
                              Icons.refresh_rounded,
                              size: 18,
                              color: primary.withAlpha(160),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Carrousel
                  if (bannieres.bannieres.isNotEmpty)
                    HomeAdCarousel(
                      items: bannieres.bannieres,
                      primary: primary,
                      isDark: isDark,
                      onTap: (item) => _handleBanniereTab(context, item),
                    )
                  else if (!bannieres.isLoading)
                    const SizedBox.shrink(),
                ],
              ),
            ),
          ),

          // ── Onglets News / Artistes ────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 22),
              child: TabBar(
                controller: _tabs,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                labelColor: primary,
                unselectedLabelColor: muted,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                ),
                indicatorColor: primary,
                indicatorSize: TabBarIndicatorSize.label,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'News'),
                  Tab(text: 'Artistes'),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: SizedBox(
              height: 200,
              child: TabBarView(
                controller: _tabs,
                children: [
                  HomeArtistGrid(
                    artists: artists,
                    primary: primary,
                    isDark: isDark,
                  ),
                  HomeArtistGrid(
                    artists: artists,
                    primary: primary,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),

          // ── Section Playlist ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 24, 18, 10),
              child: Row(
                children: [
                  Text(
                    'Playlist',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: fg,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () =>
                        Navigator.of(context).pushNamed('/profile'),
                    style: TextButton.styleFrom(
                      foregroundColor: primary,
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text(
                      'Voir Plus',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverList(
            delegate: SliverChildBuilderDelegate((_, i) {
              final pl = playlists[i];
              final first = provider.chansons
                  .where((s) => pl.chansonIds.contains(s.id))
                  .take(1)
                  .toList();
              return HomePlaylistTile(
                playlist: pl,
                coverUrl: first.isNotEmpty ? first.first.coverUrl : '',
                primary: primary,
                isDark: isDark,
                fg: fg,
                muted: muted,
              );
            }, childCount: playlists.length),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }
}
