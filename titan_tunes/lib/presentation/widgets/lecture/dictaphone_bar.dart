import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:titan_tunes/core/app_theme.dart';
import 'package:titan_tunes/presentation/widgets/glassmorphism_widgets.dart';
import 'package:titan_tunes/providers/audio_provider.dart';

// ── Barre dictaphone : forme d'onde + slider + timestamps ────────────────────
class DictaphoneBar extends StatelessWidget {
  final AudioProvider provider;
  final Color primary;
  final Color secondary;
  final bool isDark;
  final AnimationController waveCtrl;

  const DictaphoneBar({
    super.key,
    required this.provider,
    required this.primary,
    required this.secondary,
    required this.isDark,
    required this.waveCtrl,
  });

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final muted = isDark ? Colors.white38 : AppColors.mutedLight;
    final position = provider.position;
    final total = provider.duration;
    final fraction = provider.progressFraction;

    return GlassPanel(
      accentColor: primary,
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          // Forme d'onde animée
          SizedBox(
            height: 44,
            child: AnimatedBuilder(
              animation: waveCtrl,
              builder: (_, _) => CustomPaint(
                painter: WavePainter(
                  progress: fraction,
                  phase: waveCtrl.value,
                  isPlaying: provider.isPlaying,
                  color: primary,
                  inactiveColor: primary.withAlpha(30),
                ),
                size: const Size(double.infinity, 44),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Slider épais arrondi
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 8,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 22),
              activeTrackColor: primary,
              inactiveTrackColor: primary.withAlpha(25),
              thumbColor: Colors.white,
              overlayColor: primary.withAlpha(30),
              trackShape: const RoundedRectSliderTrackShape(),
            ),
            child: Slider(
              value: fraction,
              onChanged: (v) {
                if (total > Duration.zero) {
                  provider.seekTo(
                    Duration(milliseconds: (v * total.inMilliseconds).round()),
                  );
                }
              },
            ),
          ),

          // Timestamps
          Row(
            children: [
              Text(
                _fmt(position),
                style: TextStyle(
                  fontSize: 11,
                  color: muted,
                  fontWeight: FontWeight.w600,
                  fontFeatures: [const FontFeature.tabularFigures()],
                ),
              ),
              const Spacer(),
              if (provider.isBuffering)
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: primary,
                  ),
                ),
              const Spacer(),
              Text(
                _fmt(total),
                style: TextStyle(
                  fontSize: 11,
                  color: muted,
                  fontWeight: FontWeight.w600,
                  fontFeatures: [const FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Custom painter forme d'onde ───────────────────────────────────────────────
class WavePainter extends CustomPainter {
  final double progress;
  final double phase;
  final bool isPlaying;
  final Color color;
  final Color inactiveColor;
  static const int _barCount = 32;

  const WavePainter({
    required this.progress,
    required this.phase,
    required this.isPlaying,
    required this.color,
    required this.inactiveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final barW = size.width / (_barCount * 1.6);
    final gap = barW * 0.6;
    final total = barW + gap;
    final cy = size.height / 2;
    final played = (progress * _barCount).round();
    final rng = math.Random(42);

    for (int i = 0; i < _barCount; i++) {
      final seed = rng.nextDouble();
      double h = (seed * 0.7 + 0.15) * size.height;
      if (isPlaying) {
        final wave = math.sin(phase * 2 * math.pi + i * 0.45) * 0.3 + 0.7;
        h *= i < played ? wave : 1.0;
      }
      final x = i * total;
      final isActive = i < played;
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isActive
              ? [color, color.withAlpha(180)]
              : [inactiveColor, inactiveColor],
        ).createShader(Rect.fromLTWH(x, cy - h / 2, barW, h));

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, cy - h / 2, barW, h),
          const Radius.circular(4),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(WavePainter o) =>
      o.progress != progress || o.phase != phase || o.isPlaying != isPlaying;
}
