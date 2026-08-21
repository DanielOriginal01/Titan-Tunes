class Telechargement {
  final String id;
  final String chansonId;
  final String userId;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int progressPercent;

  Telechargement({
    required this.id,
    required this.chansonId,
    required this.userId,
    required this.startedAt,
    this.completedAt,
    this.progressPercent = 0,
  });

  factory Telechargement.fromJson(Map<String, dynamic> json) {
    final rawStartedAt = json['startedAt'];
    final parsedStartedAt = rawStartedAt is String
        ? DateTime.tryParse(rawStartedAt) ?? DateTime.now()
        : DateTime.now();

    final rawCompletedAt = json['completedAt'];
    final parsedCompletedAt = rawCompletedAt is String
        ? DateTime.tryParse(rawCompletedAt)
        : null;

    return Telechargement(
      id: json['id'] as String? ?? '',
      chansonId: json['chansonId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      startedAt: parsedStartedAt,
      completedAt: parsedCompletedAt,
      progressPercent: json['progressPercent'] as int? ?? 0,
    );
  }
}
