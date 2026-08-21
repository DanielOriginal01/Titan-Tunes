class ArtisteDashboardStats {
  final int totalEcoutes;
  final int auditeursUniques;
  final int totalChansons;
  final int totalAlbums;
  final int totalFavoris;
  final double royaltiesEstimees;
  final String partCatalogue;

  const ArtisteDashboardStats({
    required this.totalEcoutes,
    required this.auditeursUniques,
    required this.totalChansons,
    required this.totalAlbums,
    required this.totalFavoris,
    required this.royaltiesEstimees,
    required this.partCatalogue,
  });

  factory ArtisteDashboardStats.fromJson(Map<String, dynamic> json) {
    return ArtisteDashboardStats(
      totalEcoutes: json['totalEcoutes'] as int? ?? 0,
      auditeursUniques: json['auditeursUniques'] as int? ?? 0,
      totalChansons: json['totalChansons'] as int? ?? 0,
      totalAlbums: json['totalAlbums'] as int? ?? 0,
      totalFavoris: json['totalFavoris'] as int? ?? 0,
      royaltiesEstimees: (json['royaltiesEstimees'] as num?)?.toDouble() ?? 0.0,
      partCatalogue: json['partCatalogue'] as String? ?? '0,00%',
    );
  }

  String get formattedRoyalties {
    final formatted = royaltiesEstimees.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
    return '$formatted FCFA';
  }
}
