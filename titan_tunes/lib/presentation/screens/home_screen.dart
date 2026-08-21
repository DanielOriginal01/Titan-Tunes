import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:titan_tunes/core/app_theme.dart';
import 'package:titan_tunes/data/services/recherche_service.dart';
import 'package:titan_tunes/presentation/pages/accueil/page_accueil.dart';
import 'package:titan_tunes/presentation/pages/discover_page.dart';
import 'package:titan_tunes/presentation/pages/profil/page_profil.dart';
import 'package:titan_tunes/presentation/pages/search_page.dart';
import 'package:titan_tunes/presentation/pages/tendances/page_tendances.dart';
import 'package:titan_tunes/presentation/widgets/custom_bottom_nav_bar.dart';
import 'package:titan_tunes/presentation/widgets/mini_player_widget.dart';
import 'package:titan_tunes/providers/audio_provider.dart';
import 'package:titan_tunes/providers/auth_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int  _index     = 0;
  bool _navVisible = true;

  bool _onScroll(ScrollNotification n) {
    if (n is UserScrollNotification) {
      if (n.direction == ScrollDirection.reverse && _navVisible) {
        setState(() => _navVisible = false);
      } else if (n.direction == ScrollDirection.forward && !_navVisible) {
        setState(() => _navVisible = true);
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AudioProvider>();
    final auth     = context.watch<AuthProvider>();
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final primary  = isDark ? AppColors.primaryDark : AppColors.primaryLight;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      extendBody: true,   // le corps passe sous la barre flottante
      body: provider.isLoading
          ? _LoadingBody(primary: primary)
          : NotificationListener<ScrollNotification>(
              onNotification: _onScroll,
              child: IndexedStack(index: _index, children: [
                const HomeOverviewPage(),
                SearchPage(
                  chansons: provider.chansons,
                  rechercheService: context.read<RechercheService?>(),
                ),
                DiscoverPage(provider: provider),
                TrendsPage(chansons: provider.chansons),
                ProfilePage(provider: provider),
              ]),
            ),

      // ── Barre nav glassmorphique flottante (5 onglets) ────────────────────
      bottomNavigationBar: AnimatedSlide(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeInOut,
        offset: _navVisible ? Offset.zero : const Offset(0, 1.4),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _navVisible ? 1.0 : 0.0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Mini-player glass au-dessus de la nav
              if (provider.currentChanson != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                      child: const MiniPlayerWidget(),
                    ),
                  ),
                ),
              CustomBottomNavBar(
                currentIndex: _index,
                onTap: (i) async {
                  if (i == 4 && !auth.isLoggedIn) {
                    await Navigator.of(context).pushNamed('/login');
                    if (!mounted) return;
                    if (auth.isLoggedIn) setState(() => _index = 4);
                    return;
                  }
                  setState(() => _index = i);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Écran de chargement ───────────────────────────────────────────────────────
class _LoadingBody extends StatefulWidget {
  final Color primary;
  const _LoadingBody({required this.primary});
  @override
  State<_LoadingBody> createState() => _LoadingBodyState();
}

class _LoadingBodyState extends State<_LoadingBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.90, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final logo = isDark
        ? 'assets/logos/titan_bleu_tunes.png'
        : 'assets/logos/titan_orange_tunes.png';

    return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      ScaleTransition(scale: _pulse,
        child: Image.asset(logo, width: 88,
          errorBuilder: (_, e, s) => Icon(Icons.music_note_rounded,
              size: 60, color: widget.primary))),
      const SizedBox(height: 24),
      SizedBox(width: 44, height: 3,
        child: LinearProgressIndicator(
          borderRadius: BorderRadius.circular(99),
          color: widget.primary,
          backgroundColor: widget.primary.withAlpha(25))),
    ]));
  }
}
