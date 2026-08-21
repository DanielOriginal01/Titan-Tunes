class Reversement {
  final int id;
  final double montant;
  final DateTime? dateDemande;
  final DateTime? datePaiement;
  final String statut; // "EN_ATTENTE", "VALIDE", "REJETE", "SUCCES"
  final String modePaiement;
  final String? telephone;
  final String? reference;

  const Reversement({
    required this.id,
    required this.montant,
    this.dateDemande,
    this.datePaiement,
    required this.statut,
    required this.modePaiement,
    this.telephone,
    this.reference,
  });

  factory Reversement.fromJson(Map<String, dynamic> json) {
    DateTime? demande;
    if (json['dateDemande'] != null) {
      demande = DateTime.tryParse(json['dateDemande'].toString());
    }
    DateTime? paiement;
    if (json['datePaiement'] != null) {
      paiement = DateTime.tryParse(json['datePaiement'].toString());
    }

    return Reversement(
      id: json['id'] as int? ?? 0,
      montant: (json['montant'] as num?)?.toDouble() ?? 0.0,
      dateDemande: demande,
      datePaiement: paiement,
      statut: json['statut'] as String? ?? 'SUCCES',
      modePaiement: json['modePaiement'] as String? ??
          json['moyenPaiement'] as String? ??
          'FLOOZ',
      telephone: json['telephone'] as String?,
      reference: json['reference'] as String? ?? json['transactionRef'] as String?,
    );
  }

  String get formattedMontant {
    final formatted = montant.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
    return '$formatted FCFA';
  }
}
