// ─────────────────────────────────────────────────────────────────────────────
// BannierePromo — bannière promotionnelle / événement défilant
//
// Correspond à l'endpoint backend :
//   GET /bannieres/actives  → liste des bannières actives (public)
// ─────────────────────────────────────────────────────────────────────────────

enum TypePromotion { album, single, tournee, general }

class BannierePromo {
  final String         id;
  final String         titre;
  final String         description;
  final String         imageUrl;      // URL présignée ou CDN
  final String?        lienCible;     // deep-link ou URL externe
  final TypePromotion  type;
  final String?        artisteNom;
  final DateTime?      dateDebut;
  final DateTime?      dateFin;
  final bool           isEvenement;   // true = événement, false = pub

  const BannierePromo({
    required this.id,
    required this.titre,
    required this.description,
    required this.imageUrl,
    this.lienCible,
    required this.type,
    this.artisteNom,
    this.dateDebut,
    this.dateFin,
    this.isEvenement = false,
  });

  factory BannierePromo.fromJson(Map<String, dynamic> json) {
    TypePromotion parseType(String? raw) {
      switch (raw?.toUpperCase()) {
        case 'ALBUM':   return TypePromotion.album;
        case 'SINGLE':  return TypePromotion.single;
        case 'TOURNEE': return TypePromotion.tournee;
        default:        return TypePromotion.general;
      }
    }

    DateTime? parseDate(dynamic raw) =>
        raw is String ? DateTime.tryParse(raw) : null;

    return BannierePromo(
      id:          (json['id'] ?? '').toString(),
      titre:       json['titre']       as String? ?? json['title']       as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl:    json['imageUrl']    as String? ?? json['image']       as String? ?? '',
      lienCible:   json['lienCible']   as String? ?? json['lienUrl']     as String?,
      type:        parseType(json['typePromotion'] as String?),
      artisteNom:  json['artisteNom']  as String? ?? json['artistName']  as String?,
      dateDebut:   parseDate(json['dateDebut']),
      dateFin:     parseDate(json['dateFin']),
      isEvenement: json['isEvenement'] as bool? ??
          (json['typePromotion'] == 'TOURNEE'),
    );
  }

  Map<String, dynamic> toJson() => {
    'id':             id,
    'titre':          titre,
    'description':    description,
    'imageUrl':       imageUrl,
    'lienCible':      lienCible,
    'typePromotion':  type.name.toUpperCase(),
    'artisteNom':     artisteNom,
    'dateDebut':      dateDebut?.toIso8601String(),
    'dateFin':        dateFin?.toIso8601String(),
    'isEvenement':    isEvenement,
  };
}
