import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:titan_tunes/data/models/album.dart';
import 'package:titan_tunes/data/models/api_response.dart';
import 'package:titan_tunes/data/models/artiste_dashboard.dart';
import 'package:titan_tunes/data/models/categorie.dart';
import 'package:titan_tunes/data/models/chanson.dart';
import 'package:titan_tunes/data/models/reversement.dart';
import 'package:titan_tunes/network/network_api_client.dart';

abstract class ArtisteService {
  Future<ArtisteDashboardStats?> getDashboard(String artisteId);
  Future<PageResponse<Reversement>> getReversements(
    String artisteId, {
    int page = 0,
    int size = 10,
  });
  Future<List<Categorie>> getCategories();
  Future<List<Album>> getAlbumsByArtiste(String artisteId);
  Future<List<Chanson>> getChansonsByArtiste(String artisteId);
  Future<String?> creerAlbum({
    required String title,
    DateTime? dateSortie,
    String? artisteId,
    Uint8List? coverBytes,
    String? coverPath,
    String? coverName,
  });
  Future<String?> publierChanson({
    required String titre,
    required int duree,
    required String parole,
    required String artisteId,
    required int categorieId,
    int? albumId,
    String? filePath,
    Uint8List? fileBytes,
    String? fileName,
    Uint8List? coverBytes,
    String? coverPath,
    String? coverName,
  });
}

class RemoteArtisteService implements ArtisteService {
  final NetworkApiClient _client;

  RemoteArtisteService({required NetworkApiClient client}) : _client = client;

