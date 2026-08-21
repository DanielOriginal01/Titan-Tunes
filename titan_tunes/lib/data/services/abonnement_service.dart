import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:titan_tunes/data/models/offre_abonnement.dart';
import 'package:titan_tunes/data/models/paiement_result.dart';
import 'package:titan_tunes/network/network_api_client.dart';

abstract class AbonnementService {
  Future<List<OffreAbonnement>> getOffres();
  Future<SouscriptionResult> souscrireEtPayer({
    required String auditeurId,
    required String offreCode,
    required String modePaiement, // 'FLOOZ' | 'TMONEY' | 'WAVE'
    required String telephone,
    required String idempotencyKey,
  });
}

class RemoteAbonnementService implements AbonnementService {
  final NetworkApiClient _client;

  RemoteAbonnementService({required NetworkApiClient client})
      : _client = client;

  @override
  Future<List<OffreAbonnement>> getOffres() async {
    try {
      final response = await _client.get('/abonnements/offres');
      final body = _parseBody(response.data);
      final rawData = body['data'];

      if (rawData is List) {
        return rawData
            .map((e) =>
                OffreAbonnement.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      return _fallbackOffres();
    } catch (e) {
      debugPrint('RemoteAbonnementService.getOffres error: $e');
      return _fallbackOffres();
    }
  }

  @override
  Future<SouscriptionResult> souscrireEtPayer({
    required String auditeurId,
    required String offreCode,
    required String modePaiement,
    required String telephone,
    required String idempotencyKey,
  }) async {
    try {
      final payload = {
        'auditeurId': int.tryParse(auditeurId) ?? auditeurId,
        'offreCode': offreCode,
        'offerCode': offreCode,
        'modePaiement': modePaiement.toUpperCase(),
        'telephone': telephone.replaceAll(RegExp(r'\s+'), ''),
        'numeroPaiement': telephone.replaceAll(RegExp(r'\s+'), ''),
        'idempotencyKey': idempotencyKey,
      };

      final response = await _client.post(
        '/abonnements/souscrire-et-payer',
        data: payload,
      );

      final body = _parseBody(response.data);
      final statusCode = response.statusCode ?? 0;

      if (statusCode == 201 || statusCode == 200) {
        final data = body['data'] as Map<String, dynamic>? ?? body;
        return SouscriptionResult.fromJson(data);
      } else if (statusCode == 402) {
        final msg = body['message'] as String? ??
            'Paiement refusé par l\'opérateur. Vérifiez votre solde.';
        throw Exception(msg);
      } else {
        final msg = body['message'] as String? ??
            body['errors']?.toString() ??
            'Erreur lors du paiement ($statusCode)';
        throw Exception(msg);
      }
    } catch (e) {
      debugPrint('RemoteAbonnementService.souscrireEtPayer error: $e');
      rethrow;
    }
  }

  Map<String, dynamic> _parseBody(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    if (raw is String) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {}
    }
    return {};
  }

  List<OffreAbonnement> _fallbackOffres() {
    return const [
      OffreAbonnement(
        code: 'DAILY',
        label: 'Offre Journalière',
        prixFcfa: 100.0,
        dureeDays: 1,
        description: 'Accès illimité pendant 24h — idéal pour tester',
        avantages: [
          'Écoute illimitée 24h',
          'Sans publicité',
          'Streaming haute qualité',
        ],
        prixParJour: 100.0,
      ),
      OffreAbonnement(
        code: 'WEEKLY',
        label: 'Offre Hebdomadaire',
        prixFcfa: 500.0,
        dureeDays: 7,
        description: '7 jours d\'accès complet — flexibilité maximale',
        avantages: [
          'Écoute illimitée 7 jours',
          'Sans publicité',
          'Téléchargement hors ligne (10 chansons)',
          'Streaming haute qualité',
        ],
        prixParJour: 71.43,
      ),
      OffreAbonnement(
        code: 'MONTHLY',
        label: 'Offre Mensuelle',
        prixFcfa: 2000.0,
        dureeDays: 30,
        description: 'Le meilleur rapport qualité-prix — 30 jours complets',
        avantages: [
          'Écoute illimitée 30 jours',
          'Sans publicité',
          'Téléchargement hors ligne (50 chansons)',
          'Streaming haute qualité',
          'Accès aux avant-premières exclusives',
        ],
        prixParJour: 66.67,
      ),
      OffreAbonnement(
        code: 'QUARTERLY',
        label: 'Offre Trimestrielle',
        prixFcfa: 5000.0,
        dureeDays: 90,
        description: '3 mois au prix de 2,5 — économisez 1000 FCFA',
        avantages: [
          'Écoute illimitée 90 jours',
          'Sans publicité',
          'Téléchargement hors ligne (100 chansons)',
          'Streaming haute qualité',
          'Contenu exclusif artistes',
        ],
        prixParJour: 55.56,
      ),
      OffreAbonnement(
        code: 'YEARLY',
        label: 'Offre Annuelle',
        prixFcfa: 18000.0,
        dureeDays: 365,
        description: '12 mois au prix de 9 — la meilleure économie',
        avantages: [
          'Écoute illimitée 365 jours',
          'Sans publicité',
          'Téléchargement hors ligne illimité',
          'Streaming haute qualité',
          'Badge abonné annuel',
          'Support prioritaire',
        ],
        prixParJour: 49.32,
      ),
    ];
  }
}

class MockAbonnementService implements AbonnementService {
  @override
  Future<List<OffreAbonnement>> getOffres() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const [
      OffreAbonnement(
        code: 'DAILY',
        label: 'Offre Journalière',
        prixFcfa: 100.0,
        dureeDays: 1,
        description: 'Accès illimité pendant 24h',
        avantages: ['Écoute illimitée 24h', 'Sans publicité'],
        prixParJour: 100.0,
      ),
      OffreAbonnement(
        code: 'WEEKLY',
        label: 'Offre Hebdomadaire',
        prixFcfa: 500.0,
        dureeDays: 7,
        description: '7 jours complets',
        avantages: ['Écoute illimitée 7j', '10 téléchargements'],
        prixParJour: 71.43,
      ),
      OffreAbonnement(
        code: 'MONTHLY',
        label: 'Offre Mensuelle',
        prixFcfa: 2000.0,
        dureeDays: 30,
        description: '30 jours complets',
        avantages: ['Écoute illimitée 30j', '50 téléchargements'],
        prixParJour: 66.67,
      ),
      OffreAbonnement(
        code: 'YEARLY',
        label: 'Offre Annuelle',
        prixFcfa: 18000.0,
        dureeDays: 365,
        description: '1 an complet (économisez 6000 FCFA)',
        avantages: ['Écoute illimitée 365j', 'Téléchargements illimités'],
        prixParJour: 49.32,
      ),
    ];
  }

  @override
  Future<SouscriptionResult> souscrireEtPayer({
    required String auditeurId,
    required String offreCode,
    required String modePaiement,
    required String telephone,
    required String idempotencyKey,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    final now = DateTime.now();
    return SouscriptionResult(
      succes: true,
      message: 'Abonnement $offreCode activé avec succès en mode démo.',
      paiement: DetailPaiement(
        montant: 2000.0,
        datePaid: now,
        modePaiement: modePaiement,
        operateur: '$modePaiement Togo',
        statut: 'SUCCES',
        transactionRef: 'MOCK-${now.millisecondsSinceEpoch}',
      ),
      abonnement: DetailAbonnement(
        id: 999,
        offerCode: offreCode,
        mobileMoneyRef: 'MOCK-${now.millisecondsSinceEpoch}',
        startDate: now,
        endDate: now.add(const Duration(days: 30)),
        active: true,
        auditeurId: int.tryParse(auditeurId) ?? 1,
      ),
    );
  }
}
