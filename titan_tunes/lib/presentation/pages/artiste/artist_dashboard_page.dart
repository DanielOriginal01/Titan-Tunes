import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:titan_tunes/core/app_theme.dart';
import 'package:titan_tunes/presentation/pages/artiste/create_album_modal.dart';
import 'package:titan_tunes/presentation/pages/artiste/publish_song_modal.dart';
import 'package:titan_tunes/presentation/widgets/glassmorphism_widgets.dart';
import 'package:titan_tunes/providers/artiste_provider.dart';
import 'package:titan_tunes/providers/auth_provider.dart';

class ArtistDashboardPage extends StatefulWidget {
  const ArtistDashboardPage({super.key});

  @override
  State<ArtistDashboardPage> createState() => _ArtistDashboardPageState();
}

class _ArtistDashboardPageState extends State<ArtistDashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final auth = context.read<AuthProvider>();
    final artistId = auth.userId ?? '2';
    final artisteProv = context.read<ArtisteProvider>();
    artisteProv.loadDashboard(artistId);
    artisteProv.loadReversements(artistId);
    artisteProv.loadCategories();
    artisteProv.loadAlbums(artistId);
  }

  void _openPublishModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PublishSongModal(),
    ).then((published) {
      if (published == true) {
        _loadData();
      }
    });
  }

  void _openCreateAlbumModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CreateAlbumModal(),
    ).then((created) {
      if (created == true) {
        _loadData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final artisteProv = context.watch<ArtisteProvider>();
    final stats = artisteProv.stats;
    final albums = artisteProv.albums;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      body: PageBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async => _loadData(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
              physics: const BouncingScrollPhysics(),
              children: [
                // ── En-tête ──────────────────────────────────────────────────
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tableau de Bord Artiste',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            auth.displayName,
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Bouton créer album
                    IconButton.filledTonal(
                      onPressed: _openCreateAlbumModal,
                      icon: const Icon(Icons.album_rounded),
                      tooltip: 'Créer un Album',
                    ),
                    const SizedBox(width: 6),
                    // Bouton publier
                    IconButton.filled(
                      onPressed: _openPublishModal,
                      icon: const Icon(Icons.add_rounded),
                      tooltip: 'Publier un morceau',
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Bannière Royalties & Impact ──────────────────────────────
                GlassPanel(
                  accentColor: primaryColor,
                  borderRadius: BorderRadius.circular(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withAlpha(30),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.monetization_on_rounded,
                                    color: Colors.amber, size: 22),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Royalties Estimées',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: primaryColor.withAlpha(25),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: primaryColor.withAlpha(80)),
                            ),
                            child: Text(
                              'Impact: ${stats?.partCatalogue ?? "0,00%"}',
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        stats?.formattedRoyalties ?? '0 FCFA',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: primaryColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Revenus générés par vos flux d\'écoutes sur Titan Tunes',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Grille des KPIs ──────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _KpiTile(
                        icon: Icons.play_arrow_rounded,
                        label: 'Total Écoutes',
                        value: stats != null
                            ? _formatNumber(stats.totalEcoutes)
                            : '0',
                        color: Colors.blueAccent,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _KpiTile(
                        icon: Icons.people_rounded,
                        label: 'Auditeurs',
                        value: stats != null
                            ? _formatNumber(stats.auditeursUniques)
                            : '0',
                        color: Colors.tealAccent,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _KpiTile(
                        icon: Icons.music_note_rounded,
                        label: 'Titres Sortis',
                        value: '${stats?.totalChansons ?? 0}',
                        color: Colors.purpleAccent,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _KpiTile(
                        icon: Icons.album_rounded,
                        label: 'Albums Sortis',
                        value: '${stats?.totalAlbums ?? albums.length}',
                        color: Colors.amberAccent,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Boutons d'actions rapides (Publication & Album) ───────────
                Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _openPublishModal,
                          icon: const Icon(Icons.upload_file_rounded, size: 18),
                          label: const Text(
                            'Publier un Titre',
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 5,
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: _openCreateAlbumModal,
                          icon: const Icon(Icons.album_rounded, size: 18),
                          label: const Text(
                            'Créer Album',
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryColor,
                            side: BorderSide(color: primaryColor, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Section Mes Albums ───────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Mes Albums (${albums.length})',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _openCreateAlbumModal,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Nouveau'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (artisteProv.isLoadingAlbums)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (albums.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : AppColors.cardLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.album_outlined,
                              size: 36, color: theme.hintColor),
                          const SizedBox(height: 6),
                          Text(
                            'Aucun album créé pour le moment.',
                            style: TextStyle(color: theme.hintColor),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: _openCreateAlbumModal,
                            child: const Text('Créer votre premier album'),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: 140,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: albums.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final al = albums[index];
                        return Container(
                          width: 220,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.cardDark
                                : AppColors.cardLight,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: AppColors.divider.withAlpha(80)),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: al.coverUrl.isNotEmpty
                                    ? Image.network(
                                        al.coverUrl,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          width: 60,
                                          height: 60,
                                          color: primaryColor.withAlpha(30),
                                          child: Icon(Icons.album_rounded,
                                              color: primaryColor),
                                        ),
                                      )
                                    : Container(
                                        width: 60,
                                        height: 60,
                                        color: primaryColor.withAlpha(30),
                                        child: Icon(Icons.album_rounded,
                                            color: primaryColor),
                                      ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      al.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${al.releaseDate.year}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: theme.hintColor,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${al.chansonIds.length} pistes',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 24),

                // ── Historique des reversements ─────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Historique des Reversements',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    TextButton(
                      onPressed: () => _loadData(),
                      child: const Text('Actualiser'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (artisteProv.isLoadingReversements)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (artisteProv.reversements.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : AppColors.cardLight,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.receipt_long_outlined,
                              size: 40, color: theme.hintColor),
                          const SizedBox(height: 8),
                          Text(
                            'Aucun reversement pour le moment.',
                            style: TextStyle(color: theme.hintColor),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Les reversements sont générés périodiquement.',
                            style: TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...artisteProv.reversements.map((rev) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.cardDark
                              : AppColors.cardLight,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.divider.withAlpha(80),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: _statusColor(rev.statut).withAlpha(25),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _statusIcon(rev.statut),
                                color: _statusColor(rev.statut),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    rev.formattedMontant,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    '${rev.modePaiement} · ${rev.reference ?? "Virement"}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.hintColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _statusColor(rev.statut).withAlpha(25),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                rev.statut,
                                style: TextStyle(
                                  color: _statusColor(rev.statut),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'SUCCES':
      case 'VALIDE':
        return Colors.green;
      case 'EN_ATTENTE':
        return Colors.amber;
      case 'REJETE':
      case 'ECHEC':
        return Colors.redAccent;
      default:
        return Colors.blueAccent;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'SUCCES':
      case 'VALIDE':
        return Icons.check_circle_rounded;
      case 'EN_ATTENTE':
        return Icons.hourglass_top_rounded;
      case 'REJETE':
      case 'ECHEC':
        return Icons.cancel_rounded;
      default:
        return Icons.payment_rounded;
    }
  }

  String _formatNumber(int val) {
    if (val >= 1000000) {
      return '${(val / 1000000).toStringAsFixed(1)}M';
    }
    if (val >= 1000) {
      return '${(val / 1000).toStringAsFixed(1)}k';
    }
    return '$val';
  }
}

class _KpiTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _KpiTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider.withAlpha(80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).hintColor,
            ),
          ),
        ],
      ),
    );
  }
}
