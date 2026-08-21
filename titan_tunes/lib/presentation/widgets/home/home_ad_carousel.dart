import 'dart:async';
import 'package:flutter/material.dart';
import 'package:titan_tunes/data/models/banniere_promo.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HomeAdCarousel
//
// Carrousel auto-défilant style Gozem :
//   • Défilement automatique toutes les 4 s
//   • Indicateurs ronds en bas
//   • Badge type (Pub / Événement / Single / Album / Tournée)
//   • Dégradé bas pour lisibilité du texte
//   • Tap → callback onTap(banniere)
// ─────────────────────────────────────────────────────────────────────────────
class HomeAdCarousel extends StatefulWidget {
  final List<BannierePromo> items;
  final Color               primary;
  final bool                isDark;
  final void Function(BannierePromo)? onTap;

  const HomeAdCarousel({
    super.key,
    required this.items,
    required this.primary,
    required this.isDark,
    this.onTap,
  });

  @override
  State<HomeAdCarousel> createState() => _HomeAdCarouselState();
}

class _HomeAdCarouselState extends State<HomeAdCarousel> {
  late final PageController _pageCtrl;
  Timer?  _timer;
  int     _current = 0;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController(viewportFraction: 0.92);
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || widget.items.isEmpty) return;
      final next = (_current + 1) % widget.items.length;
      _pageCtrl.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    return Column(children: [
      SizedBox(
        height: 160,
        child: PageView.builder(
          controller:  _pageCtrl,
          itemCount:   widget.items.length,
          onPageChanged: (i) => setState(() => _current = i),
          itemBuilder: (_, i) {
            final item = widget.items[i];
            return _CarouselCard(
              item:    item,
              primary: widget.primary,
              isDark:  widget.isDark,
              onTap:   () => widget.onTap?.call(item),
            );
          },
        ),
      ),
      const SizedBox(height: 10),
      // ── Indicateurs ─────────────────────────────────────────────────
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(widget.items.length, (i) {
          final active = i == _current;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width:  active ? 20 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: active
                  ? widget.primary
                  : widget.primary.withAlpha(widget.isDark ? 80 : 60),
              borderRadius: BorderRadius.circular(99),
            ),
          );
        }),
      ),
    ]);
  }
}

// ── Carte d'une bannière ──────────────────────────────────────────────────────
class _CarouselCard extends StatelessWidget {
  final BannierePromo item;
  final Color         primary;
  final bool          isDark;
  final VoidCallback  onTap;

  const _CarouselCard({
    required this.item,
    required this.primary,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: primary.withAlpha(30),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(fit: StackFit.expand, children: [
            // ── Image de fond ──────────────────────────────────────────
            item.imageUrl.isNotEmpty
                ? Image.network(
                    item.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _Placeholder(primary: primary),
                  )
                : _Placeholder(primary: primary),

            // ── Dégradé bas ────────────────────────────────────────────
            Positioned(
              bottom: 0, left: 0, right: 0, height: 90,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withAlpha(200),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // ── Texte + badge ──────────────────────────────────────────
            Positioned(
              bottom: 12, left: 14, right: 14,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Badge type
                        _TypeBadge(item: item, primary: primary),
                        const SizedBox(height: 4),
                        // Titre
                        Text(
                          item.titre,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        // Description courte
                        if (item.description.isNotEmpty)
                          Text(
                            item.description,
                            style: TextStyle(
                              color: Colors.white.withAlpha(200),
                              fontSize: 11,
                              shadows: const [Shadow(
                                  color: Colors.black54, blurRadius: 3)],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  // Bouton action
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      item.isEvenement ? 'Voir' : 'Découvrir',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ── Badge type de promotion ───────────────────────────────────────────────────
class _TypeBadge extends StatelessWidget {
  final BannierePromo item;
  final Color         primary;
  const _TypeBadge({required this.item, required this.primary});

  @override
  Widget build(BuildContext context) {
    final (label, icon, color) = switch (item.type) {
      TypePromotion.album   => ('Album',    Icons.album_rounded,         const Color(0xFF7B2FBE)),
      TypePromotion.single  => ('Single',   Icons.music_note_rounded,    const Color(0xFFD84315)),
      TypePromotion.tournee => ('Événement',Icons.event_rounded,         const Color(0xFF1565C0)),
      TypePromotion.general => ('Promo',    Icons.local_offer_rounded,   const Color(0xFF1B5E20)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(220),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 10, color: Colors.white),
        const SizedBox(width: 4),
        Text(label,
          style: const TextStyle(
            color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

// ── Placeholder quand l'image échoue ─────────────────────────────────────────
class _Placeholder extends StatelessWidget {
  final Color primary;
  const _Placeholder({required this.primary});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: primary.withAlpha(30),
      child: Center(child: Icon(
          Icons.image_not_supported_rounded,
          color: primary.withAlpha(120), size: 40)),
    );
  }
}
