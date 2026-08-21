import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:titan_tunes/core/app_theme.dart';
import 'package:titan_tunes/presentation/screens/home_screen.dart';
import 'package:titan_tunes/providers/auth_provider.dart';

/// Mode Picker — photo plein écran, choix Dark/Light, bouton "Continuez"
class ModePickerScreen extends StatefulWidget {
  const ModePickerScreen({super.key});
  @override
  State<ModePickerScreen> createState() => _ModePickerScreenState();
}

class _ModePickerScreenState extends State<ModePickerScreen> {
  ThemeMode _selected = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _selected = context.read<AuthProvider>().themeMode;
  }

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

        // Photo plein écran
       Image.asset(
        'assets/logos/theme .jpeg', // Remplacez par le chemin vers votre image
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
        // Dégradé
        Positioned(
          bottom: 0, left: 0, right: 0, height: 420,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black],
                stops: [0.0, 0.65],
              ),
            ),
          ),
        ),

        SafeArea(child: Column(children: [
          // Logo
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Row(children: [
              Image.asset(logo, height: 34, fit: BoxFit.contain,
                errorBuilder: (_, e, s) => Text('Titan Tunes',
                  style: TextStyle(color: primary, fontWeight: FontWeight.w900, fontSize: 18)),
              ),
            ]),
          ),
          const Spacer(),

          Padding(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 40),
            child: Column(children: [
              const Text('Choose Mode',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
              const SizedBox(height: 24),

              // Cartes Dark / Light
              Row(children: [
                Expanded(child: _ModeCard(
                  icon: Icons.dark_mode_rounded,
                  label: 'Dark Mode',
                  selected: _selected == ThemeMode.dark,
                  onTap: () => setState(() => _selected = ThemeMode.dark),
                )),
                const SizedBox(width: 16),
                Expanded(child: _ModeCard(
                  icon: Icons.light_mode_rounded,
                  label: 'Light Mode',
                  selected: _selected == ThemeMode.light,
                  onTap: () => setState(() => _selected = ThemeMode.light),
                )),
              ]),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<AuthProvider>().setThemeMode(_selected);
                    Navigator.of(context).pushAndRemoveUntil(
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => const HomeScreen(),
                        transitionsBuilder: (_, anim, a, child) =>
                            FadeTransition(opacity: anim, child: child),
                        transitionDuration: const Duration(milliseconds: 400),
                      ),
                      (r) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('Continuez',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                ),
              ),
            ]),
          ),
        ])),
      ]),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final IconData icon;
  final String   label;
  final bool     selected;
  final VoidCallback onTap;
  const _ModeCard({required this.icon, required this.label,
      required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: selected ? primary.withAlpha(220) : Colors.white.withAlpha(20),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? primary : Colors.white38,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
        ]),
      ),
    );
  }
}
