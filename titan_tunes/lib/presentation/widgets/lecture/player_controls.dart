import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:titan_tunes/providers/audio_provider.dart';

// ── Contrôles lecture ─────────────────────────────────────────────────────────
class PlayerControls extends StatelessWidget {
  final AudioProvider provider;
  final Color primary;
  final Color secondary;
  final Color fg;
  final Color muted;
  final bool  isDark;

  const PlayerControls({
    super.key,
    required this.provider,
    required this.primary,
    required this.secondary,
    required this.fg,
    required this.muted,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final loopColor = provider.loopMode != LoopMode.off ? primary : muted;
    final loopIcon  = provider.loopMode == LoopMode.one
        ? Icons.repeat_one_rounded : Icons.repeat_rounded;

    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      _Btn(icon: Icons.shuffle_rounded,
          color: provider.shuffleEnabled ? primary : muted,
          onTap: provider.toggleShuffle),
      _Btn(icon: Icons.skip_previous_rounded, color: fg, size: 28,
          onTap: provider.playPrevious),
      // Play / Pause
      GestureDetector(
        onTap: provider.togglePlayPause,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 62, height: 62,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [primary, secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
            boxShadow: [BoxShadow(
                color: primary.withAlpha(100), blurRadius: 22,
                offset: const Offset(0, 8))],
          ),
          child: Icon(
            provider.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            color: Colors.white, size: 32),
        ),
      ),
      _Btn(icon: Icons.skip_next_rounded, color: fg, size: 28,
          onTap: provider.playNext),
      _Btn(icon: loopIcon, color: loopColor, onTap: provider.cycleLoopMode),
    ]);
  }
}

class _Btn extends StatelessWidget {
  final IconData     icon;
  final Color        color;
  final double       size;
  final VoidCallback onTap;
  const _Btn({required this.icon, required this.color,
      required this.onTap, this.size = 22});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Padding(padding: const EdgeInsets.all(10),
        child: Icon(icon, color: color, size: size)));
}
