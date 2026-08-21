import 'package:titan_tunes/core/api_config.dart';

class Chanson {
  final String id;
  final String title;
  final String artisteId;
  final String albumId;
  final List<String> genres;
  final Duration duration;
  final int popularity;
  final bool isDownloaded;
  final bool isFavorite;
  final String coverUrl;
  final String lyrics;
  final String audioUrl;
  final String artistName;
  final String albumCoverUrl;

  Chanson({
    required this.id,
    required this.title,
    required this.artisteId,
    required this.albumId,
    required this.genres,
    required this.duration,
    required this.popularity,
    this.isDownloaded = false,
    this.isFavorite = false,
    required this.coverUrl,
    this.lyrics = '',
    this.audioUrl = '',
    this.artistName = '',
    this.albumCoverUrl = '',
  });

  Chanson copyWith({
    String? id,
    String? title,
    String? artisteId,
    String? albumId,
    List<String>? genres,
    Duration? duration,
    int? popularity,
    bool? isDownloaded,
    bool? isFavorite,
    String? coverUrl,
    String? lyrics,
    String? audioUrl,
    String? artistName,
    String? albumCoverUrl,
  }) {
    return Chanson(
      id: id ?? this.id,
      title: title ?? this.title,
      artisteId: artisteId ?? this.artisteId,
      albumId: albumId ?? this.albumId,
      genres: genres ?? this.genres,
      duration: duration ?? this.duration,
      popularity: popularity ?? this.popularity,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      isFavorite: isFavorite ?? this.isFavorite,
      coverUrl: coverUrl ?? this.coverUrl,
      lyrics: lyrics ?? this.lyrics,
      audioUrl: audioUrl ?? this.audioUrl,
      artistName: artistName ?? this.artistName,
      albumCoverUrl: albumCoverUrl ?? this.albumCoverUrl,
    );
  }

  factory Chanson.fromJson(Map<String, dynamic> json) {
    final idValue = json['id'];
    final rawDuration =
        json['duree'] ?? json['duration'] ?? json['durationMs'] ?? 0;
    final parsedDuration = rawDuration is String
        ? _parseDuration(rawDuration)
        : (rawDuration is int
              ? (rawDuration < 10000
                    ? Duration(seconds: rawDuration)
                    : Duration(milliseconds: rawDuration))
              : Duration.zero);

    final audioPath =
        json['urlAudio'] as String? ?? json['audioUrl'] as String? ?? '';
    final rawCover =
        json['coverImage'] as String? ??
        json['coverUrl'] as String? ??
        json['albumCoverUrl'] as String? ??
        '';

    final String parsedId = idValue == null ? '' : idValue.toString();

    final genres =
        (json['genres'] as List<dynamic>?)
            ?.map((value) => value.toString())
            .toList() ??
        (json['genre'] != null ? [json['genre'].toString()] : const <String>[]);

    final String finalCoverUrl = ApiConfig.resolveMediaUrl(
      rawCover,
      endpoint: parsedId.isNotEmpty ? '/chansons/$parsedId/cover' : '',
    );

    final String finalAudioUrl = ApiConfig.resolveMediaUrl(
      audioPath,
      endpoint: parsedId.isNotEmpty ? '/chansons/$parsedId/audio' : '',
    );

    return Chanson(
      id: parsedId,
      title: json['titre'] as String? ?? json['title'] as String? ?? '',
      artisteId: (json['artisteId'] ?? json['artistId'] ?? '').toString(),
      albumId: (json['albumId'] ?? '').toString(),
      genres: genres,
      duration: parsedDuration,
      popularity:
          json['vues'] as int? ??
          json['nbEcoutes'] as int? ??
          json['popularity'] as int? ??
          0,
      isDownloaded: json['isDownloaded'] as bool? ?? false,
      isFavorite: json['isFavorite'] as bool? ?? false,
      coverUrl: finalCoverUrl,
      lyrics: json['lyrics'] as String? ?? json['parole'] as String? ?? '',
      audioUrl: finalAudioUrl,
      artistName:
          json['artisteNom'] as String? ??
          json['artistName'] as String? ??
          json['artiste'] as String? ??
          '',
      albumCoverUrl: (json['albumCoverUrl'] as String? ?? '').startsWith('http')
          ? (json['albumCoverUrl'] as String)
          : finalCoverUrl,
    );
  }

  /// Convenience empty placeholder used by UI wrappers when no real song found.
  factory Chanson.empty() => Chanson(
    id: '',
    title: 'Unknown',
    artisteId: '',
    albumId: '',
    genres: const [],
    duration: Duration.zero,
    popularity: 0,
    coverUrl: '',
  );

  static Duration _parseDuration(String value) {
    final clean = value.trim();
    if (clean.isEmpty) return Duration.zero;
    final parts = clean.split(':');
    if (parts.length == 2) {
      final minutes = int.tryParse(parts[0]) ?? 0;
      final seconds = int.tryParse(parts[1]) ?? 0;
      return Duration(minutes: minutes, seconds: seconds);
    }
    if (parts.length == 3) {
      final hours = int.tryParse(parts[0]) ?? 0;
      final minutes = int.tryParse(parts[1]) ?? 0;
      final seconds = int.tryParse(parts[2]) ?? 0;
      return Duration(hours: hours, minutes: minutes, seconds: seconds);
    }
    return Duration.zero;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artisteId': artisteId,
      'albumId': albumId,
      'genres': genres,
      'duration': duration.inMilliseconds,
      'popularity': popularity,
      'isDownloaded': isDownloaded,
      'isFavorite': isFavorite,
      'coverUrl': coverUrl,
      'lyrics': lyrics,
      'audioUrl': audioUrl,
      'artistName': artistName,
      'albumCoverUrl': albumCoverUrl,
    };
  }
}
