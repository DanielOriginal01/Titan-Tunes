import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:titan_tunes/data/models/album.dart';
import 'package:titan_tunes/data/models/artiste.dart';
import 'package:titan_tunes/data/models/chanson.dart';
import 'package:titan_tunes/data/models/ecoute.dart';
import 'package:titan_tunes/data/models/playlist.dart';
import 'package:titan_tunes/data/repositories/audio_repository.dart';
import 'package:titan_tunes/data/repositories/remote_audio_repository.dart';
import 'package:titan_tunes/providers/auth_provider.dart';
import 'package:titan_tunes/services/download_storage_service.dart';

class HistoryItem {
  final String id;
  final Chanson chanson;
  HistoryItem({required this.id, required this.chanson});
}

class AudioProvider extends ChangeNotifier {
  final AudioRepository _repository;
  final DownloadStorageService? _dlStorage;
  AuthProvider? _authProvider;
  final AudioPlayer _player = AudioPlayer();
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;
  String? _lastStreamUrl;

  AudioProvider({required AudioRepository repository, DownloadStorageService? dlStorage, AuthProvider? authProvider})
      : _repository = repository,
        _dlStorage = dlStorage,
        _authProvider = authProvider {
    _repository.initialize();
    _playerStateSubscription = _player.playerStateStream.listen(
      _handlePlayerState,
    );
    _positionSubscription = _player.positionStream.listen((value) {
      position = value;
      _progressFraction = duration.inMicroseconds > 0
          ? (value.inMicroseconds / duration.inMicroseconds).clamp(0.0, 1.0)
          : 0.0;
      notifyListeners();
    });
    _durationSubscription = _player.durationStream.listen((value) {
      if (value != null) {
        duration = value;
        notifyListeners();
      }
    });
    _loadInitialData();
  }

  List<Artiste> artistes = [];
  List<Album> albums = [];
  List<Chanson> chansons = [];
  List<Chanson> tendances = [];
  List<Playlist> playlists = [];
  List<Ecoute> ecoutes = [];
  List<Chanson> favorites = [];
  List<String> searchHistory = [];
  final Set<String> favoriteArtistIds = {};
  Chanson? currentChanson;
  bool isPlaying = false;
  bool isLowDataMode = false;
  bool isLoading = true;
  bool _isBuffering = false;
  double _progressFraction = 0.0;
  LoopMode loopMode = LoopMode.off;
  bool shuffleEnabled = false;
  Duration position = Duration.zero;
  Duration duration = Duration.zero;

  void _loadInitialData() {
    artistes = _repository.getArtistes();
    albums = _repository.getAlbums();
    chansons = _repository.getChansons();
    tendances = chansons.take(10).toList();
    playlists = _repository.getPlaylists();
    ecoutes = _repository.getEcoutes();
    favorites = chansons.where((song) => song.isFavorite).toList();
    favoriteArtistIds.addAll(_repository.getFavoriteArtistIds());
    isLoading = false;
    notifyListeners();
  }

  // --- Compatibility getters / methods used by UI ---

  double get progressFraction => _progressFraction;

  bool get isBuffering => _isBuffering;

  void _handlePlayerState(PlayerState state) {
    isPlaying = state.playing;
    _isBuffering = state.processingState == ProcessingState.buffering;
    if (state.processingState == ProcessingState.completed) {
      playNext();
    }
    notifyListeners();
  }

  Future<void> _playResolvedUrl(String url) async {
    if (url.isEmpty) {
      isPlaying = false;
      notifyListeners();
      return;
    }

    try {
      if (url.startsWith('file://')) {
        await _player.setFilePath(url.replaceFirst('file://', ''));
      } else {
        await _player.setUrl(url);
      }
      await _player.play();
    } catch (e) {
      isPlaying = false;
      debugPrint('AudioProvider._playResolvedUrl error: $e');
      notifyListeners();
    }
  }

  Future<void> _playCurrentSelection() async {
    final selected = currentChanson;
    if (selected == null) return;
    final streamUrl = await _repository.streamChanson(selected.id);
    await _playResolvedUrl(streamUrl);
    notifyListeners();
  }

