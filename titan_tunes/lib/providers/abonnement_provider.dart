import 'package:flutter/material.dart';
import 'package:titan_tunes/data/models/offre_abonnement.dart';
import 'package:titan_tunes/data/models/paiement_result.dart';
import 'package:titan_tunes/data/services/abonnement_service.dart';

class AbonnementProvider extends ChangeNotifier {
  final AbonnementService _service;

  List<OffreAbonnement> _offres = [];
  bool _isLoadingOffres = false;
  bool _isPaying = false;
  String? _errorMessage;
  SouscriptionResult? _lastSuccessResult;

  AbonnementProvider({required AbonnementService service})
      : _service = service {
    loadOffres();
  }

  List<OffreAbonnement> get offres => List.unmodifiable(_offres);
  bool get isLoadingOffres => _isLoadingOffres;
  bool get isPaying => _isPaying;
  String? get errorMessage => _errorMessage;
  SouscriptionResult? get lastSuccessResult => _lastSuccessResult;

  Future<void> loadOffres() async {
    _isLoadingOffres = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _offres = await _service.getOffres();
    } catch (e) {
      debugPrint('AbonnementProvider.loadOffres error: $e');
      _errorMessage = 'Impossible de charger les offres.';
    } finally {
      _isLoadingOffres = false;
      notifyListeners();
    }
  }

  /// Souscrire et payer en une seule étape Mobile Money
  Future<SouscriptionResult?> souscrireEtPayer({
    required String auditeurId,
    required String offreCode,
    required String modePaiement, // 'FLOOZ' | 'TMONEY' | 'WAVE'
    required String telephone,
  }) async {
    _isPaying = true;
    _errorMessage = null;
    _lastSuccessResult = null;
    notifyListeners();

    try {
      final idempotencyKey = _generateUuidV4();
      final result = await _service.souscrireEtPayer(
        auditeurId: auditeurId,
        offreCode: offreCode,
        modePaiement: modePaiement,
        telephone: telephone,
        idempotencyKey: idempotencyKey,
      );

      _lastSuccessResult = result;
      _isPaying = false;
      notifyListeners();
      return result;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isPaying = false;
      notifyListeners();
      return null;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearSuccess() {
    _lastSuccessResult = null;
    notifyListeners();
  }

  String _generateUuidV4() {
    final now = DateTime.now().microsecondsSinceEpoch;
    final rand = (now % 1000000000).toString().padLeft(9, '0');
    return 'uuid-$now-$rand';
  }
}
