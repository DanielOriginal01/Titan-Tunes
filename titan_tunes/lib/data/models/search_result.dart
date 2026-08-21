import 'package:titan_tunes/data/models/album.dart';
import 'package:titan_tunes/data/models/artiste.dart';
import 'package:titan_tunes/data/models/chanson.dart';
import 'package:titan_tunes/data/models/playlist.dart';

class SearchGlobalResult {
  final List<Chanson> chansons;
  final List<Artiste> artistes;
  final List<Album> albums;
  final List<Playlist> playlists;

  const SearchGlobalResult({
    required this.chansons,
    required this.artistes,
    required this.albums,
    required this.playlists,
  });

  factory SearchGlobalResult.fromJson(Map<String, dynamic> json) {
    final rawChansons = json['chansons'] as List<dynamic>? ?? [];
    final rawArtistes = json['artistes'] as List<dynamic>? ?? [];
    final rawAlbums = json['albums'] as List<dynamic>? ?? [];
    final rawPlaylists = json['playlists'] as List<dynamic>? ?? [];

    return SearchGlobalResult(
      chansons: rawChansons
          .map((e) => Chanson.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      artistes: rawArtistes
          .map((e) => Artiste.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      albums: rawAlbums
          .map((e) => Album.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      playlists: rawPlaylists
          .map((e) => Playlist.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }

  bool get isEmpty =>
      chansons.isEmpty && artistes.isEmpty && albums.isEmpty && playlists.isEmpty;
  bool get isNotEmpty => !isEmpty;
}
