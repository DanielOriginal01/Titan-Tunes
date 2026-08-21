import 'package:flutter/material.dart';
import 'package:titan_tunes/data/models/artiste.dart';
import 'package:titan_tunes/data/models/chanson.dart';
import 'package:titan_tunes/presentation/widgets/app_network_image.dart';
import 'package:titan_tunes/presentation/widgets/glassmorphism_widgets.dart';

// ── En-tête de section ────────────────────────────────────────────────────────
class SearchSectionHeader extends StatelessWidget {
  final String label;
  final Color primary;
  final Widget? trailing;

  const SearchSectionHeader({
    super.key,
    required this.label,
    required this.primary,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 4, height: 18,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: primary, borderRadius: BorderRadius.circular(4)),
      ),
      Expanded(
        child: Text(label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700)),
      ),
      ?trailing,
    ]);
  }
}

// ── Tile historique ───────────────────────────────────────────────────────────
class SearchHistoryTile extends StatelessWidget {
  final String query;
  final Color primary;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const SearchHistoryTile({
    super.key,
    required this.query,
    required this.primary,
    required this.isDark,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      dense: true,
      visualDensity: VisualDensity.compact,
      leading: Icon(Icons.history_rounded,
          color: isDark ? Colors.white38 : Colors.black38, size: 20),
      title: Text(query,
          style: TextStyle(fontSize: 14,
              color: isDark ? Colors.white : Colors.black)),
      trailing: IconButton(
        icon: Icon(Icons.close_rounded,
            size: 18, color: isDark ? Colors.white38 : Colors.black38),
        visualDensity: VisualDensity.compact,
        onPressed: onDelete,
      ),
      onTap: onTap,
    );
  }
}

// ── Chip artiste (liste horizontale) ─────────────────────────────────────────
class SearchArtistChip extends StatelessWidget {
  final Artiste artiste;
  final Color primary;
  final VoidCallback onTap;

  const SearchArtistChip({
    super.key,
    required this.artiste,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 80,
        child: Column(children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: primary.withAlpha(25),
            backgroundImage: artiste.pictureUrl.isNotEmpty
                ? NetworkImage(artiste.pictureUrl)
                : null,
            onBackgroundImageError: artiste.pictureUrl.isNotEmpty ? (e, s) {} : null,
            child: artiste.pictureUrl.isEmpty
                ? Icon(Icons.person_rounded, color: primary, size: 28)
                : null,
          ),
          const SizedBox(height: 6),
          Text(artiste.name,
            maxLines: 1, overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          if (artiste.genres.isNotEmpty)
            Text(artiste.genres.first,
              maxLines: 1, overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, color: primary.withAlpha(180))),
        ]),
      ),
    );
  }
}

// ── Tile chanson résultat ─────────────────────────────────────────────────────
class SearchSongTile extends StatelessWidget {
  final Chanson chanson;
  final Color primary;
  final bool isDark;
  final List<Artiste> artistes;
  final VoidCallback onPlay;
  final VoidCallback onArtistTap;

  const SearchSongTile({
    super.key,
    required this.chanson,
    required this.primary,
    required this.isDark,
    required this.artistes,
    required this.onPlay,
    required this.onArtistTap,
  });

  @override
  Widget build(BuildContext context) {
    final artiste = artistes.firstWhere(
      (a) => a.id == chanson.artisteId,
      orElse: () => Artiste(
          id: '', name: chanson.artistName, label: '',
          country: '', followers: 0, pictureUrl: '', genres: []),
    );
    final hasLabel = artiste.label.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassPanel(
        accentColor: primary,
        borderRadius: BorderRadius.circular(20),
        padding: const EdgeInsets.fromLTRB(10, 8, 6, 8),
        child: Row(children: [
          // Pochette
          GestureDetector(
            onTap: onPlay,
            child: AppNetworkImage(
              url: chanson.coverUrl,
              width: 52,
              height: 52,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 12),
          // Infos
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(chanson.title,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 3),
              GestureDetector(
                onTap: onArtistTap,
                child: Text(chanson.artistName,
                  style: TextStyle(
                    fontSize: 12, color: primary, fontWeight: FontWeight.w600,
                    decoration: artiste.id.isNotEmpty ? TextDecoration.underline : null,
                    decorationColor: primary,
                  ),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(height: 3),
              Wrap(spacing: 4, runSpacing: 2, children: [
                ...chanson.genres.take(2).map(
                  (g) => _MiniChip(label: g, color: primary)),
                if (hasLabel)
                  _MiniChip(
                    label: artiste.label,
                    color: isDark
                        ? Colors.white38.withAlpha(160)
                        : Colors.black38.withAlpha(160),
                    icon: Icons.business_outlined,
                  ),
              ]),
            ],
          )),
          // Play
          Container(
            margin: const EdgeInsets.only(left: 4),
            decoration: BoxDecoration(
                color: primary.withAlpha(22), shape: BoxShape.circle),
            child: IconButton(
              icon: Icon(Icons.play_arrow_rounded, color: primary),
              onPressed: onPlay,
              tooltip: 'Écouter',
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Petit badge chip ──────────────────────────────────────────────────────────
class _MiniChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  const _MiniChip({required this.label, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(22),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withAlpha(55)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[
          Icon(icon, size: 9, color: color),
          const SizedBox(width: 3),
        ],
        Text(label,
          style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
