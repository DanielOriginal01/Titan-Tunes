import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:titan_tunes/core/api_config.dart';
import 'package:titan_tunes/data/models/album.dart';
import 'package:titan_tunes/data/models/artiste.dart';
import 'package:titan_tunes/data/models/chanson.dart';
import 'package:titan_tunes/data/models/ecoute.dart';
import 'package:titan_tunes/data/models/evenement.dart';
import 'package:titan_tunes/data/models/paiement.dart';
import 'package:titan_tunes/data/models/playlist.dart';
import 'package:titan_tunes/data/models/telechargement.dart';
import 'package:titan_tunes/data/models/user.dart';
import 'package:titan_tunes/data/repositories/audio_repository.dart';
import 'package:titan_tunes/network/network_api_client.dart';
import 'package:titan_tunes/services/download_manager.dart';
import 'package:titan_tunes/services/download_storage_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// RemoteAudioRepository — implémentation réelle via l'API REST Spring Boot
// Base URL : http://localhost:8080/api/v1
// ─────────────────────────────────────────────────────────────────────────────
class RemoteAudioRepository implements AudioRepository {
  final NetworkApiClient _api;
  final DownloadManager _dm;
  final DownloadStorageService _dlStorage;
  final Dio _dioBinary;

  // Caches en mémoire rechargés à chaque initialize()
  final List<Artiste> _artistes = [];
  final List<Album> _albums = [];
  final List<Chanson> _chansons = [];
  final List<Chanson> _tendances = [];
  final List<Playlist> _playlists = [];
  final List<Evenement> _evenements = [];
  final List<Paiement> _paiements = [];
  final List<Telechargement> _telechargements = [];
  final List<User> _users = [];
  final List<Ecoute> _ecoutes = [];
  final Set<String> _favoriteArtistIds = {};

  // ID de l'utilisateur connecté (injecté après login)
  String? userId;

  /// Retourne les IDs des artistes suivis/favoris
  @override
  Set<String> getFavoriteArtistIds() => Set.unmodifiable(_favoriteArtistIds);

  @override
  Artiste? getArtisteById(String id) {
    for (final a in _artistes) {
      if (a.id == id) return a;
    }
    return null;
  }

  RemoteAudioRepository({
    required NetworkApiClient apiClient,
    required DownloadStorageService downloadStorage,
    DownloadManager? downloadManager,
    Dio? dioBinary,
    this.userId,
  }) : _api = apiClient,
       _dlStorage = downloadStorage,
       _dm = downloadManager ?? DownloadManager(),
       _dioBinary =
           dioBinary ??
           Dio(
             BaseOptions(
               connectTimeout: const Duration(seconds: 20),
               receiveTimeout: const Duration(seconds: 120),
               responseType: ResponseType.bytes,
             ),
           );

  // ── Getters (caches) ───────────────────────────────────────────────────────
  @override
  List<Artiste> getArtistes() => List.unmodifiable(_artistes);
  @override
  List<Album> getAlbums() => List.unmodifiable(_albums);
  @override
  List<Chanson> getChansons() => List.unmodifiable(_chansons);
  List<Chanson> getTendances() => List.unmodifiable(_tendances);
  @override
  List<Playlist> getPlaylists() => List.unmodifiable(_playlists);
  @override
  List<Evenement> getEvenements() => List.unmodifiable(_evenements);
  @override
  List<Paiement> getPaiements() => List.unmodifiable(_paiements);
  @override
  List<Telechargement> getTelechargements() =>
      List.unmodifiable(_telechargements);
  @override
  List<User> getUsers() => List.unmodifiable(_users);
  @override
  List<Ecoute> getEcoutes() => List.unmodifiable(_ecoutes);

  // ── Initialisation — chargement parallèle ─────────────────────────────────
  @override
  Future<void> initialize() async {
    try {
      final results = await Future.wait([
        _fetchList('/artistes', Artiste.fromJson),
        _fetchList('/albums', Album.fromJson),
        _fetchList('/chansons', _chansonFromApi),
        _fetchList('/chansons/tendances', _chansonFromApi),
        if (userId != null)
          _fetchList('/playlists/auditeur/$userId', Playlist.fromJson)
        else
          Future.value(<Playlist>[]),
      ], eagerError: false);

      _artistes
        ..clear()
        ..addAll(results[0] as List<Artiste>);
      _albums
        ..clear()
        ..addAll(results[1] as List<Album>);
      _chansons
        ..clear()
        ..addAll(results[2] as List<Chanson>);
      _tendances
        ..clear()
        ..addAll(results[3] as List<Chanson>);
      _playlists
        ..clear()
        ..addAll(results[4] as List<Playlist>);

      // Synchronise l'état des favoris si l'utilisateur est connecté
      if (userId != null) {
        await _syncFavorites();
      }

      // Purge des téléchargements expirés au démarrage
      await _dlStorage.purgeExpired();
    } catch (e) {
      debugPrint('RemoteAudioRepository.initialize error: $e');
    }
  }

