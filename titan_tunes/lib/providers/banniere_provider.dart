import 'package:flutter/foundation.dart';
import 'package:titan_tunes/data/models/banniere_promo.dart';
import 'package:titan_tunes/data/services/banniere_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// BanniereProvider — état des bannières promotionnelles
// ─────────────────────────────────────────────────────────────────────────────
class BanniereProvider extends ChangeNotifier {
  final BanniereService _service;

  List<BannierePromo> _bannieres = [];
  bool  _isLoading = false;
  String? _error;

  BanniereProvider({required BanniereService service}) : _service = service {
    load();
  }

  List<BannierePromo> get bannieres        => List.unmodifiable(_bannieres);
  List<BannierePromo> get pubs             =>
      _bannieres.where((b) => !b.isEvenement).toList();
  List<BannierePromo> get evenements       =>
      _bannieres.where((b) =>  b.isEvenement).toList();
  bool                get isLoading        => _isLoading;
  String?             get error            => _error;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _bannieres = await _service.fetchActives();
    } catch (e) {
      _error = e.toString();
      debugPrint('BanniereProvider.load error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => load();
}
