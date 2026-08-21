import 'package:titan_tunes/core/api_config.dart';

class Album {
  final String id;
  final String title;
  final String artisteId;
  final DateTime releaseDate;
  final String coverUrl;
  final List<String> genres;
  final List<String> chansonIds;

  Album({
    required this.id,
    required this.title,
    required this.artisteId,
    required this.releaseDate,
    required this.coverUrl,
    required this.genres,
    required this.chansonIds,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    final rawDate = json['dateSortie'] ?? json['releaseDate'] ?? json['releasedAt'];
    final parsedDate = rawDate is String
        ? DateTime.tryParse(rawDate) ?? DateTime.now()
        : DateTime.now();

    final rawCover = json['coverImage'] as String? ?? json['coverUrl'] as String? ?? '';
    final rawId = (json['id'] ?? '').toString();

    // Résolution de la couverture — endpoint direct du backend si pas déjà une URL
    final String finalCoverUrl = ApiConfig.resolveMediaUrl(
      rawCover,
      endpoint: rawId.isNotEmpty ? '/albums/$rawId/cover' : '',
    );

    return Album(
      id: rawId,
      title: json['title'] as String? ?? '',
      artisteId:
          (json['artisteId'] ?? json['artistId'] ?? '').toString(),
      releaseDate: parsedDate,
      coverUrl: finalCoverUrl,
      genres:
          (json['genres'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      chansonIds:
          (json['chansonIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }
}