  @override
  Future<ArtisteDashboardStats?> getDashboard(String artisteId) async {
    try {
      final response = await _client.get('/artistes/$artisteId/dashboard');
      final body = _parseBody(response.data);
      if (_isSuccess(body, response.statusCode)) {
        final data = body['data'] as Map<String, dynamic>? ?? body;
        return ArtisteDashboardStats.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('RemoteArtisteService.getDashboard error: $e');
      return null;
    }
  }

  @override
  Future<PageResponse<Reversement>> getReversements(
    String artisteId, {
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response = await _client.get(
        '/reversements/artiste/$artisteId',
        queryParameters: {'page': page, 'size': size},
      );
      final body = _parseBody(response.data);
      if (_isSuccess(body, response.statusCode)) {
        final data = body['data'] as Map<String, dynamic>? ?? body;
        return PageResponse<Reversement>.fromJson(
          data,
          (item) => Reversement.fromJson(item),
        );
      }
      return PageResponse<Reversement>(
        content: [],
        page: page,
        size: size,
        totalElements: 0,
        totalPages: 0,
        first: true,
        last: true,
        empty: true,
      );
    } catch (e) {
      debugPrint('RemoteArtisteService.getReversements error: $e');
      return PageResponse<Reversement>(
        content: [],
        page: page,
        size: size,
        totalElements: 0,
        totalPages: 0,
        first: true,
        last: true,
        empty: true,
      );
    }
  }

  @override
  Future<List<Categorie>> getCategories() async {
    try {
      final response = await _client.get('/categories');
      final body = _parseBody(response.data);
      final rawList = body['data'];

      if (rawList is List) {
        return rawList
            .map((e) =>
                Categorie.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      return _defaultCategories();
    } catch (e) {
      debugPrint('RemoteArtisteService.getCategories error: $e');
      return _defaultCategories();
    }
  }

  @override
  Future<List<Album>> getAlbumsByArtiste(String artisteId) async {
    try {
      final response = await _client.get('/albums/artiste/$artisteId');
      final body = _parseBody(response.data);
      final rawData = body['data'];
      List items = [];
      if (rawData is Map && rawData['content'] is List) {
        items = rawData['content'] as List;
      } else if (rawData is List) {
        items = rawData;
      }

      return items
          .map((e) => Album.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      debugPrint('RemoteArtisteService.getAlbumsByArtiste error: $e');
      return [];
    }
  }

  @override
  Future<List<Chanson>> getChansonsByArtiste(String artisteId) async {
    try {
      final response = await _client.get('/chansons/artiste/$artisteId');
      final body = _parseBody(response.data);
      final rawData = body['data'];
      List items = [];
      if (rawData is Map && rawData['content'] is List) {
        items = rawData['content'] as List;
      } else if (rawData is List) {
        items = rawData;
      }

      return items
          .map((e) => Chanson.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      debugPrint('RemoteArtisteService.getChansonsByArtiste error: $e');
      return [];
    }
  }

  @override
  Future<String?> creerAlbum({
    required String title,
    DateTime? dateSortie,
    String? artisteId,
    Uint8List? coverBytes,
    String? coverPath,
    String? coverName,
  }) async {
    try {
      final Map<String, dynamic> metadata = {
        'title': title,
        if (dateSortie != null)
          'dateSortie': dateSortie.toIso8601String().split('T').first,
        if (artisteId != null && artisteId.isNotEmpty)
          'artisteId': int.tryParse(artisteId) ?? artisteId,
      };

      final formData = FormData();

      // Part 'data' en application/json
      formData.files.add(MapEntry(
        'data',
        MultipartFile.fromString(
          jsonEncode(metadata),
          contentType: DioMediaType('application', 'json'),
        ),
      ));

      // Part 'cover' (optionnel)
      if (coverBytes != null && coverBytes.isNotEmpty) {
        formData.files.add(MapEntry(
          'cover',
          MultipartFile.fromBytes(
            coverBytes,
            filename: coverName ?? 'cover.jpg',
          ),
        ));
      } else if (coverPath != null && coverPath.isNotEmpty) {
        formData.files.add(MapEntry(
          'cover',
          await MultipartFile.fromFile(
            coverPath,
            filename: coverName ?? coverPath.split(RegExp(r'[\\/]')).last,
          ),
        ));
      }

      final response = await _client.post(
        '/albums/publier',
        data: formData,
      );

      final body = _parseBody(response.data);
      final status = response.statusCode ?? 0;
      if (status >= 200 && status < 300) {
        return null; // succès
      } else {
        return body['message'] as String? ?? 'Erreur lors de la création de l\'album ($status)';
      }
    } catch (e) {
      debugPrint('RemoteArtisteService.creerAlbum error: $e');
      return e.toString().replaceFirst('Exception: ', '');
    }
  }

  @override
  Future<String?> publierChanson({
    required String titre,
    required int duree,
    required String parole,
    required String artisteId,
    required int categorieId,
    int? albumId,
    String? filePath,
    Uint8List? fileBytes,
    String? fileName,
    Uint8List? coverBytes,
    String? coverPath,
    String? coverName,
  }) async {
    try {
      final Map<String, dynamic> metadata = {
        'titre': titre,
        'duree': duree,
        'parole': parole,
        'artisteId': int.tryParse(artisteId) ?? artisteId,
        'categorieId': categorieId,
        'albumId': albumId,
      };

      final formData = FormData();

      // Part 'data' en application/json
      formData.files.add(MapEntry(
        'data',
        MultipartFile.fromString(
          jsonEncode(metadata),
          contentType: DioMediaType('application', 'json'),
        ),
      ));

      // Part 'file' (audio obligatoire)
      if (fileBytes != null && fileBytes.isNotEmpty) {
        formData.files.add(MapEntry(
          'file',
          MultipartFile.fromBytes(
            fileBytes,
            filename: fileName ?? 'chanson.mp3',
          ),
        ));
      } else if (filePath != null && filePath.isNotEmpty) {
        formData.files.add(MapEntry(
          'file',
          await MultipartFile.fromFile(
            filePath,
            filename: fileName ?? filePath.split(RegExp(r'[\\/]')).last,
          ),
        ));
      } else {
        return 'Veuillez sélectionner un fichier audio (.mp3 ou .wav).';
      }

      // Part 'cover' (optionnel)
      if (coverBytes != null && coverBytes.isNotEmpty) {
        formData.files.add(MapEntry(
          'cover',
          MultipartFile.fromBytes(
            coverBytes,
            filename: coverName ?? 'cover.jpg',
          ),
        ));
      } else if (coverPath != null && coverPath.isNotEmpty) {
        formData.files.add(MapEntry(
          'cover',
          await MultipartFile.fromFile(
            coverPath,
            filename: coverName ?? coverPath.split(RegExp(r'[\\/]')).last,
          ),
        ));
      }

      final response = await _client.post(
        '/chansons/publier',
        data: formData,
      );

      final body = _parseBody(response.data);
      final status = response.statusCode ?? 0;
      if (status >= 200 && status < 300) {
        return null; // succès
      } else {
        return body['message'] as String? ?? 'Erreur de publication ($status)';
      }
    } catch (e) {
      debugPrint('RemoteArtisteService.publierChanson error: $e');
      return e.toString().replaceFirst('Exception: ', '');
    }
  }

  Map<String, dynamic> _parseBody(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    if (raw is String) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {}
    }
    return {};
  }

  bool _isSuccess(Map<String, dynamic> body, int? statusCode) {
    final success = body['success'] as bool?;
    if (success != null) return success;
    return (statusCode ?? 0) >= 200 && (statusCode ?? 0) < 300;
  }

  List<Categorie> _defaultCategories() {
    return const [
      Categorie(id: 1, nom: 'Afrobeat'),
      Categorie(id: 2, nom: 'Hip-Hop / Rap'),
      Categorie(id: 3, nom: 'Gospel'),
      Categorie(id: 4, nom: 'Coupé-Décalé'),
      Categorie(id: 5, nom: 'Reggae'),
      Categorie(id: 6, nom: 'R&B / Soul'),
      Categorie(id: 7, nom: 'Pop Africaine'),
      Categorie(id: 8, nom: 'Highlife'),
      Categorie(id: 9, nom: 'Afro-Pop'),
      Categorie(id: 10, nom: 'Musique Traditionnelle'),
    ];
  }
}

class MockArtisteService implements ArtisteService {
  final List<Album> _mockAlbums = [
    Album(
      id: '1',
      title: 'Racines du Golfe',
      artisteId: '2',
      releaseDate: DateTime.now().subtract(const Duration(days: 60)),
      coverUrl: '',
      genres: ['Afrobeat'],
      chansonIds: ['1', '2'],
    ),
    Album(
      id: '2',
      title: 'Lomé By Night',
      artisteId: '2',
      releaseDate: DateTime.now().subtract(const Duration(days: 20)),
      coverUrl: '',
      genres: ['Afro-Pop'],
      chansonIds: ['3'],
    ),
  ];

  @override
  Future<ArtisteDashboardStats?> getDashboard(String artisteId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return ArtisteDashboardStats(
      totalEcoutes: 48290,
      auditeursUniques: 12450,
      totalChansons: 8,
      totalAlbums: _mockAlbums.length,
      totalFavoris: 3420,
      royaltiesEstimees: 145000.0,
      partCatalogue: '3,45%',
    );
  }

  @override
  Future<PageResponse<Reversement>> getReversements(
    String artisteId, {
    int page = 0,
    int size = 10,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final now = DateTime.now();
    return PageResponse<Reversement>(
      content: [
        Reversement(
          id: 1,
          montant: 50000.0,
          datePaiement: now.subtract(const Duration(days: 15)),
          statut: 'SUCCES',
          modePaiement: 'FLOOZ',
          telephone: '+22890123456',
          reference: 'REV-2026-001',
        ),
        Reversement(
          id: 2,
          montant: 95000.0,
          datePaiement: now.subtract(const Duration(days: 45)),
          statut: 'SUCCES',
          modePaiement: 'TMONEY',
          telephone: '+22890123456',
          reference: 'REV-2026-002',
        ),
      ],
      page: 0,
      size: 10,
      totalElements: 2,
      totalPages: 1,
      first: true,
      last: true,
      empty: false,
    );
  }

  @override
  Future<List<Categorie>> getCategories() async {
    return const [
      Categorie(id: 1, nom: 'Afrobeat'),
      Categorie(id: 2, nom: 'Hip-Hop / Rap'),
      Categorie(id: 3, nom: 'Gospel'),
      Categorie(id: 4, nom: 'Coupé-Décalé'),
      Categorie(id: 5, nom: 'R&B / Soul'),
    ];
  }

  @override
  Future<List<Album>> getAlbumsByArtiste(String artisteId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_mockAlbums);
  }

  @override
  Future<List<Chanson>> getChansonsByArtiste(String artisteId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return [];
  }

  @override
  Future<String?> creerAlbum({
    required String title,
    DateTime? dateSortie,
    String? artisteId,
    Uint8List? coverBytes,
    String? coverPath,
    String? coverName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _mockAlbums.add(
      Album(
        id: '${_mockAlbums.length + 1}',
        title: title,
        artisteId: artisteId ?? '2',
        releaseDate: dateSortie ?? DateTime.now(),
        coverUrl: '',
        genres: ['Afrobeat'],
        chansonIds: [],
      ),
    );
    return null;
  }

  @override
  Future<String?> publierChanson({
    required String titre,
    required int duree,
    required String parole,
    required String artisteId,
    required int categorieId,
    int? albumId,
    String? filePath,
    Uint8List? fileBytes,
    String? fileName,
    Uint8List? coverBytes,
    String? coverPath,
    String? coverName,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    return null;
  }
}
