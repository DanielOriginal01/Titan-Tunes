import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:titan_tunes/providers/auth_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// GlassPageHeader — en-tête avec tag, titre, sous-titre et avatar glass
// ─────────────────────────────────────────────────────────────────────────────
class GlassPageHeader extends StatelessWidget {
  final String       title;
  final String       subtitle;
  final String?      tag;
  final VoidCallback? onAvatarTap;

  const GlassPageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.tag,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    final auth    = context.watch<AuthProvider>();
    final theme   = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (tag != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: primary.withAlpha(20),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(tag!,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: primary,
                  letterSpacing: 0.5,
                )),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            auth.isLoggedIn
                ? 'Bonjour, ${auth.userName ?? 'ami'}'
                : title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800, letterSpacing: -0.5),
          ),
          const SizedBox(height: 3),
          Text(subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor)),
        ]),
      ),
      const SizedBox(width: 12),
      GestureDetector(
        onTap: onAvatarTap ?? () {
          if (!auth.isLoggedIn) {
            Navigator.of(context).pushNamed('/login');
          } else {
            Navigator.of(context).pushNamed('/profile');
          }
        },
        child: GlassAvatar(auth: auth, primary: primary),
      ),
    ]);
  }
}

/// Avatar glass réutilisable (utilisé dans GlassPageHeader et autres).
class GlassAvatar extends StatelessWidget {
  final AuthProvider auth;
  final Color        primary;
  const GlassAvatar({super.key, required this.auth, required this.primary});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final ImageProvider? img = auth.isLoggedIn
        ? (auth.avatarBytes != null
            ? MemoryImage(auth.avatarBytes!)
            : auth.avatarUrl != null
                ? (auth.avatarUrl!.startsWith('http')
                    ? NetworkImage(auth.avatarUrl!)
                    : AssetImage(auth.avatarUrl!) as ImageProvider)
                : null)
        : null;

    return ClipRRect(
      borderRadius: BorderRadius.circular(36),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: primary.withAlpha(isDark ? 35 : 25),
            borderRadius: BorderRadius.circular(36),
            border: Border.all(
              color: isDark
                  ? Colors.white.withAlpha(30)
                  : primary.withAlpha(100),
              width: 1.5),
          ),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: primary.withAlpha(25),
            backgroundImage: img,
            onBackgroundImageError: img != null ? (e, s) {} : null,
            child: img == null
                ? Icon(Icons.person_rounded, color: primary, size: 20)
                : null,
          ),
        ),
      ),
    );
  }
}
