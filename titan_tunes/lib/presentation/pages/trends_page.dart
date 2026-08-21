import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:titan_tunes/core/app_theme.dart';
import 'package:titan_tunes/data/models/artiste.dart';
import 'package:titan_tunes/data/models/chanson.dart';
import 'package:titan_tunes/presentation/pages/artist_profile_page.dart';
import 'package:titan_tunes/presentation/pages/lecture/page_lecture_audio.dart';
import 'package:titan_tunes/presentation/widgets/app_network_image.dart';
import 'package:titan_tunes/presentation/widgets/glassmorphism_widgets.dart';
import 'package:titan_tunes/providers/audio_provider.dart';

class TrendsPage extends StatefulWidget {
  final List<Chanson> chansons;
  const TrendsPage({super.key, required this.chansons});

  @override
  State<TrendsPage> createState() => _TrendsPageState();
}

class _TrendsPageState extends State<TrendsPage> {
  String _selectedGenre = 'Tous';

  List<String> _genres(List<Chanson> list) {
    final s = <String>{'Tous'};
    for (final c in list) {
      s.addAll(c.genres);
    }
    return s.toList();
  }

  List<Chanson> _filtered(List<Chanson> all) {
    final trending = all.isNotEmpty
        ? (all.toList()..sort((a, b) => b.popularity.compareTo(a.popularity)))
        : <Chanson>[];
    if (_selectedGenre == 'Tous') return trending;
    return trending.where((c) => c.genres.contains(_selectedGenre)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final primary  = Theme.of(context).colorScheme.primary;
    final secondary= isDark ? AppColors.accentSkyBlue : AppColors.amber;
    final theme    = Theme.of(context);
    final provider = context.watch<AudioProvider>();
    final sourceList = provider.tendances.isNotEmpty ? provider.tendances : provider.chansons;
    final filtered = _filtered(sourceList);
    final genres   = _genres(sourceList);
    final top3     = filtered.take(3).toList();
    final rest     = filtered.length > 3 ? filtered.sublist(3) : <Chanson>[];

    return PageBackground(
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Header ────────────────────────────────────────────────────
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(18, 14, 18, 0),
                child: GlassPageHeader(
                  title: 'Tendances',
                  subtitle: 'Les morceaux les plus populaires du moment.',
                  tag: 'Top Classement',
                ),
              ),
            ),

            // ── Filtres genres ────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
                child: SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: genres.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final g   = genres[i];
                      final sel = g == _selectedGenre;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedGenre = g),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: sel
                                ? primary
                                : (isDark ? AppColors.surfaceDark2 : AppColors.cardLight),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: sel ? primary : (isDark ? AppColors.dividerDark : AppColors.divider),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            g,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                              color: sel
                                  ? Colors.white
                                  : (isDark ? AppColors.textDark : AppColors.textLight),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // ── Podium Top 3 ──────────────────────────────────────────────
            if (top3.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
                  child: GlassPanel(
                    accentColor: primary,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: primary.withAlpha(25),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.military_tech_rounded,
                                  color: primary, size: 18),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Podium des écoutes',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _PodiumRow(
                          chansons: top3,
                          primary: primary,
                          secondary: secondary,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],

