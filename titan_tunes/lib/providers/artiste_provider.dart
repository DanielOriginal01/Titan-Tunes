import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:titan_tunes/data/models/album.dart';
import 'package:titan_tunes/data/models/artiste_dashboard.dart';
import 'package:titan_tunes/data/models/categorie.dart';
import 'package:titan_tunes/data/models/chanson.dart';
import 'package:titan_tunes/data/models/reversement.dart';
import 'package:titan_tunes/data/services/artiste_service.dart';

class ArtisteProvider extends ChangeNotifier {
  final ArtisteService _service;

  ArtisteDashboardStats? _stats;
  List<Reversement> _reversements = [];
  List<Categorie> _categories = [];
  List<Album> _albums = [];
  List<Chanson> _chansons = [];
  bool _isLoadingStats = false;
  bool _isLoadingReversements = false;
  bool _isLoadingAlbums = false;
  bool _isLoadingChansons = false;
  bool _isPublishing = false;
  bool _isCreatingAlbum = false;
  String? _publishError;
  String? _albumError;

  ArtisteProvider({required ArtisteService service}) : _service = service;

  ArtisteDashboardStats? get stats => _stats;
  List<Reversement> get reversements => List.unmodifiable(_reversements);
  List<Categorie> get categories => List.unmodifiable(_categories);
  List<Album> get albums => List.unmodifiable(_albums);
  List<Chanson> get chansons => List.unmodifiable(_chansons);
  bool get isLoadingStats => _isLoadingStats;
  bool get isLoadingReversements => _isLoadingReversements;
  bool get isLoadingAlbums => _isLoadingAlbums;
  bool get isLoadingChansons => _isLoadingChansons;
  bool get isPublishing => _isPublishing;
  bool get isCreatingAlbum => _isCreatingAlbum;
  String? get publishError => _publishError;
  String? get albumError => _albumError;

  Future<void> loadDashboard(String artisteId) async {
    _isLoadingStats = true;
    notifyListeners();

    try {
      _stats = await _service.getDashboard(artisteId);
    } catch (e) {
      debugPrint('ArtisteProvider.loadDashboard error: $e');
    } finally {
      _isLoadingStats = false;
      notifyListeners();
    }
  }

  Future<void> loadReversements(String artisteId, {int page = 0, int size = 10}) async {
    _isLoadingReversements = true;
    notifyListeners();

    try {
      final pageRes = await _service.getReversements(artisteId, page: page, size: size);
      _reversements = pageRes.content;
    } catch (e) {
      debugPrint('ArtisteProvider.loadReversements error: $e');
    } finally {
      _isLoadingReversements = false;
      notifyListeners();
    }
  }

  Future<void> loadCategories() async {
    try {
      _categories = await _service.getCategories();
      notifyListeners();
    } catch (e) {
      debugPrint('ArtisteProvider.loadCategories error: $e');
    }
  }

  Future<void> loadAlbums(String artisteId) async {
    _isLoadingAlbums = true;
    notifyListeners();

    try {
      _albums = await _service.getAlbumsByArtiste(artisteId);
    } catch (e) {
      debugPrint('ArtisteProvider.loadAlbums error: $e');
    } finally {
      _isLoadingAlbums = false;
      notifyListeners();
    }
  }

  Future<void> loadChansons(String artisteId) async {
    _isLoadingChansons = true;
    notifyListeners();

    try {
      _chansons = await _service.getChansonsByArtiste(artisteId);
    } catch (e) {
      debugPrint('ArtisteProvider.loadChansons error: $e');
    } finally {
      _isLoadingChansons = false;
      notifyListeners();
    }
  }

  Future<bool> creerAlbum({
    required String title,
    DateTime? dateSortie,
    String? artisteId,
    Uint8List? coverBytes,
    String? coverPath,
    String? coverName,
  }) async {
    _isCreatingAlbum = true;
    _albumError = null;
    notifyListeners();

    try {
      final err = await _service.creerAlbum(
        title: title,
        dateSortie: dateSortie,
        artisteId: artisteId,
        coverBytes: coverBytes,
        coverPath: coverPath,
        coverName: coverName,
      );

      _isCreatingAlbum = false;
      if (err != null) {
        _albumError = err;
        notifyListeners();
        return false;
      }

      if (artisteId != null && artisteId.isNotEmpty) {
        await loadAlbums(artisteId);
        await loadDashboard(artisteId);
      }
      notifyListeners();
      return true;
    } catch (e) {
      _albumError = e.toString().replaceFirst('Exception: ', '');
      _isCreatingAlbum = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> publierChanson({
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
    _isPublishing = true;
    _publishError = null;
    notifyListeners();

    try {
      final err = await _service.publierChanson(
        titre: titre,
        duree: duree,
        parole: parole,
        artisteId: artisteId,
        categorieId: categorieId,
        albumId: albumId,
        filePath: filePath,
        fileBytes: fileBytes,
        fileName: fileName,
        coverBytes: coverBytes,
        coverPath: coverPath,
        coverName: coverName,
      );

      _isPublishing = false;
      if (err != null) {
        _publishError = err;
        notifyListeners();
        return false;
      }

      // Recharger le dashboard après publication réussie
      await loadDashboard(artisteId);
      if (albumId != null) {
        await loadAlbums(artisteId);
      }
      notifyListeners();
      return true;
    } catch (e) {
      _publishError = e.toString().replaceFirst('Exception: ', '');
      _isPublishing = false;
      notifyListeners();
      return false;
    }
  }
}
