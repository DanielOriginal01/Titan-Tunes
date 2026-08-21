import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:titan_tunes/core/app_theme.dart';
import 'package:titan_tunes/presentation/pages/lecture/page_lecture_audio.dart';
import 'package:titan_tunes/presentation/widgets/app_network_image.dart';
import 'package:titan_tunes/providers/audio_provider.dart';

/// Mini-player style maquette — bande fine au-dessus de la nav bar
class MiniPlayerWidget extends StatelessWidget {
  const MiniPlayerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AudioProvider>();
    final chanson = provider.currentChanson;
    if (chanson == null) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final bg = isDark ? AppColors.cardDark : AppColors.cardLight;
    final fg = isDark ? Colors.white : Colors.black;
    final muted = isDark ? Colors.white54 : Colors.black45;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (_, _, _) => const PageLectureAudio(),
          transitionsBuilder: (_, anim, _, child) => SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 320),
        ),
      ),
      child: Container(
        color: bg,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Barre de progression réelle
            LinearProgressIndicator(
              value: provider.progressFraction,
              minHeight: 2,
              backgroundColor: primary.withAlpha(20),
              valueColor: AlwaysStoppedAnimation<Color>(primary),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  // Pochette
                  Hero(
                    tag: 'cover_${chanson.id}',
                    child: AppNetworkImage(
                      url: chanson.coverUrl,
                      width: 42,
                      height: 42,
                      borderRadius: BorderRadius.circular(8),
                      errorWidget: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: primary.withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.music_note, color: primary, size: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          chanson.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: fg,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          chanson.artistName.isNotEmpty
                              ? chanson.artistName
                              : chanson.artisteId,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11, color: muted),
                        ),
                      ],
                    ),
                  ),
                  // Buffering
                  if (provider.isBuffering) ...[
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: primary,
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  // Prev
                  GestureDetector(
                    onTap: provider.playPrevious,
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        Icons.skip_previous_rounded,
                        color: primary.withAlpha(200),
                        size: 22,
                      ),
                    ),
                  ),
                  // Play/Pause
                  GestureDetector(
                    onTap: provider.togglePlayPause,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        provider.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  // Next
                  GestureDetector(
                    onTap: provider.playNext,
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        Icons.skip_next_rounded,
                        color: primary.withAlpha(200),
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
