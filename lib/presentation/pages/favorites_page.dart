import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/anime_repository.dart';
import '../cubits/favorites_cubit.dart';
import 'anime_details_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  bool _loadingDetails = false;
  final Map<int, _FavAnimePreview> _cache = {};

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final ids = context.read<FavoritesCubit>().state.ids.toList();
    if (ids.isEmpty) return;

    setState(() => _loadingDetails = true);
    final repo = context.read<AnimeRepository>();

    for (final id in ids) {
      if (_cache.containsKey(id)) continue;
      try {
        final a = await repo.getAnimeDetails(id);
        _cache[id] = _FavAnimePreview(id: id, title: a.title, imageUrl: a.imageUrl);
      } catch (_) {
        _cache[id] = _FavAnimePreview(id: id, title: 'Anime #$id', imageUrl: '');
      }
    }

    setState(() => _loadingDetails = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ulubione'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: BlocConsumer<FavoritesCubit, FavoritesState>(
        listener: (_, __) => _refresh(),
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          final ids = state.ids.toList();
          if (ids.isEmpty) {
            return const Center(child: Text('Brak ulubionych. Dodaj serduszkiem ❤️'));
          }

          if (_loadingDetails) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.separated(
            itemCount: ids.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final id = ids[i];
              final preview = _cache[id] ?? _FavAnimePreview(id: id, title: 'Anime #$id', imageUrl: '');

              return ListTile(
                leading: preview.imageUrl.isEmpty
                    ? const SizedBox(width: 50, height: 70)
                    : ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(preview.imageUrl, width: 50, height: 70, fit: BoxFit.cover),
                ),
                title: Text(preview.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => context.read<FavoritesCubit>().toggle(id),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AnimeDetailsPage(animeId: id, title: preview.title),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _FavAnimePreview {
  final int id;
  final String title;
  final String imageUrl;

  _FavAnimePreview({
    required this.id,
    required this.title,
    required this.imageUrl,
  });
}