  Future<void> playPrevious() async {
    if (chansons.isEmpty) return;
    if (currentChanson == null) {
      currentChanson = chansons.first;
    } else {
      final idx = chansons.indexWhere((c) => c.id == currentChanson?.id);
      final prev = idx > 0 ? chansons[idx - 1] : chansons.last;
      currentChanson = prev;
    }
    await _playCurrentSelection();
  }

  Future<void> playNext() async {
    if (chansons.isEmpty) return;
    if (currentChanson == null) {
      currentChanson = chansons.first;
    } else {
      final idx = chansons.indexWhere((c) => c.id == currentChanson?.id);
      final next = (idx >= 0 && idx < chansons.length - 1)
          ? chansons[idx + 1]
          : chansons.first;
      currentChanson = next;
    }
    await _playCurrentSelection();
  }

  void addSearchHistory(String q) {
    final v = q.trim();
    if (v.isEmpty) return;
    searchHistory.remove(v);
    searchHistory.insert(0, v);
    if (searchHistory.length > 30) searchHistory.removeLast();
    notifyListeners();
  }

  void clearSearchHistory() {
    searchHistory.clear();
    notifyListeners();
  }

  void removeSearchHistory(String q) {
    searchHistory.remove(q);
    notifyListeners();
  }

  void syncUser(String? userId) {
    if (_repository is RemoteAudioRepository) {
      (_repository as RemoteAudioRepository).userId = userId;
    }
    _loadInitialData();
  }

  Future<bool> deletePlaylist(String playlistId) async {
    removePlaylist(playlistId);
    return true;
  }

  Future<Playlist?> createPlaylist(String title, String description) async {
    addPlaylist(title: title, description: description, isPublic: true);
    return playlists.isNotEmpty ? playlists.first : null;
  }

  void updatePlaylist(String playlistId, Playlist updated) {
    final index = playlists.indexWhere((p) => p.id == playlistId);
    if (index < 0) return;
    playlists[index] = updated;
    notifyListeners();
  }

  List<DownloadRecord> get downloads => _dlStorage?.available ?? [];

  Future<void> removeDownload(String chansonId) async {
    if (_dlStorage != null) {
      await _dlStorage!.remove(chansonId);
    }
    final idx = chansons.indexWhere((c) => c.id == chansonId);
    if (idx >= 0) {
      chansons[idx] = chansons[idx].copyWith(isDownloaded: false);
    }
    if (currentChanson?.id == chansonId) {
      currentChanson = currentChanson!.copyWith(isDownloaded: false);
    }
    notifyListeners();
  }

  // History item wrapper used by UI (provides chanson object)
  List<HistoryItem> get history {
    return ecoutes.map((e) {
      final song = chansons.firstWhere(
        (c) => c.id == e.chansonId,
        orElse: () => chansons.isNotEmpty ? chansons.first : Chanson.empty(),
      );
      return HistoryItem(id: e.id, chanson: song);
    }).toList();
  }

