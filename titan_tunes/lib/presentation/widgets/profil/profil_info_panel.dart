import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:titan_tunes/presentation/widgets/glassmorphism_widgets.dart';
import 'package:titan_tunes/providers/auth_provider.dart';

// ── Panneau informations du diagramme ────────────────────────────────────────
class ProfilInfoPanel extends StatelessWidget {
  const ProfilInfoPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final auth         = context.watch<AuthProvider>();
    final primaryColor = Theme.of(context).colorScheme.primary;

    return GlassPanel(
      accentColor: primaryColor,
      child: Column(children: [
        _InfoTile(icon: Icons.badge_outlined,    title: 'Prénom et nom',
            subtitle: _joinNonEmpty([auth.firstName, auth.lastName]),
            primaryColor: primaryColor),
        Divider(height: 1, color: primaryColor.withAlpha(30)),
        _InfoTile(icon: Icons.email_outlined,    title: 'Email',
            subtitle: auth.email   ?? 'Non renseigné', primaryColor: primaryColor),
        Divider(height: 1, color: primaryColor.withAlpha(30)),
        _InfoTile(icon: Icons.wc_outlined,       title: 'Genre',
            subtitle: auth.gender  ?? 'Non renseigné', primaryColor: primaryColor),
        Divider(height: 1, color: primaryColor.withAlpha(30)),
        _InfoTile(icon: Icons.cake_outlined,     title: 'Date de naissance',
            subtitle: auth.birthDate == null
                ? 'Non renseignée' : _formatDate(auth.birthDate!),
            primaryColor: primaryColor),
        Divider(height: 1, color: primaryColor.withAlpha(30)),
        _InfoTile(icon: Icons.schedule_outlined, title: 'Création du compte',
            subtitle: auth.createdAt == null
                ? 'Non renseignée' : _formatDate(auth.createdAt!),
            primaryColor: primaryColor),
        Divider(height: 1, color: primaryColor.withAlpha(30)),
        _InfoTile(icon: Icons.update_outlined,   title: 'Dernière mise à jour',
            subtitle: auth.updatedAt == null
                ? 'Non renseignée' : _formatDate(auth.updatedAt!),
            primaryColor: primaryColor),
      ]),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String   title;
  final String   subtitle;
  final Color    primaryColor;
  const _InfoTile({
    required this.icon, required this.title,
    required this.subtitle, required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: CircleAvatar(
      backgroundColor: primaryColor.withAlpha(25),
      child: Icon(icon, color: primaryColor, size: 20),
    ),
    title: Text(title),
    subtitle: Text(subtitle),
  );
}

// ── Helpers ────────────────────────────────────────────────────────────────────
String _joinNonEmpty(List<String?> values) {
  final parts = values.whereType<String>().where((v) => v.trim().isNotEmpty).toList();
  return parts.isEmpty ? 'Non renseigné' : parts.join(' ');
}

String _formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/'
    '${date.month.toString().padLeft(2, '0')}/'
    '${date.year}';
