class Evenement {
  final String id;
  final String name;
  final String location;
  final DateTime date;
  final String artisteId;
  final int availableTickets;
  final double ticketPrice;

  Evenement({
    required this.id,
    required this.name,
    required this.location,
    required this.date,
    required this.artisteId,
    required this.availableTickets,
    required this.ticketPrice,
  });

  factory Evenement.fromJson(Map<String, dynamic> json) {
    final rawDate = json['date'];
    final parsedDate = rawDate is String
        ? DateTime.tryParse(rawDate) ?? DateTime.now()
        : DateTime.now();

    return Evenement(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      location: json['location'] as String? ?? '',
      date: parsedDate,
      artisteId:
          json['artisteId'] as String? ?? json['artistId'] as String? ?? '',
      availableTickets: json['availableTickets'] as int? ?? 0,
      ticketPrice: (json['ticketPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