  void removeHistoryItem(String id) {
    ecoutes.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void clearHistory() {
    ecoutes.clear();
    notifyListeners();
  }

  void refreshData() {
    _loadInitialData();
  }

  void refreshFavorites() {
    favorites = chansons.where((song) => song.isFavorite).toList();
    notifyListeners();
  }

  Future<void> playChanson(Chanson chanson) async {
    // Restreindre les invités à 10 chansons max
    if (_authProvider != null && _authProvider!.isGuest && !_authProvider!.canPlayAsGuest) {
      return;
    }

    currentChanson = chanson;
    position = Duration.zero;
    duration = chanson.duration;
    _progressFraction = 0.0;
    isPlaying = true;
    notifyListeners();

    _authProvider?.incrementGuestPlayCount();

    final streamUrl = await _repository.streamChanson(chanson.id);
    _lastStreamUrl = streamUrl;
    await _playResolvedUrl(streamUrl);
  }

  Future<void> togglePlayPause() async {
    if (currentChanson == null) {
      if (chansons.isNotEmpty) {
        currentChanson = chansons.first;
      } else {
        return;
      }
    }

    if (_player.playing) {
      await _player.pause();
    } else if (_lastStreamUrl != null && _lastStreamUrl!.isNotEmpty) {
      await _playResolvedUrl(_lastStreamUrl!);
    } else {
      final url = await _repository.streamChanson(currentChanson!.id);
      _lastStreamUrl = url;
      await _playResolvedUrl(url);
    }
    notifyListeners();
  }

  Future<void> toggleFavorite(Chanson chanson) async {
    final updated = await _repository.toggleFavorite(chanson.id);
    if (updated == null) return;

    final index = chansons.indexWhere((item) => item.id == updated.id);
    if (index >= 0) {
      chansons[index] = updated;
    }

    favorites = chansons.where((song) => song.isFavorite).toList();

    if (currentChanson?.id == updated.id) {
      currentChanson = updated;
    }

    notifyListeners();
  }

  bool isArtistFavorite(String artistId) =>
      favoriteArtistIds.contains(artistId);

  Future<void> toggleFavoriteArtist(String artistId) async {
    if (!favoriteArtistIds.add(artistId)) {
      favoriteArtistIds.remove(artistId);
    }
    notifyListeners();
    await _repository.toggleFavoriteArtist(artistId);
  }

  void addPlaylist({
    required String title,
    required String description,
    required bool isPublic,
    List<String> chansonIds = const [],
  }) {
    final newPlaylist = Playlist(
      id: 'pl_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: description,
      creatorId: 'u-local',
      chansonIds: chansonIds,
      isPublic: isPublic,
    );
    playlists = [newPlaylist, ...playlists];
    notifyListeners();
  }

  void removePlaylist(String playlistId) {
    playlists.removeWhere((playlist) => playlist.id == playlistId);
    notifyListeners();
  }

  void toggleLowDataMode() {
    isLowDataMode = !isLowDataMode;
    notifyListeners();
  }

  Future<String> downloadCurrentChanson({
    bool isSubscribed = false,
    DateTime? subscriptionExpiryAt,
  }) async {
    if (currentChanson == null) {
      return 'Aucune chanson sélectionnée pour le téléchargement.';
    }

    final message = await _repository.downloadChanson(
      currentChanson!.id,
      lowDataMode: isLowDataMode,
      isSubscribed: isSubscribed,
      subscriptionExpiryAt: subscriptionExpiryAt,
    );

    if (message.contains('Téléchargement protégé terminé')) {
      final updatedChanson = currentChanson!.copyWith(isDownloaded: true);
      final index = chansons.indexWhere((song) => song.id == updatedChanson.id);
      if (index >= 0) {
        chansons[index] = updatedChanson;
      }
      currentChanson = updatedChanson;
      notifyListeners();
    }

    return message;
  }

  // Playback helpers
  void toggleShuffle() {
    shuffleEnabled = !shuffleEnabled;
    notifyListeners();
  }

  void cycleLoopMode() {
    if (loopMode == LoopMode.off) {
      loopMode = LoopMode.one;
    } else if (loopMode == LoopMode.one) {
      loopMode = LoopMode.all;
    } else {
      loopMode = LoopMode.off;
    }
    notifyListeners();
  }

  void seekTo(Duration d) {
    position = d;
    _player.seek(d);
    notifyListeners();
  }

  Future<void> addSongToPlaylist(String playlistId, String chansonId) async {
    await _repository.addToPlaylist(playlistId, chansonId);
    final index = playlists.indexWhere((playlist) => playlist.id == playlistId);
    if (index >= 0) {
      final existing = playlists[index];
      if (!existing.chansonIds.contains(chansonId)) {
        playlists[index] = existing.copyWith(
          chansonIds: [...existing.chansonIds, chansonId],
        );
      }
      notifyListeners();
    }
  }

  Future<void> removeSongFromPlaylist(
    String playlistId,
    String chansonId,
  ) async {
    await _repository.removeFromPlaylist(playlistId, chansonId);
    final index = playlists.indexWhere((playlist) => playlist.id == playlistId);
    if (index >= 0) {
      final existing = playlists[index];
      playlists[index] = existing.copyWith(
        chansonIds: existing.chansonIds.where((id) => id != chansonId).toList(),
      );
      notifyListeners();
    }
  }

  Future<void> refreshDownloadedAccess({
    DateTime? currentSubscriptionExpiry,
  }) async {
    await _repository.refreshDownloadedAccess(
      currentSubscriptionExpiry: currentSubscriptionExpiry,
    );
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _player.dispose();
    super.dispose();
  }
}