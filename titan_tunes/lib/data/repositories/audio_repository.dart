import 'dart:convert';

import 'package:titan_tunes/data/datasources/mock_audio_service.dart';
import 'package:titan_tunes/data/models/album.dart';
import 'package:titan_tunes/data/models/artiste.dart';
import 'package:titan_tunes/data/models/chanson.dart';
import 'package:titan_tunes/data/models/evenement.dart';
import 'package:titan_tunes/data/models/paiement.dart';
import 'package:titan_tunes/data/models/playlist.dart';
import 'package:titan_tunes/data/models/telechargement.dart';
import 'package:titan_tunes/data/models/ecoute.dart';
import 'package:titan_tunes/services/download_manager.dart';

import 'package:titan_tunes/data/models/user.dart';

abstract class AudioRepository {
  Future<void> initialize();
  List<Artiste> getArtistes();
  List<Album> getAlbums();
  List<Chanson> getChansons();
  List<Playlist> getPlaylists();
  List<Evenement> getEvenements();
  List<Paiement> getPaiements();
  List<Telechargement> getTelechargements();
  List<User> getUsers();
  List<Ecoute> getEcoutes();
  Future<String> streamChanson(
    String chansonId, {
    bool isSubscribed = false,
    DateTime? subscriptionExpiryAt,
  });
  Future<Chanson?> toggleFavorite(String chansonId);
  Future<String> downloadChanson(
    String chansonId, {
    bool lowDataMode = false,
    required bool isSubscribed,
    DateTime? subscriptionExpiryAt,
  });
  Future<void> refreshDownloadedAccess({DateTime? currentSubscriptionExpiry});
  Future<void> addToPlaylist(String playlistId, String chansonId);
  Future<void> removeFromPlaylist(String playlistId, String chansonId);
  Future<void> toggleFavoriteArtist(String artistId);
  Set<String> getFavoriteArtistIds();
  Artiste? getArtisteById(String id);
}

class MockAudioRepository implements AudioRepository {
  final MockAudioService _service;
  final DownloadManager _downloadManager;

  MockAudioRepository({
    MockAudioService? service,
    DownloadManager? downloadManager,
  }) : _service = service ?? MockAudioService(),
       _downloadManager = downloadManager ?? DownloadManager();

  @override
  Future<void> initialize() async {
    // Les données mock sont chargées directement par les getters.
    return;
  }

  @override
  List<Album> getAlbums() => _service.fetchAlbums();

  @override
  List<Artiste> getArtistes() => _service.fetchArtistes();

  @override
  List<Chanson> getChansons() => _service.fetchChansons();

  @override
  List<Evenement> getEvenements() => _service.fetchEvenements();

  @override
  List<Paiement> getPaiements() => _service.fetchPaiements();

  @override
  List<Playlist> getPlaylists() => _service.fetchPlaylists();

  @override
  List<Telechargement> getTelechargements() => _service.fetchTelechargements();

  @override
  List<User> getUsers() => _service.fetchUsers();

  @override
  List<Ecoute> getEcoutes() => _service.fetchEcoutes();

  @override
  Future<String> streamChanson(
    String chansonId, {
    bool isSubscribed = false,
    DateTime? subscriptionExpiryAt,
  }) async {
    final chanson = _service.fetchChansons().firstWhere(
      (song) => song.id == chansonId,
      orElse: () => _service.fetchChansons().first,
    );

    if (chanson.isDownloaded) {
      final available = await _downloadManager.isDownloadAvailable(
        chansonId,
        subscriptionExpiryAt,
      );
      if (!available) {
        return chanson.audioUrl.isNotEmpty
            ? chanson.audioUrl
            : 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';
      }
      final localBytes = await _downloadManager.loadDownloadedAudio(chansonId);
      if (localBytes != null) {
        final localPath = await _downloadManager.getDecryptedTempPath(
          chansonId,
          currentSubscriptionExpiry: subscriptionExpiryAt,
        );
        if (localPath != null) {
          return 'file://$localPath';
        }
      }
    }

    return chanson.audioUrl.isNotEmpty
        ? chanson.audioUrl
        : 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';
  }

  @override
  Future<Chanson?> toggleFavorite(String chansonId) =>
      _service.toggleFavorite(chansonId);

  @override
  Future<String> downloadChanson(
    String chansonId, {
    bool lowDataMode = false,
    required bool isSubscribed,
    DateTime? subscriptionExpiryAt,
  }) async {
    final chanson = _service.fetchChansons().firstWhere(
      (song) => song.id == chansonId,
      orElse: () => _service.fetchChansons().first,
    );

    if (!isSubscribed ||
        subscriptionExpiryAt == null ||
        subscriptionExpiryAt.isBefore(DateTime.now())) {
      return 'Vous devez être abonné et actif pour télécharger ce titre.';
    }

    final content = utf8.encode(
      'Fichier audio protégé pour "${chanson.title}" (${chanson.id}) - stockage chiffré localement.',
    );
    await _downloadManager.saveDownloadedAudio(
      chansonId,
      content,
      subscriptionExpiry: subscriptionExpiryAt,
    );

    _service.updateDownloadedState(chansonId, true);

    return 'Téléchargement protégé terminé pour "${chanson.title}".';
  }

  @override
  Future<void> refreshDownloadedAccess({
    DateTime? currentSubscriptionExpiry,
  }) async {
    await _downloadManager.refreshDownloadAccess(
      currentSubscriptionExpiry: currentSubscriptionExpiry,
    );
  }

  @override
  Future<void> addToPlaylist(String playlistId, String chansonId) async {
    await _service.addToPlaylist(playlistId, chansonId);
  }

  @override
  Future<void> removeFromPlaylist(String playlistId, String chansonId) async {
    await _service.removeFromPlaylist(playlistId, chansonId);
  }

  @override
  Future<void> toggleFavoriteArtist(String artistId) async {}

  @override
  Set<String> getFavoriteArtistIds() => {};

  @override
  Artiste? getArtisteById(String id) => null;
}
