import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:titan_tunes/presentation/pages/bibliotheque/page_bibliotheque.dart';
import 'package:titan_tunes/presentation/widgets/glassmorphism_widgets.dart';
import 'package:titan_tunes/presentation/widgets/profil/profil_avatar_card.dart';
import 'package:titan_tunes/presentation/widgets/profil/profil_completion_card.dart';
import 'package:titan_tunes/presentation/widgets/profil/profil_info_panel.dart';
import 'package:titan_tunes/presentation/widgets/profil/profil_settings_panel.dart';
import 'package:titan_tunes/presentation/widgets/test_accounts_bottom_sheet.dart';
import 'package:titan_tunes/providers/audio_provider.dart';
import 'package:titan_tunes/providers/auth_provider.dart';

class ProfilePage extends StatelessWidget {
  final AudioProvider provider;
  const ProfilePage({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    return PageBackground(
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        children: [
          // ── Header ────────────────────────────────────────────────────
          GlassPageHeader(
            title: 'Profil',
            subtitle: auth.isLoggedIn
                ? 'Votre compte, vos réglages et votre abonnement.'
                : 'Connectez-vous pour retrouver votre compte.',
            tag: auth.isLoggedIn ? 'Compte actif' : 'Accès requis',
          ),
          const SizedBox(height: 16),

          // ── Non connecté ───────────────────────────────────────────────
          if (!auth.isLoggedIn)
            GlassPanel(
              accentColor: primaryColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person_off_outlined, color: primaryColor),
                      const SizedBox(width: 10),
                      Text(
                        "Vous n'êtes pas connecté.",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Connectez-vous pour voir votre profil, vos téléchargements et votre abonnement.',
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () =>
                          Navigator.of(context).pushNamed('/login'),
                      child: const Text('Se connecter'),
                    ),
                  ),
                ],
              ),
            )
          else ...[
            // ── Avatar + infos + stats ─────────────────────────────────
            GlassPanel(
              accentColor: primaryColor,
              child: ProfilAvatarCard(provider: provider),
            ),
            const SizedBox(height: 16),

            // ── Bibliothèque ───────────────────────────────────────────
            GlassPanel(
              accentColor: primaryColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.library_music_outlined, color: primaryColor),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Bibliothèque et playlists',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Text(
                        '${provider.playlists.length} playlists',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Retrouvez vos playlists, modifiez-les et consultez les morceaux.',
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LibraryPage()),
                      ),
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: const Text('Ouvrir la bibliothèque'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Changer de compte test ─────────────────────────────────
            GlassPanel(
              accentColor: Colors.amber,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.amber.withAlpha(30),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.science_rounded,
                      color: Colors.amber,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Changer de compte de test',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Testez les rôles Admin, Artiste, Auditeur Abonné',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.swap_horiz_rounded,
                      color: Colors.amber,
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => const TestAccountsBottomSheet(),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Compléter le profil ────────────────────────────────────
            _SectionTitle(
              label: 'Compléter le profil',
              primaryColor: primaryColor,
            ),
            const SizedBox(height: 8),
            const ProfilCompletionCard(),
            const SizedBox(height: 16),

            // ── Informations du diagramme ──────────────────────────────
            _SectionTitle(
              label: 'Informations du diagramme',
              primaryColor: primaryColor,
            ),
            const SizedBox(height: 8),
            const ProfilInfoPanel(),
            const SizedBox(height: 16),

            // ── Apparence ──────────────────────────────────────────────
            _SectionTitle(label: 'Apparence', primaryColor: primaryColor),
            const SizedBox(height: 8),
            const ProfilAppearancePanel(),
            const SizedBox(height: 16),

            // ── Low-Data ───────────────────────────────────────────────
            ProfilLowDataPanel(provider: provider),
            const SizedBox(height: 16),

            // ── Compte & abonnement ────────────────────────────────────
            _SectionTitle(
              label: 'Compte et abonnement',
              primaryColor: primaryColor,
            ),
            const SizedBox(height: 8),
            const ProfilAccountPanel(),
            const SizedBox(height: 16),

            // ── Déconnexion ────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await auth.logout();
                  if (context.mounted) {
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil('/login', (r) => false);
                  }
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Se déconnecter'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent, width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),
          Center(
            child: Text(
              'powered by NITCH-Corp',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String label;
  final Color primaryColor;
  const _SectionTitle({required this.label, required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return Row(
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
          label,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}
