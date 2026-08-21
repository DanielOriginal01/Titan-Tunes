import 'package:titan_tunes/data/models/album.dart';
import 'package:titan_tunes/data/models/artiste.dart';
import 'package:titan_tunes/data/models/chanson.dart';
import 'package:titan_tunes/data/models/evenement.dart';
import 'package:titan_tunes/data/models/ecoute.dart';
import 'package:titan_tunes/data/models/paiement.dart';
import 'package:titan_tunes/data/models/playlist.dart';
import 'package:titan_tunes/data/models/telechargement.dart';
import 'package:titan_tunes/data/models/user.dart';

class MockAudioService {
  MockAudioService();

  final List<Artiste> _artistes = [
    Artiste(
      id: 'a1',
      name: 'Santrinos Raphael',
      label: 'Raphael Records',
      country: 'Togo',
      followers: 52800,
      pictureUrl: 'https://example.com/santrinos_raphael.jpg',
      genres: ['Afrobeat', 'Afro Pop'],
      biography:
          'Icône du rap togolais, engagé pour la jeunesse et la culture locale.',
      photoUrl: 'https://example.com/santrinos_photo.jpg',
    ),
    Artiste(
      id: 'a2',
      name: 'King Mensah',
      label: 'King Label',
      country: 'Togo',
      followers: 71500,
      pictureUrl: 'https://example.com/king_mensah.jpg',
      genres: ['Gospel', 'Afro Spirit'],
      biography:
          'Le roi du gospel togolais, reconnu dans toute l’Afrique francophone.',
      photoUrl: 'https://example.com/king_mensah_photo.jpg',
    ),
    Artiste(
      id: 'a3',
      name: 'Almok',
      label: 'Sagemusic',
      country: 'Côte d’Ivoire',
      followers: 63000,
      pictureUrl: 'https://example.com/almok.jpg',
      genres: ['Zouk', 'Afrobeat'],
      biography:
          'Chanteur ivoirien multi-genre, connu pour ses refrains dansants.',
      photoUrl: 'https://example.com/almok_photo.jpg',
    ),
  ];

  final List<Album> _albums = [
    Album(
      id: 'al1',
      title: 'Rêves de Lomé',
      artisteId: 'a1',
      releaseDate: DateTime(2024, 9, 10),
      coverUrl: 'https://example.com/cover_reves_lome.jpg',
      genres: ['Afrobeat', 'Rap'],
      chansonIds: ['c1', 'c2'],
    ),
    Album(
      id: 'al2',
      title: 'Couronne Divine',
      artisteId: 'a2',
      releaseDate: DateTime(2023, 5, 22),
      coverUrl: 'https://example.com/cover_couronne_divine.jpg',
      genres: ['Gospel', 'Afro Spirit'],
      chansonIds: ['c3', 'c4'],
    ),
    Album(
      id: 'al3',
      title: 'Chaleur d’Afrique',
      artisteId: 'a3',
      releaseDate: DateTime(2025, 2, 14),
      coverUrl: 'https://example.com/cover_chaleur_afrique.jpg',
      genres: ['Zouk', 'Afrobeat'],
      chansonIds: ['c5', 'c6'],
    ),
  ];

