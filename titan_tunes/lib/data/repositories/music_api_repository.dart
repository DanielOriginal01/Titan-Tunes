import 'dart:convert';

import 'package:titan_tunes/data/models/api_response.dart';
import 'package:titan_tunes/data/models/chanson.dart';
import 'package:titan_tunes/data/repositories/remote_audio_repository.dart';
import 'package:titan_tunes/network/network_api_client.dart';

class MusicApiRepository {
  final NetworkApiClient apiClient;
  final TokenVault tokenVault;
  final RemoteAudioRepository? _remoteRepo;

  MusicApiRepository({
    required this.apiClient,
    required this.tokenVault,
    RemoteAudioRepository? remoteRepo,
  }) : _remoteRepo = remoteRepo;

  DateTime? _extractJwtExpiry(String jwt) {
    try {
      final parts = jwt.split('.');
      if (parts.length != 3) return null;
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final data = jsonDecode(decoded) as Map<String, dynamic>;
      final expValue = data['exp'];
      if (expValue is int) {
        return DateTime.fromMillisecondsSinceEpoch(expValue * 1000);
      }
      if (expValue is String) {
        return DateTime.fromMillisecondsSinceEpoch(int.parse(expValue) * 1000);
      }
    } catch (_) {}
    return null;
  }

  Future<List<Chanson>> fetchTrendingSongs() async {
    // Utiliser le endpoint correct du backend : /chansons/tendances
    final response = await apiClient.get('/chansons/tendances');

    if (response.statusCode != 200) {
      throw Exception('Impossible de charger les titres tendance.');
    }

    final data = response.data;
    if (data == null) return [];

    final Map<String, dynamic> body = data is Map<String, dynamic>
        ? data
        : Map<String, dynamic>.from(data as Map);

    final listData = body['data'];
    List<dynamic> list;
    if (listData is List) {
      list = listData;
    } else if (listData is Map && listData['content'] is List) {
      list = listData['content'] as List<dynamic>;
    } else {
      list = [];
    }

    return list
        .map((item) => Chanson.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<List<Chanson>> fetchPlaylistTracks(String playlistId) async {
    // Utiliser le endpoint correct : /playlists/{id} qui retourne les chansons
    final response = await apiClient.get('/playlists/$playlistId');

    if (response.statusCode != 200) {
      throw Exception('Impossible de charger les pistes de la playlist.');
    }

    final data = response.data;
    if (data == null) return [];

    final Map<String, dynamic> body = data is Map<String, dynamic>
        ? data
        : Map<String, dynamic>.from(data as Map);

    final resultData = body['data'] as Map<String, dynamic>? ?? body;
    final chansonsData = resultData['chansons'] as List<dynamic>? ?? [];

    return chansonsData
        .map((item) => Chanson.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }
}
