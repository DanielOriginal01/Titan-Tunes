class Playlist {
  final String id;
  final String title;
  final String description;
  final String creatorId;
  final List<String> chansonIds;
  final bool isPublic;
  final DateTime createdAt;

  Playlist({
    required this.id,
    required this.title,
    required this.description,
    required this.creatorId,
    required this.chansonIds,
    this.isPublic = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Playlist.fromJson(Map<String, dynamic> json) {
    final rawDate = json['createdAt'] ?? json['dateCreation'];
    final parsedDate = rawDate is String
        ? DateTime.tryParse(rawDate) ?? DateTime.now()
        : DateTime.now();

    final rawChansons =
        json['chansons'] as List<dynamic>? ??
        (json['chansonIds'] as List<dynamic>? ?? const []);

    final chansonIds = rawChansons.map((item) {
      if (item is Map) {
        return (item['id'] ?? item['chansonId'] ?? '').toString();
      }
      return item.toString();
    }).toList();

    return Playlist(
      id: (json['id'] ?? '').toString(),
      title: json['nom'] as String? ?? json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      creatorId:
          (json['auditeurId'] ?? json['creatorId'] ?? json['userId'] ?? '')
              .toString(),
      chansonIds: chansonIds,
      isPublic: json['isPublic'] as bool? ?? true,
      createdAt: parsedDate,
    );
  }

  Playlist copyWith({
    String? id,
    String? title,
    String? description,
    String? creatorId,
    List<String>? chansonIds,
    bool? isPublic,
    DateTime? createdAt,
  }) {
    return Playlist(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      creatorId: creatorId ?? this.creatorId,
      chansonIds: chansonIds ?? this.chansonIds,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
