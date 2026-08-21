import 'package:flutter/foundation.dart';
import 'package:titan_tunes/data/models/banniere_promo.dart';
import 'package:titan_tunes/network/network_api_client.dart';

// ─────────────────────────────────────────────────────────────────────────────
// BanniereService
//
// - En mode mock (kUseMockData = true) → renvoie des bannières fictives
// - En mode réseau  → appelle GET /bannieres/actives
// ─────────────────────────────────────────────────────────────────────────────

abstract class BanniereService {
  Future<List<BannierePromo>> fetchActives();
}

// ── Données fictives ──────────────────────────────────────────────────────────
class MockBanniereService implements BanniereService {
  static final List<BannierePromo> _data = [
    BannierePromo(
      id: 'b1',
      titre: 'Nouveau single — Santrinos',
      description: 'Découvrez « Lomé By Night », le nouveau single de Santrinos Raphael. Disponible maintenant sur Titan Tunes.',
      imageUrl: 'https://picsum.photos/seed/santrinos/800/400',
      type: TypePromotion.single,
      artisteNom: 'Santrinos Raphael',
      isEvenement: false,
    ),
    BannierePromo(
      id: 'b2',
      titre: 'Concert Gospel — King Mensah',
      description: 'King Mensah en concert au Palais des Congrès de Lomé. Réservez vos places dès maintenant.',
      imageUrl: 'https://picsum.photos/seed/kingmensah/800/400',
      type: TypePromotion.tournee,
      artisteNom: 'King Mensah',
      dateDebut: DateTime.now().add(const Duration(days: 14)),
      isEvenement: true,
    ),
    BannierePromo(
      id: 'b3',
      titre: 'Titan Tunes Premium',
      description: 'Passez au plan mensuel — audio HD, téléchargements offline et zéro pub. À partir de 2 500 FCFA.',
      imageUrl: 'https://picsum.photos/seed/premium/800/400',
      type: TypePromotion.general,
      isEvenement: false,
      lienCible: '/subscription',
    ),
    BannierePromo(
      id: 'b4',
      titre: 'Album « Afrique » — Fally Ipupa',
      description: 'L\'album tant attendu de Fally Ipupa est enfin disponible. 18 titres, 0 compromis.',
      imageUrl: 'https://picsum.photos/seed/fally/800/400',
      type: TypePromotion.album,
      artisteNom: 'Fally Ipupa',
      isEvenement: false,
    ),
    BannierePromo(
      id: 'b5',
      titre: 'Festival Afrobeats Lomé 2026',
      description: '3 jours de musique, 20 artistes, une seule scène. Du 20 au 22 août au Stade de Lomé.',
      imageUrl: 'https://picsum.photos/seed/festival/800/400',
      type: TypePromotion.tournee,
      dateDebut: DateTime(2026, 8, 20),
      dateFin:   DateTime(2026, 8, 22),
      isEvenement: true,
    ),
  ];

  @override
  Future<List<BannierePromo>> fetchActives() async {
    await Future.delayed(const Duration(milliseconds: 300)); // simule latence
    return _data;
  }
}

// ── Service réseau réel ────────────────────────────────────────────────────────
class RemoteBanniereService implements BanniereService {
  final NetworkApiClient _client;
  RemoteBanniereService({required NetworkApiClient client}) : _client = client;

  @override
  Future<List<BannierePromo>> fetchActives() async {
    try {
      final response = await _client.get('/bannieres/actives');
      final body = response.data as Map<String, dynamic>?;
      if (body == null || body['success'] != true) return [];
      final list = body['data'] as List<dynamic>? ?? [];
      return list
          .map((e) => BannierePromo.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('BanniereService.fetchActives error: $e');
      return [];
    }
  }
}
