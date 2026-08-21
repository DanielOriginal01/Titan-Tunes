import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:titan_tunes/core/app_theme.dart';
import 'package:titan_tunes/data/models/artiste.dart';
import 'package:titan_tunes/presentation/pages/lecture/page_lecture_audio.dart';
import 'package:titan_tunes/presentation/widgets/app_network_image.dart';
import 'package:titan_tunes/providers/audio_provider.dart';

class ArtistProfilePage extends StatelessWidget {
  final Artiste artist;
  const ArtistProfilePage({super.key, required this.artist});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AudioProvider>();

    final currentArtist = provider.artistes.firstWhere(
      (a) => a.id == artist.id,
      orElse: () => artist,
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;
    final fg = isDark ? Colors.white : Colors.black;
    final muted = isDark ? Colors.white54 : Colors.black45;

    final songs = provider.chansons
        .where((s) => s.artisteId == currentArtist.id)
        .toList();
    final albums = provider.albums
        .where((a) => a.artisteId == currentArtist.id)
        .toList();
    final isFav = provider.isArtistFavorite(currentArtist.id);

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Photo de couverture (bannière) ──────────────────────────────────
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: bg,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: fg),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.more_vert_rounded, color: fg),
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Options artistiques bientôt disponibles.'),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Photo de couverture (bannière)
                  AppNetworkImage(
                    url: currentArtist.photoUrl,
                    fit: BoxFit.cover,
                    errorWidget: Container(
                      color: primary.withAlpha(30),
                      child: Icon(
                        Icons.person_rounded,
                        size: 80,
                        color: primary,
                      ),
                    ),
                  ),
                  // Dégradé bas
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 160,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [bg, Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                  // Avatar profil + nom + followers + bouton suivre
                  Positioned(
                    bottom: 16,
                    left: 18,
                    right: 18,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Avatar photo de profil
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: bg, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(40),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: AppNetworkImage(
                              url: currentArtist.pictureUrl,
                              fit: BoxFit.cover,
                              errorWidget: Container(
                                color: primary.withAlpha(60),
                                child: Icon(
                                  Icons.person_rounded,
                                  size: 36,
                                  color: primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Nom + followers + pays
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                currentArtist.name,
                                style: TextStyle(
                                  color: fg,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${currentArtist.followers} abonnés  •  ${currentArtist.country}',
                                style: TextStyle(color: muted, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        // Bouton suivre
                        GestureDetector(
                          onTap: () =>
                              provider.toggleFavoriteArtist(currentArtist.id),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isFav ? primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: primary),
                            ),
                            child: Text(
                              isFav ? 'Suivi' : 'Suivre',
                              style: TextStyle(
                                color: isFav ? Colors.white : primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Genres ───────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: currentArtist.genres
                    .map<Widget>(
                      (g) => Chip(
                        label: Text(g),
                        visualDensity: VisualDensity.compact,
                        side: BorderSide(color: primary.withAlpha(60)),
                        backgroundColor: primary.withAlpha(15),
                        labelStyle: TextStyle(
                          color: primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),

          // ── Bio ─────────────────────────────────────────────────────────
          if (currentArtist.biography.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
                child: Text(
                  currentArtist.biography,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: muted,
                  ),
                ),
              ),
            ),

          // ── Albums ────────────────────────────────────────────────────────
          if (albums.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 22, 18, 12),
                child: Text(
                  'Albums',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: fg,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 150,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  physics: const BouncingScrollPhysics(),
                  itemCount: albums.length,
                  separatorBuilder: (_, i) => const SizedBox(width: 14),
                  itemBuilder: (ctx, i) {
                    final al = albums[i];
                    return Column(
                      children: [
                        AppNetworkImage(
                          url: al.coverUrl,
                          width: 100,
                          height: 100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: 100,
                          child: Text(
                            al.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: fg,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],

          // ── Chansons ──────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 12),
              child: Text(
                'Chansons',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: fg,
                ),
              ),
            ),
          ),

          songs.isEmpty
              ? SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Text(
                      'Aucune chanson disponible.',
                      style: TextStyle(color: muted, fontSize: 14),
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate((ctx, i) {
                    final s = songs[i];
                    final dur =
                        '${s.duration.inMinutes}:${(s.duration.inSeconds % 60).toString().padLeft(2, '0')}';
                    return ListTile(
                      contentPadding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
                      leading: AppNetworkImage(
                        url: s.coverUrl,
                        width: 44,
                        height: 44,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      title: Text(
                        s.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: fg,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        s.genres.join(' • '),
                        style: TextStyle(fontSize: 11, color: muted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            dur,
                            style: TextStyle(fontSize: 12, color: muted),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.favorite_border_rounded,
                            color: muted,
                            size: 18,
                          ),
                        ],
                      ),
                      onTap: () {
                        provider.playChanson(s);
                        Navigator.of(ctx).push(
                          MaterialPageRoute(
                            builder: (_) => const PageLectureAudio(),
                          ),
                        );
                      },
                    );
                  }, childCount: songs.length),
                ),

          const SliverToBoxAdapter(child: SizedBox(height: 30)),
        ],
      ),
    );
  }
}
