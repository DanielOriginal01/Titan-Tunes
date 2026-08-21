import 'package:flutter/material.dart';
import 'package:titan_tunes/data/models/chanson.dart';
import 'package:titan_tunes/data/repositories/music_api_repository.dart';

class MusicApiProvider extends ChangeNotifier {
  final MusicApiRepository repository;

  MusicApiProvider({required this.repository});

  List<Chanson> trendingSongs = [];
  bool isLoading = false;
  String? error;

  Future<void> loadTrendingSongs() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      trendingSongs = await repository.fetchTrendingSongs();
    } catch (e) {
      error = e.toString();
      trendingSongs = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
