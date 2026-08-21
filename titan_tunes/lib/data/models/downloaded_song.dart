import 'package:titan_tunes/data/models/chanson.dart';

class DownloadedSong {
  final Chanson chanson;
  final String localPath;
  final DateTime downloadedAt;
  final double sizeInMb;

  const DownloadedSong({
    required this.chanson,
    required this.localPath,
    required this.downloadedAt,
    required this.sizeInMb,
  });
}