            // ── Titre liste ───────────────────────────────────────────────
            if (rest.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 24, 18, 8),
                  child: Row(
                    children: [
                      Container(
                        width: 4, height: 16,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Text(
                        'Suite du classement',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // ── Liste classée ─────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    final rank    = i + 4;
                    final chanson = rest[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _RankedTrackTile(
                        rank: rank,
                        chanson: chanson,
                        primary: primary,
                        isDark: isDark,
                        onPlay: () {
                          context.read<AudioProvider>().playChanson(chanson);
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => const PageLectureAudio()));
                        },
                      ),
                    );
                  },
                  childCount: rest.length,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

// ── Podium ────────────────────────────────────────────────────────────────────
class _PodiumRow extends StatelessWidget {
  final List<Chanson> chansons;
  final Color primary;
  final Color secondary;
  final bool  isDark;
  const _PodiumRow({
    required this.chansons,
    required this.primary,
    required this.secondary,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // ordre visuel podium : 2e - 1er - 3e
    final order = chansons.length >= 3
        ? [chansons[1], chansons[0], chansons[2]]
        : chansons;
    final heights = [100.0, 130.0, 85.0];
    final ranks = chansons.length >= 3 ? [2, 1, 3] : [1, 2, 3];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(order.length, (i) {
        final c   = order[i];
        final h   = heights[i];
        final rank = ranks[i];
        return Expanded(
          child: GestureDetector(
            onTap: () => context.read<AudioProvider>().playChanson(c),
            child: Column(children: [
              AppNetworkImage(
                url: c.coverUrl,
                width: 64,
                height: 64,
                borderRadius: BorderRadius.circular(14),
              ),
              const SizedBox(height: 6),
              _PodiumRankBadge(rank: rank),
              const SizedBox(height: 4),
              Text(
                c.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  width: double.infinity,
                  height: h * 0.45,
                  color: primary.withAlpha(20),
                  child: FractionallySizedBox(
                    alignment: Alignment.bottomCenter,
                    heightFactor: (c.popularity / 100).clamp(0.1, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: rank == 1
                              ? [primary, primary.withAlpha(180)]
                              : [secondary, secondary.withAlpha(180)],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${c.popularity}%',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textDark : AppColors.textLight,
                ),
              ),
            ]),
          ),
        );
      }),
    );
  }
}

class _PodiumRankBadge extends StatelessWidget {
  final int rank;
  const _PodiumRankBadge({required this.rank});

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    Color textColor = Colors.white;

    switch (rank) {
      case 1:
        badgeColor = const Color(0xFFFFB800); // Gold
        break;
      case 2:
        badgeColor = const Color(0xFF9E9EA7); // Silver
        break;
      case 3:
      default:
        badgeColor = const Color(0xFFCD7F32); // Bronze
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.emoji_events_rounded, size: 12, color: textColor),
          const SizedBox(width: 3),
          Text(
            '#$rank',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w900,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tuile morceau classé ──────────────────────────────────────────────────────
class _RankedTrackTile extends StatelessWidget {
  final int     rank;
  final Chanson chanson;
  final Color   primary;
  final bool    isDark;
  final VoidCallback onPlay;

  const _RankedTrackTile({
    required this.rank,
    required this.chanson,
    required this.primary,
    required this.isDark,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AudioProvider>();
    final isPlaying = provider.currentChanson?.id == chanson.id && provider.isPlaying;

    return GlassPanel(
      accentColor: isPlaying ? primary : null,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      borderRadius: BorderRadius.circular(14),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '$rank',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: isPlaying ? primary : (isDark ? AppColors.mutedDark : AppColors.mutedLight),
              ),
            ),
          ),
          const SizedBox(width: 8),

          AppNetworkImage(
            url: chanson.coverUrl,
            width: 44,
            height: 44,
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chanson.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isPlaying ? primary : (isDark ? AppColors.textDark : AppColors.textLight),
                  ),
                ),
                const SizedBox(height: 2),
                GestureDetector(
                  onTap: () {
                    final artist = provider.artistes.firstWhere(
                      (a) => a.id == chanson.artisteId,
                      orElse: () => Artiste(
                        id: chanson.artisteId,
                        name: chanson.artistName,
                        label: '',
                        country: 'Togo',
                        followers: 1200,
                        pictureUrl: chanson.coverUrl,
                        genres: chanson.genres,
                      ),
                    );
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => ArtistProfilePage(artist: artist)),
                    );
                  },
                  child: Text(
                    chanson.artistName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.mutedDark : AppColors.mutedLight,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.trending_up_rounded, size: 14, color: primary),
              const SizedBox(width: 3),
              Text(
                '${chanson.popularity}%',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.mutedDark : AppColors.mutedLight,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),

          IconButton(
            onPressed: onPlay,
            icon: Icon(
              isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
              color: primary,
              size: 32,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
