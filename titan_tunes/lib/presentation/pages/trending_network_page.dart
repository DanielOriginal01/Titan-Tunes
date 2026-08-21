import 'package:flutter/material.dart';
import 'package:titan_tunes/data/models/chanson.dart';
import 'package:titan_tunes/data/repositories/music_api_repository.dart';

class TrendingNetworkPage extends StatefulWidget {
  final MusicApiRepository repository;

  const TrendingNetworkPage({super.key, required this.repository});

  @override
  State<TrendingNetworkPage> createState() => _TrendingNetworkPageState();
}

class _TrendingNetworkPageState extends State<TrendingNetworkPage> {
  late Future<List<Chanson>> _songsFuture;

  @override
  void initState() {
    super.initState();
    _songsFuture = widget.repository.fetchTrendingSongs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tendances Titan Tunes')),
      body: FutureBuilder<List<Chanson>>(
        future: _songsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Erreur : ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final chansons = snapshot.data ?? [];
          if (chansons.isEmpty) {
            return const Center(child: Text('Aucun titre disponible.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: chansons.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final chanson = chansons[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    chanson.coverUrl,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 56,
                      height: 56,
                      color: Theme.of(context).dividerColor,
                      child: const Icon(Icons.music_note),
                    ),
                  ),
                ),
                title: Text(chanson.title),
                subtitle: Text('${chanson.popularity}% popularité'),
                trailing: IconButton(
                  icon: const Icon(Icons.play_circle_fill),
                  onPressed: () => debugPrint('Lire ${chanson.title}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
