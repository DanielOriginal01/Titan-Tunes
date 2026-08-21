class Categorie {
  final int id;
  final String nom;

  const Categorie({
    required this.id,
    required this.nom,
  });

  factory Categorie.fromJson(Map<String, dynamic> json) {
    return Categorie(
      id: json['id'] as int? ?? 0,
      nom: json['nom'] as String? ?? json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
    };
  }
}
