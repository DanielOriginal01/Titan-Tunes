import 'package:titan_tunes/data/models/chanson.dart';

class HistoryItem {
  final String id;
  final Chanson chanson;
  final DateTime playedAt;

  const HistoryItem({
    required this.id,
    required this.chanson,
    required this.playedAt,
  });
}