  Future<void> _syncFavorites() async {
    if (userId == null) return;
    try {
      final response = await _api.get('/favoris/user/$userId');
      final body = _body(response.data);
      final data = body['data'];
      if (data is List) {
        final chansonFavIds = <String>{};
        _favoriteArtistIds.clear();
        for (final item in data) {
          final type = (item['type'] as String? ?? '').toUpperCase();
          final targetId = item['targetId'] ?? item['idFav'] ?? item['id'];
          if (targetId == null) continue;
          final sid = targetId.toString();
          if (type == 'ARTISTE') {
            _favoriteArtistIds.add(sid);
          } else {
            chansonFavIds.add(sid);
          }
        }
        for (int i = 0; i < _chansons.length; i++) {
          if (chansonFavIds.contains(_chansons[i].id)) {
            _chansons[i] = _chansons[i].copyWith(isFavorite: true);
          }
        }
      }
    } catch (e) {
      debugPrint('_syncFavorites error: $e');
    }
  }

  // ── Streaming ──────────────────────────────────────────────────────────────
  @override
  Future<String> streamChanson(
    String chansonId, {
    bool isSubscribed = false,
    DateTime? subscriptionExpiryAt,
  }) async {
    // 1. Fichier téléchargé localement ?
    final result = await _dm.checkAccess(
      chansonId,
      currentSubscriptionExpiry: subscriptionExpiryAt,
    );
    if (result.canPlay && result.decryptedBytes != null) {
      final path = await _dm.getDecryptedTempPath(
        chansonId,
        currentSubscriptionExpiry: subscriptionExpiryAt,
      );
      if (path != null) return 'file://$path';
    }

    // 2. Endpoint binaire du backend (GET /chansons/{id}/audio)
    //    Le backend gère le proxy MinIO + Range requests (206).
    final binaryUrl = '${_api.baseUrl}/chansons/$chansonId/audio';
    return binaryUrl;
  }

  // ── Toggle favori ──────────────────────────────────────────────────────────
  @override
  Future<Chanson?> toggleFavorite(String chansonId) async {
    if (userId == null) return null;
    try {
      final chanson = _chansons.where((c) => c.id == chansonId).firstOrNull;
      if (chanson == null) return null;

      if (chanson.isFavorite) {
        await _api.delete(
          '/favoris/user/$userId/target/$chansonId',
          queryParameters: {'type': 'CHANSON'},
        );
      } else {
        await _api.post(
          '/favoris',
          data: {
            'utilisateurId': int.tryParse(userId!) ?? userId,
            'targetId': int.tryParse(chansonId) ?? chansonId,
            'type': 'CHANSON',
          },
        );
      }

      final idx = _chansons.indexWhere((c) => c.id == chansonId);
      if (idx >= 0) {
        final updated = _chansons[idx].copyWith(
          isFavorite: !chanson.isFavorite,
        );
        _chansons[idx] = updated;
        return updated;
      }
    } catch (e) {
      debugPrint('toggleFavorite error: $e');
    }
    return null;
  }

  // ── Toggle favori Artiste (Abonnement) ────────────────────────────────────
  @override
  Future<void> toggleFavoriteArtist(String artistId) async {
    if (userId == null) return;
    try {
      final isFollowing = _favoriteArtistIds.contains(artistId);
      if (isFollowing) {
        await _api.delete(
          '/favoris/user/$userId/target/$artistId',
          queryParameters: {'type': 'ARTISTE'},
        );
        _favoriteArtistIds.remove(artistId);
      } else {
        await _api.post(
          '/favoris',
          data: {
            'utilisateurId': int.tryParse(userId!) ?? userId,
            'targetId': int.tryParse(artistId) ?? artistId,
            'type': 'ARTISTE',
          },
        );
        _favoriteArtistIds.add(artistId);
      }
    } catch (e) {
      debugPrint('toggleFavoriteArtist error: $e');
    }
  }

