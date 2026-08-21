import 'package:flutter/material.dart';
import 'package:titan_tunes/data/models/chanson.dart';
import 'package:titan_tunes/presentation/widgets/app_network_image.dart';

/// Bannière « À la une » avec pochette, titre, artiste et bouton play.
class HomeFeaturedBanner extends StatelessWidget {
  final Chanson       chanson;
  final Color         primary;
  final bool          isDark;
  final VoidCallback  onTap;

  const HomeFeaturedBanner({
    super.key,
    required this.chanson,
    required this.primary,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
            color: primary, borderRadius: BorderRadius.circular(18)),
        child: Stack(fit: StackFit.expand, children: [
          // Pochette à droite
          Positioned(
            right: 0, top: 0, bottom: 0, width: 150,
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(right: Radius.circular(18)),
              child: AppNetworkImage(
                url: chanson.coverUrl,
                fit: BoxFit.cover,
                width: 150,
                errorWidget: Container(color: primary.withAlpha(80)),
              ),
            ),
          ),
          // Dégradé sur la pochette
          Positioned(
            right: 0, top: 0, bottom: 0, width: 150,
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(right: Radius.circular(18)),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    colors: [Colors.transparent, primary],
                    stops: const [0.0, 0.7],
                  ),
                ),
              ),
            ),
          ),
          // Texte à gauche
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('À la une',
                    style: TextStyle(color: Colors.white, fontSize: 10,
                        fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 8),
                Text(chanson.title,
                  style: const TextStyle(color: Colors.white, fontSize: 18,
                      fontWeight: FontWeight.w800),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(chanson.artistName,
                  style: TextStyle(
                      color: Colors.white.withAlpha(200), fontSize: 13)),
              ],
            ),
          ),
          // Bouton play
          Positioned(
            bottom: 14, right: 14,
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(
                    color: Colors.black.withAlpha(40), blurRadius: 8)],
              ),
              child: Icon(Icons.play_arrow_rounded, color: primary, size: 22),
            ),
          ),
        ]),
      ),
    );
  }
}
