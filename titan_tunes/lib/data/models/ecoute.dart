class Ecoute {
  final String id;
  final String chansonId;
  final String userId;
  final DateTime startedAt;
  final Duration duration;
  final bool completed;

  Ecoute({
    required this.id,
    required this.chansonId,
    required this.userId,
    required this.startedAt,
    required this.duration,
    this.completed = false,
  });

  factory Ecoute.fromJson(Map<String, dynamic> json) {
    final rawStartedAt = json['startedAt'];
    final parsedStartedAt = rawStartedAt is String
        ? DateTime.tryParse(rawStartedAt) ?? DateTime.now()
        : DateTime.now();

    final durationValue = json['durationMs'] ?? json['duration'];
    final parsedDuration = durationValue is int
        ? Duration(milliseconds: durationValue)
        : const Duration();

    return Ecoute(
      id: json['id'] as String? ?? '',
      chansonId: json['chansonId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      startedAt: parsedStartedAt,
      duration: parsedDuration,
      completed: json['completed'] as bool? ?? false,
    );
  }
}