  // ── Téléchargement ─────────────────────────────────────────────────────────
  @override
  Future<String> downloadChanson(
    String chansonId, {
    bool lowDataMode = false,
    required bool isSubscribed,
    DateTime? subscriptionExpiryAt,
  }) async {
    if (!isSubscribed ||
        subscriptionExpiryAt == null ||
        subscriptionExpiryAt.isBefore(DateTime.now())) {
      return '🔒 Abonnement requis pour télécharger ce titre.';
    }

    final chanson = _chansons.where((c) => c.id == chansonId).firstOrNull;
    if (chanson == null) return '❌ Chanson introuvable.';

    try {
      final streamUrl = await streamChanson(
        chansonId,
        isSubscribed: isSubscribed,
        subscriptionExpiryAt: subscriptionExpiryAt,
      );
      if (streamUrl.isEmpty) return '❌ URL de téléchargement introuvable.';

      final response = await _dioBinary.get<List<int>>(
        streamUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      if (response.statusCode != 200 || response.data == null) {
        return '❌ Erreur de téléchargement (${response.statusCode}).';
      }

      final audioBytes = Uint8List.fromList(response.data!);

      await _dm.save(
        chansonId,
        audioBytes,
        subscriptionExpiry: subscriptionExpiryAt,
      );

      await _dlStorage.addOrUpdate(
        DownloadRecord(
          chansonId: chansonId,
          titre: chanson.title,
          artisteName: chanson.artistName,
          coverUrl: chanson.coverUrl,
          sizeBytes: audioBytes.length,
          downloadedAt: DateTime.now(),
          subscriptionExpiryAt: subscriptionExpiryAt,
          qualityKbps: lowDataMode ? 128 : 320,
        ),
      );

      final idx = _chansons.indexWhere((c) => c.id == chansonId);
      if (idx >= 0) {
        _chansons[idx] = _chansons[idx].copyWith(isDownloaded: true);
      }

      final size = (audioBytes.length / 1024).round();
      return '✅ "${chanson.title}" téléchargé ($size Ko). '
          'Accès jusqu\'au ${_fmt(subscriptionExpiryAt)} + 7j de grâce.';
    } on DioException catch (e) {
      debugPrint('downloadChanson DioError: $e');
      return '❌ Erreur réseau : ${e.message}';
    } catch (e) {
      debugPrint('downloadChanson error: $e');
      return '❌ Erreur inattendue : $e';
    }
  }

  // ── Refresh accès téléchargements ──────────────────────────────────────────
  @override
  Future<void> refreshDownloadedAccess({
    DateTime? currentSubscriptionExpiry,
  }) async {
    if (currentSubscriptionExpiry != null) {
      await _dm.refreshAccess(currentSubscriptionExpiry);
      await _dlStorage.refreshExpiry(currentSubscriptionExpiry);
    } else {
      await _dm.purgeExpired();
      await _dlStorage.purgeExpired();
    }
  }

  // ── Playlists (mutations) ──────────────────────────────────────────────────
  Future<void> createPlaylist(
    String name,
    String description,
    String userId,
  ) async {
    await createPlaylistDetailed(
      title: name,
      description: description,
      isPublic: true,
      ownerUserId: userId,
    );
  }

  Future<Playlist?> createPlaylistDetailed({
    required String title,
    required String description,
    required bool isPublic,
    String? ownerUserId,
  }) async {
    final activeUserId = ownerUserId ?? userId;
    if (activeUserId == null) return null;
    try {
      final response = await _api.post(
        '/playlists',
        data: {
          'title': title,
          'nom': title,
          'description': description,
          'privee': !isPublic,
          'isPublic': isPublic,
          'auditeurId': int.tryParse(activeUserId) ?? activeUserId,
        },
      );
      final body = _body(response.data);
      if (!_ok(body, response.statusCode)) return null;
      final data = body['data'] as Map<String, dynamic>?;
      if (data == null) return null;
      final pl = Playlist.fromJson(data);
      _playlists.insert(0, pl);
      return pl;
    } catch (e) {
      debugPrint('createPlaylist error: $e');
      return null;
    }
  }

  @override
  Future<void> addToPlaylist(String playlistId, String chansonId) async {
    await addSongToPlaylist(playlistId, chansonId);
  }

  @override
  Future<void> removeFromPlaylist(String playlistId, String chansonId) async {
    await removeSongFromPlaylist(playlistId, chansonId);
  }

  Future<bool> deletePlaylist(String playlistId) async {
    try {
      final response = await _api.delete('/playlists/$playlistId');
      final ok = _ok(_body(response.data), response.statusCode);
      if (ok) {
        _playlists.removeWhere((p) => p.id == playlistId);
      }
      return ok;
    } catch (e) {
      debugPrint('deletePlaylist error: $e');
      return false;
    }
  }

  Future<bool> addSongToPlaylist(String playlistId, String chansonId) async {
    try {
      final response = await _api.post(
        '/playlists/$playlistId/chansons/$chansonId',
      );
      return _ok(_body(response.data), response.statusCode);
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeSongFromPlaylist(
    String playlistId,
    String chansonId,
  ) async {
    try {
      final response = await _api.delete(
        '/playlists/$playlistId/chansons/$chansonId',
      );
      return _ok(_body(response.data), response.statusCode);
    } catch (e) {
      return false;
    }
  }

  // ── Écoutes Asynchrones ───────────────────────────────────────────────────
  Future<void> recordEcoute(String chansonId, int dureeSecondes) async {
    if (userId == null) return;
    try {
      await _api.post(
        '/ecoutes/async',
        data: {
          'auditeurId': int.tryParse(userId!) ?? userId,
          'chansonId': int.tryParse(chansonId) ?? chansonId,
          'dureeEcoute': dureeSecondes,
        },
      );
      debugPrint(
        '✅ Écoute enregistrée : chanson $chansonId, durée $dureeSecondes s.',
      );
    } catch (e) {
      debugPrint('recordEcoute error: $e');
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  Future<List<T>> _fetchList<T>(
    String path,
    T Function(Map<String, dynamic>) parser,
  ) async {
    try {
      final response = await _api.get(path);
      final body = _body(response.data);

      List<dynamic> list;
      if (response.data is List) {
        list = response.data as List<dynamic>;
      } else {
        final data = body['data'];
        if (data is Map && data['content'] is List) {
          list = data['content'] as List<dynamic>;
        } else if (data is List) {
          list = data;
        } else {
          list = [];
        }
      }

      return list
          .map((e) => parser(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      debugPrint('_fetchList($path) error: $e');
      return [];
    }
  }

  static Chanson _chansonFromApi(Map<String, dynamic> json) {
    final rawGenre = json['genre'] ?? json['genres'];
    final genres = rawGenre is List
        ? rawGenre.map((e) => e.toString()).toList()
        : rawGenre is String && rawGenre.isNotEmpty
        ? [rawGenre]
        : <String>[];

    final parsedId = (json['id'] ?? '').toString();

    final rawAudio =
        json['audioUrl'] as String? ??
        json['urlAudio'] as String? ??
        json['streamUrl'] as String? ??
        json['fileUrl'] as String? ??
        json['downloadUrl'] as String? ??
        '';

    final rawCover =
        json['coverImage'] as String? ??
        json['coverUrl'] as String? ??
        json['photoUrl'] as String? ??
        json['albumCoverUrl'] as String? ??
        '';

    final audioUrl = ApiConfig.resolveMediaUrl(
      rawAudio,
      endpoint: parsedId.isNotEmpty ? '/chansons/$parsedId/audio' : '',
    );

    final cover = ApiConfig.resolveMediaUrl(
      rawCover,
      endpoint: parsedId.isNotEmpty ? '/chansons/$parsedId/cover' : '',
    );

    return Chanson(
      id: parsedId,
      title: json['titre'] as String? ?? json['title'] as String? ?? '',
      artisteId: (json['artisteId'] ?? json['artiste']?['id'] ?? '').toString(),
      albumId: (json['albumId'] ?? '').toString(),
      genres: genres,
      duration: Duration(
        seconds:
            (json['duree'] as num?)?.toInt() ??
            (json['duration'] as num?)?.toInt() ??
            0,
      ),
      popularity:
          (json['nbEcoutes'] as num?)?.toInt() ??
          (json['popularity'] as num?)?.toInt() ??
          0,
      coverUrl: cover,
      lyrics: json['parole'] as String? ?? json['lyrics'] as String? ?? '',
      audioUrl: audioUrl,
      artistName:
          json['artisteNom'] as String? ??
          json['artisteName'] as String? ??
          json['nomArtistique'] as String? ??
          '',
      albumCoverUrl: json['albumCoverUrl'] as String? ?? cover,
      isFavorite: json['isFavorite'] as bool? ?? false,
      isDownloaded: json['isDownloaded'] as bool? ?? false,
    );
  }

  Map<String, dynamic> _body(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return {};
  }

  bool _ok(Map<String, dynamic> body, int? code) {
    final success = body['success'] as bool?;
    if (success != null) return success;
    return (code ?? 0) >= 200 && (code ?? 0) < 300;
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/${d.year}';
}
