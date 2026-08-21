import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:titan_tunes/core/app_theme.dart';
import 'package:titan_tunes/presentation/widgets/glassmorphism_widgets.dart';
import 'package:titan_tunes/providers/audio_provider.dart';
import 'package:titan_tunes/providers/auth_provider.dart';

// ── Panneau Apparence (thème) ─────────────────────────────────────────────────
class ProfilAppearancePanel extends StatelessWidget {
  const ProfilAppearancePanel({super.key});

  @override
  Widget build(BuildContext context) {
    final theme        = Theme.of(context);
    final auth         = context.watch<AuthProvider>();
    final primaryColor = theme.colorScheme.primary;

    return GlassPanel(
      accentColor: primaryColor,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("Choisissez le thème de l'application.", style: theme.textTheme.bodyMedium),
        const SizedBox(height: 8),
        Row(children: [
          Icon(Icons.circle, color: AppColors.primaryLight, size: 12),
          const SizedBox(width: 4),
          const Text('Orange = Clair', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 16),
          Icon(Icons.circle, color: AppColors.primaryDark, size: 12),
          const SizedBox(width: 4),
          const Text('Bleu = Sombre', style: TextStyle(fontSize: 12)),
        ]),
        const SizedBox(height: 12),
        Wrap(spacing: 10, runSpacing: 10, children: [
          _ThemeChip(
            label: 'Système', icon: Icons.brightness_auto_outlined,
            selected: auth.themeMode == ThemeMode.system,
            primaryColor: primaryColor,
            onTap: () => context.read<AuthProvider>().setThemeMode(ThemeMode.system),
          ),
          _ThemeChip(
            label: 'Clair', icon: Icons.light_mode_outlined,
            selected: auth.themeMode == ThemeMode.light,
            primaryColor: AppColors.primaryLight,
            onTap: () => context.read<AuthProvider>().setThemeMode(ThemeMode.light),
          ),
          _ThemeChip(
            label: 'Sombre', icon: Icons.dark_mode_outlined,
            selected: auth.themeMode == ThemeMode.dark,
            primaryColor: AppColors.primaryDark,
            onTap: () => context.read<AuthProvider>().setThemeMode(ThemeMode.dark),
          ),
        ]),
      ]),
    );
  }
}

// ── Panneau Low-Data ──────────────────────────────────────────────────────────
class ProfilLowDataPanel extends StatelessWidget {
  final AudioProvider provider;
  const ProfilLowDataPanel({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return GlassPanel(
      accentColor: primaryColor,
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Mode Économie de données (Low-Data)'),
        subtitle: const Text('Réduit la qualité audio pour préserver le forfait'),
        value: provider.isLowDataMode,
        onChanged: (_) => provider.toggleLowDataMode(),
      ),
    );
  }
}

// ── Panneau Compte & abonnement ───────────────────────────────────────────────
class ProfilAccountPanel extends StatelessWidget {
  const ProfilAccountPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final theme        = Theme.of(context);
    final auth         = context.watch<AuthProvider>();
    final primaryColor = theme.colorScheme.primary;

    return GlassPanel(
      accentColor: primaryColor,
      child: Column(children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: primaryColor.withAlpha(30),
            child: Icon(Icons.person_outline, color: primaryColor),
          ),
          title: const Text('Nom du compte'),
          subtitle: Text(auth.userName ?? 'Utilisateur'),
        ),
        Divider(height: 1, color: primaryColor.withAlpha(30)),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: primaryColor.withAlpha(30),
            child: Icon(Icons.phone_android_rounded, color: primaryColor),
          ),
          title: const Text('Téléphone'),
          subtitle: Text(auth.phoneNumber ?? 'Non renseigné'),
        ),
        Divider(height: 1, color: primaryColor.withAlpha(30)),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: primaryColor.withAlpha(30),
            child: Icon(Icons.workspace_premium_outlined, color: primaryColor),
          ),
          title: const Text('Abonnement'),
          subtitle: Text(auth.subscriptionLabel),
          trailing: TextButton(
            onPressed: () => Navigator.of(context).pushNamed('/subscription'),
            style: TextButton.styleFrom(foregroundColor: primaryColor),
            child: const Text('Gérer'),
          ),
        ),
      ]),
    );
  }
}

// ── Chip thème ─────────────────────────────────────────────────────────────────
class _ThemeChip extends StatelessWidget {
  final String       label;
  final IconData     icon;
  final bool         selected;
  final Color        primaryColor;
  final VoidCallback onTap;
  const _ThemeChip({
    required this.label, required this.icon, required this.selected,
    required this.primaryColor, required this.onTap,
  });

  @override
  Widget build(BuildContext context) => ChoiceChip(
    selected: selected,
    onSelected: (_) => onTap(),
    selectedColor: primaryColor,
    backgroundColor: primaryColor.withAlpha(18),
    side: BorderSide(color: primaryColor.withAlpha(selected ? 220 : 60)),
    label: Text(label,
      style: TextStyle(color: selected ? Colors.white : null, fontWeight: FontWeight.w600)),
    avatar: Icon(icon, size: 17,
        color: selected ? Colors.white : Theme.of(context).iconTheme.color),
  );
}
