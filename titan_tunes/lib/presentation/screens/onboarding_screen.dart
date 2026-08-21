import 'package:flutter/material.dart';
import 'package:titan_tunes/core/app_theme.dart';
import 'package:titan_tunes/presentation/screens/mode_picker_screen.dart';

/// Onboarding — photo plein écran + logo + texte + bouton "Commencez"
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final logo    = isDark
        ? 'assets/logos/titan_bleu_tunes.png'
        : 'assets/logos/titan_orange_tunes.png';

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(fit: StackFit.expand, children: [

        // ── Photo plein écran ─────────────────────────────────────────────
        Image.asset(
            'assets/logos/onboarding.jpeg', 
            fit: BoxFit.cover,
            errorBuilder: (_, e, s) => Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [primary.withAlpha(180), Colors.black],
                ),
              ),
            ),
          ),

        // ── Dégradé sombre en bas ─────────────────────────────────────────
        Positioned(
          bottom: 0, left: 0, right: 0, height: 380,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black],
                stops: [0.0, 0.7],
              ),
            ),
          ),
        ),

        // ── Contenu ───────────────────────────────────────────────────────
        SafeArea(
          child: Column(children: [
            // Logo en haut
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Image.asset(logo, height: 36, fit: BoxFit.contain,
                errorBuilder: (_, e, s) => Text('Titan Tunes',
                  style: TextStyle(color: primary, fontWeight: FontWeight.w900, fontSize: 20)),
              ),
            ),

            const Spacer(),

            // Texte + bouton en bas
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Enjoy Listening\nTo Music',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Titan Tunes est votre plateforme de streaming musical africaine, '
                    'avec les meilleurs artistes du continent.',
                    style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ModePickerScreen()),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text('Commencez',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}
