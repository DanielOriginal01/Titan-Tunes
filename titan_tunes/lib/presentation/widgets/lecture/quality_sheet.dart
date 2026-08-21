import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:titan_tunes/core/api_config.dart';
import 'package:titan_tunes/core/app_theme.dart';
import 'package:titan_tunes/presentation/widgets/app_network_image.dart';
import 'package:titan_tunes/providers/audio_provider.dart';
import 'package:titan_tunes/providers/auth_provider.dart';

Timer? _sleepTimer;

// ── Bottom sheet d'options audio et de téléchargement ────────────────────────
void showQualitySheet(
  BuildContext ctx,
  AudioProvider provider,
  AuthProvider auth,
  Color primary,
  bool isDark,
) {
  final chanson = provider.currentChanson;
  if (chanson == null) return;

  showModalBottomSheet<void>(
    context: ctx,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (modalCtx) => Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Poignée
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Titre
          Row(
            children: [
              AppNetworkImage(
                url: chanson.coverUrl,
                width: 44,
                height: 44,
                borderRadius: BorderRadius.circular(10),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chanson.title,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      chanson.artistName,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.mutedDark : AppColors.mutedLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Divider(color: isDark ? AppColors.dividerDark : AppColors.divider),
          const SizedBox(height: 8),

          // 1. Ajouter à une playlist
          Material(
            color: Colors.transparent,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: _OptionIcon(icon: Icons.playlist_add_rounded, color: primary),
              title: const Text('Ajouter à une playlist', style: TextStyle(fontWeight: FontWeight.w600)),
              trailing: const Icon(Icons.chevron_right_rounded, size: 20),
              onTap: () {
                Navigator.pop(modalCtx);
                _showAddToPlaylistDialog(ctx, provider, chanson.id, primary, isDark);
              },
            ),
          ),

          // 2. Minuteur de sommeil (Sleep Timer)
          Material(
            color: Colors.transparent,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: _OptionIcon(icon: Icons.timer_outlined, color: Colors.indigoAccent),
              title: const Text('Minuteur de sommeil', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(
                _sleepTimer != null && _sleepTimer!.isActive ? 'Minuteur actif' : 'Désactivé',
                style: TextStyle(fontSize: 11, color: isDark ? AppColors.mutedDark : AppColors.mutedLight),
              ),
              trailing: const Icon(Icons.chevron_right_rounded, size: 20),
              onTap: () {
                Navigator.pop(modalCtx);
                _showSleepTimerDialog(ctx, provider, primary);
              },
            ),
          ),

          // 3. Partager le titre
          Material(
            color: Colors.transparent,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: _OptionIcon(icon: Icons.share_rounded, color: Colors.teal),
              title: const Text('Partager le morceau', style: TextStyle(fontWeight: FontWeight.w600)),
              trailing: const Icon(Icons.chevron_right_rounded, size: 20),
              onTap: () {
                Navigator.pop(modalCtx);
                Clipboard.setData(ClipboardData(
                  text: 'Écoute « ${chanson.title} » par ${chanson.artistName} sur Titan Tunes : ${ApiConfig.defaultBaseUrl}/chansons/${chanson.id}',
                ));
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(
                    content: Text('Lien du morceau « ${chanson.title} » copié dans le presse-papiers !'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
            ),
          ),

          // 4. Téléchargement hors ligne
          Material(
            color: Colors.transparent,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: _OptionIcon(icon: Icons.download_rounded, color: Colors.amber),
              title: const Text('Télécharger hors-ligne', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(
                auth.isSubscribed
                    ? 'Chiffrement AES-256 (3 qualités disponibles)'
                    : 'Abonnement requis pour télécharger',
                style: TextStyle(fontSize: 11, color: isDark ? AppColors.mutedDark : AppColors.mutedLight),
              ),
              trailing: const Icon(Icons.chevron_right_rounded, size: 20),
              onTap: () {
                Navigator.pop(modalCtx);
                _showDownloadQualityDialog(ctx, provider, auth, primary, isDark);
              },
            ),
          ),
        ],
      ),
    ),
  );
}

class _OptionIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _OptionIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }
}

// ── Dialogue : Ajouter à une playlist ─────────────────────────────────────────
void _showAddToPlaylistDialog(
  BuildContext ctx,
  AudioProvider provider,
  String chansonId,
  Color primary,
  bool isDark,
) {
  showDialog(
    context: ctx,
    builder: (dialogCtx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Ajouter à la playlist'),
      content: SizedBox(
        width: double.maxFinite,
        child: provider.playlists.isEmpty
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Aucune playlist trouvée. Créez-en une dans votre bibliothèque.'),
              )
            : ListView.separated(
                shrinkWrap: true,
                itemCount: provider.playlists.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final pl = provider.playlists[i];
                  final contains = pl.chansonIds.contains(chansonId);
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      contains ? Icons.check_circle_rounded : Icons.queue_music_rounded,
                      color: contains ? primary : null,
                    ),
                    title: Text(pl.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('${pl.chansonIds.length} titres'),
                    onTap: () async {
                      Navigator.pop(dialogCtx);
                      if (contains) {
                        await provider.removeSongFromPlaylist(pl.id, chansonId);
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(content: Text('Morceau retiré de « ${pl.title} ».')),
                          );
                        }
                      } else {
                        await provider.addSongToPlaylist(pl.id, chansonId);
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(content: Text('Morceau ajouté à « ${pl.title} » !')),
                          );
                        }
                      }
                    },
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogCtx),
          child: const Text('Fermer'),
        ),
      ],
    ),
  );
}