  final List<Chanson> _chansons = [
    Chanson(
      id: 'c1',
      title: 'Rêve du Sud',
      artisteId: 'a1',
      albumId: 'al1',
      genres: ['Afrobeat', 'Rap'],
      duration: const Duration(minutes: 3, seconds: 35),
      popularity: 93,
      isDownloaded: true,
      isFavorite: true,
      coverUrl: 'https://example.com/cover_reve_du_sud.jpg',
      lyrics: 'Je rêve d’un sud, où le rythme nous guide...',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      artistName: 'Santrinos Raphael',
      albumCoverUrl: 'https://example.com/cover_reves_lome.jpg',
    ),
    Chanson(
      id: 'c2',
      title: 'Voix de Lomé',
      artisteId: 'a1',
      albumId: 'al1',
      genres: ['Afrobeat'],
      duration: const Duration(minutes: 4, seconds: 2),
      popularity: 81,
      isDownloaded: false,
      coverUrl: 'https://example.com/cover_voix_de_lome.jpg',
      lyrics: 'Écoute la voix, écoute le vent du soir...',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
      artistName: 'Santrinos Raphael',
      albumCoverUrl: 'https://example.com/cover_reves_lome.jpg',
    ),
    Chanson(
      id: 'c3',
      title: 'Couronne Divine',
      artisteId: 'a2',
      albumId: 'al2',
      genres: ['Gospel'],
      duration: const Duration(minutes: 4, seconds: 18),
      popularity: 95,
      isDownloaded: true,
      coverUrl: 'https://example.com/cover_couronne_divine.jpg',
      lyrics: 'J’élève mes mains, dans la lumière du matin...',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
      artistName: 'King Mensah',
      albumCoverUrl: 'https://example.com/cover_couronne_divine.jpg',
    ),
    Chanson(
      id: 'c4',
      title: 'Bénédiction',
      artisteId: 'a2',
      albumId: 'al2',
      genres: ['Gospel', 'Afro Spirit'],
      duration: const Duration(minutes: 3, seconds: 50),
      popularity: 78,
      isDownloaded: false,
      coverUrl: 'https://example.com/cover_benediction.jpg',
      lyrics: 'La paix descend, bénédiction sur nos routes...',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
      artistName: 'King Mensah',
      albumCoverUrl: 'https://example.com/cover_couronne_divine.jpg',
    ),
    Chanson(
      id: 'c5',
      title: 'Tempo d’Or',
      artisteId: 'a3',
      albumId: 'al3',
      genres: ['Zouk', 'Afrobeat'],
      duration: const Duration(minutes: 3, seconds: 22),
      popularity: 88,
      isDownloaded: false,
      coverUrl: 'https://example.com/cover_tempo_dor.jpg',
      lyrics: 'Le tempo d’or nous soulève, chaque pas résonne...',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',
      artistName: 'Almok',
      albumCoverUrl: 'https://example.com/cover_chaleur_afrique.jpg',
    ),
    Chanson(
      id: 'c6',
      title: 'Low Data Remix',
      artisteId: 'a3',
      albumId: 'al3',
      genres: ['Afrobeat'],
      duration: const Duration(minutes: 2, seconds: 58),
      popularity: 76,
      isDownloaded: true,
      coverUrl: 'https://example.com/cover_low_data_remix.jpg',
      lyrics: 'La musique légère pour la route, sans perdre le groove...',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3',
      artistName: 'Almok',
      albumCoverUrl: 'https://example.com/cover_chaleur_afrique.jpg',
    ),
  ];

  final List<Playlist> _playlists = [
    Playlist(
      id: 'p1',
      title: 'Afro Sessions',
      description: 'Hits togolais et classiques afro.',
      creatorId: 'a1',
      chansonIds: ['c1', 'c2', 'c5'],
    ),
    Playlist(
      id: 'p2',
      title: 'Low Data Mix',
      description: 'Chansons légères optimisées pour les réseaux lents.',
      creatorId: 'a3',
      chansonIds: ['c6', 'c4'],
    ),
  ];

  final List<Ecoute> _ecoutes = [
    Ecoute(
      id: 'l1',
      chansonId: 'c3',
      userId: 'u1',
      startedAt: DateTime.now().subtract(const Duration(hours: 2)),
      duration: const Duration(minutes: 4, seconds: 18),
      completed: true,
    ),
    Ecoute(
      id: 'l2',
      chansonId: 'c1',
      userId: 'u1',
      startedAt: DateTime.now().subtract(const Duration(days: 1, hours: 1)),
      duration: const Duration(minutes: 3, seconds: 35),
      completed: true,
    ),
    Ecoute(
      id: 'l3',
      chansonId: 'c5',
      userId: 'u2',
      startedAt: DateTime.now().subtract(const Duration(minutes: 40)),
      duration: const Duration(minutes: 3, seconds: 22),
      completed: true,
    ),
  ];

  final List<Telechargement> _telechargements = [
    Telechargement(
      id: 'd1',
      chansonId: 'c1',
      userId: 'u1',
      startedAt: DateTime.now().subtract(const Duration(hours: 6)),
      completedAt: DateTime.now().subtract(
        const Duration(hours: 5, minutes: 30),
      ),
      progressPercent: 100,
    ),
    Telechargement(
      id: 'd2',
      chansonId: 'c4',
      userId: 'u1',
      startedAt: DateTime.now().subtract(const Duration(minutes: 10)),
      progressPercent: 55,
    ),
  ];

  final List<Evenement> _evenements = [
    Evenement(
      id: 'e1',
      name: 'Festival Titan Tunes',
      location: 'Stade de Lomé',
      date: DateTime(2025, 12, 12),
      artisteId: 'a1',
      availableTickets: 350,
      ticketPrice: 2500.0,
    ),
    Evenement(
      id: 'e2',
      name: 'Soirée AfroDrive',
      location: 'Kara Music Hall',
      date: DateTime(2025, 11, 5),
      artisteId: 'a2',
      availableTickets: 180,
      ticketPrice: 1800.0,
    ),
  ];

