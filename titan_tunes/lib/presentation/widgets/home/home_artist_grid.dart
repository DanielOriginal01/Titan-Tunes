import 'package:flutter/material.dart';
import 'package:titan_tunes/data/models/artiste.dart';
import 'package:titan_tunes/presentation/pages/artist_profile_page.dart';
import 'package:titan_tunes/presentation/widgets/app_network_image.dart';

/// Liste horizontale de cartes artiste.
class HomeArtistGrid extends StatelessWidget {
  final List<Artiste> artists;
  final Color         primary;
  final bool          isDark;

  const HomeArtistGrid({
    super.key,
    required this.artists,
    required this.primary,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (artists.isEmpty) {
      return Center(child: Text('Aucun artiste',
        style: TextStyle(
            color: isDark ? Colors.white38 : Colors.black38)));
    }
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      physics: const BouncingScrollPhysics(),
      itemCount: artists.length,
      separatorBuilder: (_, __) => const SizedBox(width: 14),
      itemBuilder: (_, i) => _ArtistCard(
          artist: artists[i], primary: primary, isDark: isDark),
    );
  }
}

class _ArtistCard extends StatelessWidget {
  final Artiste artist;
  final Color   primary;
  final bool    isDark;
  const _ArtistCard(
      {required this.artist, required this.primary, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ArtistProfilePage(artist: artist))),
      child: SizedBox(width: 110, child: Column(children: [
        SizedBox(
          width: 96,
          height: 96,
          child: ClipOval(
            child: artist.pictureUrl.isNotEmpty
                ? AppNetworkImage(url: artist.pictureUrl, width: 96, height: 96)
                : Container(
                    width: 96,
                    height: 96,
                    color: primary.withAlpha(20),
                    child: Icon(Icons.person_rounded, color: primary, size: 32),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(artist.name,
          maxLines: 1, overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12,
              color: isDark ? Colors.white : Colors.black)),
        Text(
          artist.genres.isNotEmpty ? artist.genres.first : '',
          maxLines: 1, overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11,
              color: isDark ? Colors.white38 : Colors.black38)),
      ])),
    );
  }
}

/// Tile playlist dans la liste verticale.
class HomePlaylistTile extends StatelessWidget {
  final dynamic playlist;
  final String  coverUrl;
  final Color   primary;
  final bool    isDark;
  final Color   fg;
  final Color   muted;

  const HomePlaylistTile({
    super.key,
    required this.playlist,
    required this.coverUrl,
    required this.primary,
    required this.isDark,
    required this.fg,
    required this.muted,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
      child: Row(children: [
        AppNetworkImage(
          url: coverUrl,
          width: 52,
          height: 52,
          borderRadius: BorderRadius.circular(10),
          errorWidget: _Cover(primary: primary),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text(playlist.title as String,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: fg),
            maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 3),
          Text('${(playlist.chansonIds as List).length} titres',
            style: TextStyle(fontSize: 12, color: muted)),
        ])),
        Icon(Icons.play_circle_fill_rounded, color: primary, size: 36),
      ]),
    );
  }
}

class _Cover extends StatelessWidget {
  final Color primary;
  const _Cover({required this.primary});
  @override
  Widget build(BuildContext context) => Container(
    width: 52, height: 52,
    color: primary.withAlpha(25),
    child: Icon(Icons.music_note_rounded, color: primary, size: 24));
}
