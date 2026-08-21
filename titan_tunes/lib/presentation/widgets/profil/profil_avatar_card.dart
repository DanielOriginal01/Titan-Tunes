import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:titan_tunes/providers/audio_provider.dart';
import 'package:titan_tunes/providers/auth_provider.dart';

// ── Carte avatar + infos compte + stats ──────────────────────────────────────
class ProfilAvatarCard extends StatelessWidget {
  final AudioProvider provider;
  const ProfilAvatarCard({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final theme        = Theme.of(context);
    final auth         = context.watch<AuthProvider>();
    final primaryColor = theme.colorScheme.primary;

    return Column(children: [
      Row(children: [
        // ── Avatar avec bouton caméra ─────────────────────────────────
        Stack(children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: primaryColor, width: 2.5),
            ),
            child: CircleAvatar(
              radius: 30,
              backgroundColor: primaryColor.withAlpha(30),
              backgroundImage: auth.avatarBytes != null
                  ? MemoryImage(auth.avatarBytes!) as ImageProvider
                  : auth.avatarUrl != null
                      ? (auth.avatarUrl!.startsWith('http')
                          ? NetworkImage(auth.avatarUrl!) as ImageProvider
                          : AssetImage(auth.avatarUrl ?? AuthProvider.defaultAvatarAsset)
                              as ImageProvider)
                      : null,
              onBackgroundImageError: (auth.avatarBytes != null || auth.avatarUrl != null)
                  ? (_, __) {}
                  : null,
              child: (auth.avatarBytes == null && auth.avatarUrl == null)
                  ? Icon(Icons.person_rounded, color: primaryColor, size: 26)
                  : null,
            ),
          ),
          Positioned(
            right: -2, bottom: -2,
            child: Material(
              color: primaryColor,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => _pickProfilePhoto(context),
                child: const Padding(
                  padding: EdgeInsets.all(7),
                  child: Icon(Icons.photo_camera_outlined, size: 15, color: Colors.white),
                ),
              ),
            ),
          ),
        ]),
        const SizedBox(width: 14),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(auth.displayName,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(
              auth.phoneNumber ?? auth.email ?? 'Informations manquantes',
              style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withAlpha(190)),
            ),
            const SizedBox(height: 8),
            // Boutons photo
            Wrap(spacing: 8, runSpacing: 6, children: [
              TextButton.icon(
                onPressed: () => _pickProfilePhoto(context),
                icon: const Icon(Icons.upload_file_outlined),
                label: const Text('Photo'),
                style: TextButton.styleFrom(foregroundColor: primaryColor),
              ),
              TextButton.icon(
                onPressed: auth.avatarBytes == null && auth.avatarUrl == null
                    ? null
                    : () => context.read<AuthProvider>().clearAvatar(),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Retirer'),
                style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
              ),
            ]),
            // Chips plan + méthode
            Wrap(spacing: 8, runSpacing: 6, children: [
              ProfilChip(label: auth.subscriptionLabel, color: primaryColor),
              ProfilChip(
                label: _authMethodLabel(auth.authMethod),
                color: primaryColor.withAlpha(180),
              ),
            ]),
          ],
        )),
      ]),
      const SizedBox(height: 16),
      // Stats rapides
      Row(children: [
        Expanded(child: ProfilStatCard(title: 'État',
            value: auth.isSubscribed ? 'Premium' : 'Free', color: primaryColor)),
        const SizedBox(width: 10),
        Expanded(child: ProfilStatCard(title: 'Audio',
            value: provider.isLowDataMode ? 'Low-Data' : 'Standard', color: primaryColor)),
        const SizedBox(width: 10),
        Expanded(child: ProfilStatCard(title: 'Données',
            value: auth.isPhoneVerified ? 'Vérifié' : 'Actif', color: primaryColor)),
      ]),
    ]);
  }
}

// ── Chip badge ────────────────────────────────────────────────────────────────
class ProfilChip extends StatelessWidget {
  final String label;
  final Color  color;
  const ProfilChip({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withAlpha(70)),
      ),
      child: Text(label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

// ── Mini stat card ─────────────────────────────────────────────────────────────
class ProfilStatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color  color;
  const ProfilStatCard({super.key,
      required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withAlpha(55)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(color: theme.hintColor, fontSize: 11)),
        const SizedBox(height: 6),
        Text(value,
          style: TextStyle(fontWeight: FontWeight.w800, color: color, fontSize: 13)),
      ]),
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────────
Future<void> _pickProfilePhoto(BuildContext context) async {
  final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
  if (result == null || result.files.isEmpty) return;
  final bytes = result.files.single.bytes;
  if (bytes == null || !context.mounted) return;
  context.read<AuthProvider>().setAvatarBytes(bytes);
}

String _authMethodLabel(AuthMethod? method) {
  switch (method) {
    case AuthMethod.phone:    return 'Connexion téléphone';
    case AuthMethod.google:   return 'Google';
    case AuthMethod.facebook: return 'Facebook';
    default:                  return 'Mode démonstration';
  }
}