  final List<Paiement> _paiements = [
    Paiement(
      id: 'pay1',
      userId: 'u1',
      amount: 1500.0,
      method: PaiementMethod.flooz,
      date: DateTime.now().subtract(const Duration(days: 4)),
      success: true,
    ),
    Paiement(
      id: 'pay2',
      userId: 'u1',
      amount: 2500.0,
      method: PaiementMethod.tMoney,
      date: DateTime.now().subtract(const Duration(days: 10)),
      success: true,
    ),
  ];

  final List<User> _users = [
    User(
      id: 'u1',
      username: 'sol_togo',
      email: 'sol@titantunes.com',
      role: UserRole.auditeur,
      avatarUrl: 'https://example.com/avatar_sol_togo.png',
      lowDataMode: true,
    ),
    User(
      id: 'u2',
      username: 'aya_artist',
      email: 'aya@titantunes.com',
      role: UserRole.artiste,
      avatarUrl: 'https://example.com/avatar_aya_artist.png',
    ),
  ];

  List<Artiste> fetchArtistes() => List.unmodifiable(_artistes);
  List<Album> fetchAlbums() => List.unmodifiable(_albums);
  List<Chanson> fetchChansons() => _chansons.map((song) => song).toList();
  List<Playlist> fetchPlaylists() => List.unmodifiable(_playlists);
  List<Evenement> fetchEvenements() => List.unmodifiable(_evenements);
  List<Paiement> fetchPaiements() => List.unmodifiable(_paiements);
  List<Telechargement> fetchTelechargements() =>
      List.unmodifiable(_telechargements);
  List<Ecoute> fetchEcoutes() => List.unmodifiable(_ecoutes);
  List<User> fetchUsers() => List.unmodifiable(_users);

  Future<String> streamChanson(String chansonId) async {
    await Future.delayed(const Duration(milliseconds: 450));
    final chanson = _chansons.firstWhere(
      (song) => song.id == chansonId,
      orElse: () => _chansons.first,
    );
    return chanson.audioUrl.isNotEmpty
        ? chanson.audioUrl
        : 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';
  }

  Future<Chanson?> toggleFavorite(String chansonId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final index = _chansons.indexWhere((song) => song.id == chansonId);
    if (index < 0) {
      return null;
    }
    final current = _chansons[index];
    _chansons[index] = current.copyWith(isFavorite: !current.isFavorite);
    return _chansons[index];
  }

  Future<void> addToPlaylist(String playlistId, String chansonId) async {
    final idx = _playlists.indexWhere((p) => p.id == playlistId);
    if (idx < 0) return;
    final pl = _playlists[idx];
    if (!pl.chansonIds.contains(chansonId)) {
      final updated = pl.copyWith(chansonIds: [...pl.chansonIds, chansonId]);
      _playlists[idx] = updated;
    }
  }

  Future<void> removeFromPlaylist(String playlistId, String chansonId) async {
    final idx = _playlists.indexWhere((p) => p.id == playlistId);
    if (idx < 0) return;
    final pl = _playlists[idx];
    if (pl.chansonIds.contains(chansonId)) {
      final updated = pl.copyWith(
        chansonIds: pl.chansonIds.where((id) => id != chansonId).toList(),
      );
      _playlists[idx] = updated;
    }
  }

  void updateDownloadedState(String chansonId, bool isDownloaded) {
    final index = _chansons.indexWhere((song) => song.id == chansonId);
    if (index < 0) {
      return;
    }
    final current = _chansons[index];
    _chansons[index] = current.copyWith(isDownloaded: isDownloaded);
  }

  Future<String> downloadChanson(
    String chansonId, {
    bool lowDataMode = false,
  }) async {
    final downloadSpeed = lowDataMode ? 2 : 1;
    await Future.delayed(Duration(seconds: downloadSpeed));
    final chanson = _chansons.firstWhere(
      (song) => song.id == chansonId,
      orElse: () => _chansons.first,
    );
    final quality = lowDataMode ? 'MP3 64kbps' : 'MP3 128kbps';
    return 'Téléchargement ${chanson.title} ($quality) terminé en mode ${lowDataMode ? 'Low Data' : 'Normal'}.';
  }
}
