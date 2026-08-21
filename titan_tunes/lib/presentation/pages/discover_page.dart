import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:titan_tunes/data/services/recherche_service.dart';
import 'package:titan_tunes/presentation/pages/search_page.dart';
import 'package:titan_tunes/presentation/widgets/app_network_image.dart';
import 'package:titan_tunes/presentation/widgets/glassmorphism_widgets.dart';
import 'package:titan_tunes/providers/audio_provider.dart';

class DiscoverPage extends StatelessWidget {
  final AudioProvider provider;

  const DiscoverPage({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    return SafeArea(
      child: PageBackground(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          children: [
            // ── Header ─────────────────────────────────────────────────────
            const GlassPageHeader(
              title: 'Découvrir',
              subtitle: 'Des sélections fraîches pour tous vos moods',
              tag: 'À la une',
            ),
            const SizedBox(height: 20),

            // ── Bouton de recherche interactif ──────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SearchPage(
                        chansons: provider.chansons,
                        rechercheService: context.read<RechercheService?>(),
                      ),
                    ),
                  ),
                  child: GlassPanel(
                    accentColor: primaryColor,
                    borderRadius: BorderRadius.circular(28),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search_rounded, color: primaryColor),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Rechercher des titres, artistes, playlists…',
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.hintColor,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: theme.hintColor.withAlpha(150),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Albums à la une ─────────────────────────────────────────────
            Row(
              children: [
                Container(
                  width: 4,
                  height: 18,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Text(
                  'Albums à la une',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            if (provider.albums.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Aucun album disponible pour le moment.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              )
            else
              SizedBox(
                height: 200,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: provider.albums.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final album = provider.albums[index];
                    return GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => SearchPage(
                            chansons: provider.chansons,
                            rechercheService: context.read<RechercheService?>(),
                          ),
                        ),
                      ),
                      child: Container(
                        width: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withAlpha(35),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                          border: Border.all(
                            color: primaryColor.withAlpha(isDark ? 40 : 25),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              FadeInImage.assetNetwork(
                                placeholder:
                                    'assets/logos/titan_orange_tunes.png',
                                image: album.coverUrl,
                                fit: BoxFit.cover,
                                imageErrorBuilder: (c, e, s) => Container(
                                  color: primaryColor.withAlpha(25),
                                  child: Icon(
                                    Icons.music_note,
                                    size: 40,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                              // Dégradé en bas
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Colors.black.withAlpha(210),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                  child: Text(
                                    album.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 24),

            // ── Recommandations ─────────────────────────────────────────────
            Row(
              children: [
                Container(
                  width: 4,
                  height: 18,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Text(
                  'Recommandé pour vous',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            if (provider.chansons.isEmpty)
              Text(
                'Aucune chanson disponible.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor,
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.chansons.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final chanson = provider.chansons[i];
                  return GlassPanel(
                    accentColor: primaryColor,
                    borderRadius: BorderRadius.circular(22),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      onTap: () => provider.playChanson(chanson),
                      leading: AppNetworkImage(
                        url: chanson.coverUrl,
                        width: 52,
                        height: 52,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      title: Text(
                        chanson.title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        chanson.artistName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.hintColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        onPressed: () => provider.toggleFavorite(chanson),
                        icon: Icon(
                          chanson.isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: chanson.isFavorite
                              ? Colors.redAccent
                              : primaryColor,
                        ),
                      ),
                    ),
                  );
                },
              ),

            const SizedBox(height: 32),
            Center(
              child: Text(
                'powered by NITCH-Corp',
                style: theme.textTheme.bodySmall?.copyWith(
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
