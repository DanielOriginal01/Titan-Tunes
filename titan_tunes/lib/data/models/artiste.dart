import 'package:titan_tunes/core/api_config.dart';

class Artiste {
  final String id;
  final String name;
  final String label;
  final String country;
  final int followers;
  final String pictureUrl;
  final List<String> genres;
  final String biography;
  final String photoUrl;

  Artiste({
    required this.id,
    required this.name,
    required this.label,
    required this.country,
    required this.followers,
    required this.pictureUrl,
    required this.genres,
    this.biography = '',
    this.photoUrl = '',
  });

  factory Artiste.fromJson(Map<String, dynamic> json) {
    final rawId = (json['id'] ?? '').toString();

    // Photo de profil / avatar
    final rawProfil = json['photoProfil'] as String? ?? 
                    json['avatarUrl'] as String? ?? 
                    json['pictureUrl'] as String? ?? '';
    // Photo de couverture / bannière
    final rawCouverture = json['photoCouverture'] as String? ?? 
                         json['photoUrl'] as String? ?? 
                         json['imageUrl'] as String? ?? '';

    final name = json['artistName'] as String? ??
                 json['nomArtistique'] as String? ??
                 json['name'] as String? ??
                 json['username'] as String? ??
                 '';

    // Résolution des URLs — vers les endpoints directs du backend
    final String profilUrl = ApiConfig.resolveMediaUrl(
      rawProfil,
      endpoint: rawId.isNotEmpty ? '/artistes/$rawId/photo-profil' : '',
    );

    final String coverUrl = ApiConfig.resolveMediaUrl(
      rawCouverture,
      endpoint: rawId.isNotEmpty ? '/artistes/$rawId/photo' : '',
    );

    return Artiste(
      id: rawId,
      name: name,
      label: json['label'] as String? ?? '',
      country: json['country'] as String? ?? json['pays'] as String? ?? '',
      followers: json['followers'] as int? ?? json['nbAbonnes'] as int? ?? 0,
      pictureUrl: profilUrl,
      genres:
          (json['genres'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const <String>[],
      biography: json['bio'] as String? ?? json['biography'] as String? ?? '',
      photoUrl: coverUrl,
    );
  }

  Artiste copyWith({
    String? id,
    String? name,
    String? label,
    String? country,
    int? followers,
    String? pictureUrl,
    List<String>? genres,
    String? biography,
    String? photoUrl,
  }) {
    return Artiste(
      id: id ?? this.id,
      name: name ?? this.name,
      label: label ?? this.label,
      country: country ?? this.country,
      followers: followers ?? this.followers,
      pictureUrl: pictureUrl ?? this.pictureUrl,
      genres: genres ?? this.genres,
      biography: biography ?? this.biography,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}