// ── Dialogue : Minuteur de sommeil ────────────────────────────────────────────
void _showSleepTimerDialog(
  BuildContext ctx,
  AudioProvider provider,
  Color primary,
) {
  showDialog(
    context: ctx,
    builder: (dialogCtx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Minuteur de sommeil'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TimerOptionTile(minutes: 15, onSelect: () => _startTimer(ctx, provider, 15)),
          _TimerOptionTile(minutes: 30, onSelect: () => _startTimer(ctx, provider, 30)),
          _TimerOptionTile(minutes: 45, onSelect: () => _startTimer(ctx, provider, 45)),
          _TimerOptionTile(minutes: 60, onSelect: () => _startTimer(ctx, provider, 60)),
          if (_sleepTimer != null && _sleepTimer!.isActive)
            ListTile(
              leading: const Icon(Icons.timer_off_rounded, color: Colors.redAccent),
              title: const Text('Arrêter le minuteur', style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                _sleepTimer?.cancel();
                _sleepTimer = null;
                Navigator.pop(dialogCtx);
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Minuteur de sommeil annulé.')),
                );
              },
            ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Annuler')),
      ],
    ),
  );
}

void _startTimer(BuildContext ctx, AudioProvider provider, int minutes) {
  _sleepTimer?.cancel();
  _sleepTimer = Timer(Duration(minutes: minutes), () {
    if (provider.isPlaying) {
      provider.togglePlayPause();
    }
  });
  Navigator.pop(ctx);
  ScaffoldMessenger.of(ctx).showSnackBar(
    SnackBar(content: Text('Minuteur de sommeil programmé dans $minutes minutes.')),
  );
}

class _TimerOptionTile extends StatelessWidget {
  final int minutes;
  final VoidCallback onSelect;
  const _TimerOptionTile({required this.minutes, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.access_time_rounded),
      title: Text('$minutes minutes'),
      onTap: onSelect,
    );
  }
}

// ── Dialogue : Qualité de téléchargement ──────────────────────────────────────
void _showDownloadQualityDialog(
  BuildContext ctx,
  AudioProvider provider,
  AuthProvider auth,
  Color primary,
  bool isDark,
) {
  if (!auth.isSubscribed) {
    showDialog(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Abonnement Requis'),
        content: const Text('Le téléchargement hors-ligne avec chiffrement AES-256 est réservé aux abonnés Titan Premium.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Plus tard')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              Navigator.of(ctx).pushNamed('/subscription');
            },
            child: const Text('Voir les offres'),
          ),
        ],
      ),
    );
    return;
  }

  showModalBottomSheet<void>(
    context: ctx,
    backgroundColor: Colors.transparent,
    builder: (sheetCtx) => Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Qualité du téléchargement',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Chiffré AES-256, accès lié à votre abonnement + 7j de grâce.',
            style: TextStyle(fontSize: 12, color: isDark ? AppColors.mutedDark : AppColors.mutedLight),
          ),
          const SizedBox(height: 16),
          QualityTile(
            label: '128 kbps',
            sublabel: 'Économie de données (faible consommation)',
            icon: Icons.data_saver_on_rounded,
            color: AppColors.teal,
            onTap: () => _download(ctx, provider, auth),
          ),
          const SizedBox(height: 8),
          QualityTile(
            label: '256 kbps',
            sublabel: 'Qualité standard recommandée',
            icon: Icons.graphic_eq_rounded,
            color: primary,
            onTap: () => _download(ctx, provider, auth),
          ),
          const SizedBox(height: 8),
          QualityTile(
            label: '320 kbps',
            sublabel: 'Haute définition audio Ultra HD',
            icon: Icons.high_quality_rounded,
            color: AppColors.amber,
            onTap: () => _download(ctx, provider, auth),
          ),
        ],
      ),
    ),
  );
}

Future<void> _download(
  BuildContext ctx,
  AudioProvider provider,
  AuthProvider auth,
) async {
  Navigator.of(ctx).pop();
  final chanson = provider.currentChanson;
  if (chanson == null) return;

  final msg = await provider.downloadCurrentChanson(
    isSubscribed: auth.isSubscribed,
    subscriptionExpiryAt: auth.subscriptionExpiryAt,
  );
  if (ctx.mounted) {
    ScaffoldMessenger.of(ctx)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
      ));
  }
}

// ── Tuile de qualité ──────────────────────────────────────────────────────────
class QualityTile extends StatelessWidget {
  final String label;
  final String sublabel;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const QualityTile({
    super.key,
    required this.label,
    required this.sublabel,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withAlpha(isDark ? 25 : 15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(60)),
        ),
        child: Row(children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: color)),
                Text(sublabel,
                    style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : AppColors.mutedLight)),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: color.withAlpha(160)),
        ]),
      ),
    );
  }
}