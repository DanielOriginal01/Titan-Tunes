class DetailPaiement {
  final int? idPaiement;
  final double montant;
  final DateTime? datePaid;
  final String modePaiement;
  final String operateur;
  final String statut;
  final String transactionRef;
  final String? message;
  final int? abonnementId;

  const DetailPaiement({
    this.idPaiement,
    required this.montant,
    this.datePaid,
    required this.modePaiement,
    required this.operateur,
    required this.statut,
    required this.transactionRef,
    this.message,
    this.abonnementId,
  });

  factory DetailPaiement.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    if (json['datePaid'] != null) {
      parsedDate = DateTime.tryParse(json['datePaid'].toString());
    }

    return DetailPaiement(
      idPaiement: json['idPaiement'] as int?,
      montant: (json['montant'] as num?)?.toDouble() ?? 0.0,
      datePaid: parsedDate,
      modePaiement: json['modePaiement'] as String? ?? 'FLOOZ',
      operateur: json['operateur'] as String? ?? '',
      statut: json['statut'] as String? ?? 'SUCCES',
      transactionRef: json['transactionRef'] as String? ?? '',
      message: json['message'] as String?,
      abonnementId: json['abonnementId'] as int?,
    );
  }
}

class DetailAbonnement {
  final int id;
  final String offerCode;
  final String mobileMoneyRef;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool active;
  final int auditeurId;

  const DetailAbonnement({
    required this.id,
    required this.offerCode,
    required this.mobileMoneyRef,
    this.startDate,
    this.endDate,
    required this.active,
    required this.auditeurId,
  });

  factory DetailAbonnement.fromJson(Map<String, dynamic> json) {
    DateTime? start;
    if (json['startDate'] != null) {
      start = DateTime.tryParse(json['startDate'].toString());
    }
    DateTime? end;
    if (json['endDate'] != null) {
      end = DateTime.tryParse(json['endDate'].toString());
    }

    return DetailAbonnement(
      id: json['id'] as int? ?? 0,
      offerCode: json['offerCode'] as String? ?? 'MONTHLY',
      mobileMoneyRef: json['mobileMoneyRef'] as String? ?? '',
      startDate: start,
      endDate: end,
      active: json['active'] as bool? ?? true,
      auditeurId: json['auditeurId'] as int? ?? 0,
    );
  }
}

class SouscriptionResult {
  final bool succes;
  final String message;
  final DetailPaiement? paiement;
  final DetailAbonnement? abonnement;

  const SouscriptionResult({
    required this.succes,
    required this.message,
    this.paiement,
    this.abonnement,
  });

  factory SouscriptionResult.fromJson(Map<String, dynamic> json) {
    return SouscriptionResult(
      succes: json['succes'] as bool? ?? (json['success'] as bool? ?? true),
      message: json['message'] as String? ?? 'Abonnement activé avec succès',
      paiement: json['paiement'] != null
          ? DetailPaiement.fromJson(
              Map<String, dynamic>.from(json['paiement'] as Map))
          : null,
      abonnement: json['abonnement'] != null
          ? DetailAbonnement.fromJson(
              Map<String, dynamic>.from(json['abonnement'] as Map))
          : null,
    );
  }
}
