class OffreAbonnement {
  final String code;
  final String label;
  final double prixFcfa;
  final int dureeDays;
  final String description;
  final List<String> avantages;
  final double prixParJour;

  const OffreAbonnement({
    required this.code,
    required this.label,
    required this.prixFcfa,
    required this.dureeDays,
    required this.description,
    required this.avantages,
    required this.prixParJour,
  });

  factory OffreAbonnement.fromJson(Map<String, dynamic> json) {
    final rawAvantages = json['avantages'];
    final List<String> listAvantages = [];
    if (rawAvantages is List) {
      listAvantages.addAll(rawAvantages.map((e) => e.toString()));
    }

    return OffreAbonnement(
      code: json['code'] as String? ?? 'MONTHLY',
      label: json['label'] as String? ?? 'Offre Standard',
      prixFcfa: (json['prixFcfa'] as num?)?.toDouble() ?? 2000.0,
      dureeDays: json['dureeDays'] as int? ?? 30,
      description: json['description'] as String? ?? '',
      avantages: listAvantages,
      prixParJour: (json['prixParJour'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'label': label,
      'prixFcfa': prixFcfa,
      'dureeDays': dureeDays,
      'description': description,
      'avantages': avantages,
      'prixParJour': prixParJour,
    };
  }

  String get formattedPrice {
    final formatted = prixFcfa.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
    return '$formatted FCFA';
  }

  String get durationLabel {
    if (dureeDays == 1) return '24 heures';
    if (dureeDays == 7) return '7 jours';
    if (dureeDays == 30) return '1 mois';
    if (dureeDays == 90) return '3 mois';
    if (dureeDays == 365) return '1 an';
    return '$dureeDays jours';
  }
}
