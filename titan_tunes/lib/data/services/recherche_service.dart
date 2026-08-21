import 'package:flutter/foundation.dart';
import 'package:titan_tunes/data/models/search_result.dart';
import 'package:titan_tunes/network/network_api_client.dart';

abstract class RechercheService {
  Future<SearchGlobalResult?> rechercheGlobale(String query, {int limit = 5});
}

class RemoteRechercheService implements RechercheService {
  final NetworkApiClient _client;

  RemoteRechercheService({required NetworkApiClient client})
      : _client = client;

  @override
  Future<SearchGlobalResult?> rechercheGlobale(
    String query, {
    int limit = 5,
  }) async {
    try {
      final response = await _client.get(
        '/search',
        queryParameters: {
          'q': query,
          'query': query,
          'limit': limit,
        },
      );

      final data = response.data;
      if (data == null) return null;

      final Map<String, dynamic> body = data is Map<String, dynamic>
          ? data
          : Map<String, dynamic>.from(data as Map);

      final resultData = body['data'] as Map<String, dynamic>? ?? body;
      return SearchGlobalResult.fromJson(resultData);
    } catch (e) {
      debugPrint('RemoteRechercheService.rechercheGlobale error: $e');
      return null;
    }
  }
}

class MockRechercheService implements RechercheService {
  @override
  Future<SearchGlobalResult?> rechercheGlobale(
    String query, {
    int limit = 5,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const SearchGlobalResult(
      chansons: [],
      artistes: [],
      albums: [],
      playlists: [],
    );
  }
}
