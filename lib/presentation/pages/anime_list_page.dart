import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/anime_list_cubit.dart';
import '../cubits/favorites_cubit.dart';
import '../services/motion_service.dart';
import 'anime_details_page.dart';

enum _ViewMode { list, grid }

class AnimeListPage extends StatefulWidget {
  const AnimeListPage({super.key, required this.isActive});

  final bool isActive;

  @override
  State<AnimeListPage> createState() => _AnimeListPageState();
}

class _AnimeListPageState extends State<AnimeListPage> {
  final _controller = TextEditingController();
  _ViewMode _viewMode = _ViewMode.list;
  MotionService? _motion;

  @override
  void initState() {
    super.initState();

    _motion = MotionService(
      onShake: _openRandom,
      onTiltLeft: () => _setViewMode(_ViewMode.list),
      onTiltRight: () => _setViewMode(_ViewMode.grid),
    );

    if (widget.isActive) {
      _motion?.start();
    }
  }

  @override
  void didUpdateWidget(covariant AnimeListPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive == widget.isActive) return;

    if (widget.isActive) {
      _motion?.start();
    } else {
      _motion?.stop();
    }
  }

  @override
  void dispose() {
    _motion?.stop();
    _controller.dispose();
    super.dispose();
  }

  void _setViewMode(_ViewMode mode) {
    if (_viewMode == mode) return;
    HapticFeedback.selectionClick();
    setState(() => _viewMode = mode);
  }

  void _openRandom() {
    final state = context.read<AnimeListCubit>().state;
    if (state is! AnimeListLoaded || state.items.isEmpty) {
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Brak listy do losowania — najpierw załaduj TOP lub wyszukaj.')),
      );
      return;
    }

    final rnd = math.Random();
    final a = state.items[rnd.nextInt(state.items.length)];
    HapticFeedback.mediumImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AnimeDetailsPage(animeId: a.id, title: a.title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anime Explorer'),
        actions: [
          IconButton(
            tooltip: _viewMode == _ViewMode.list ? 'Widok siatki (przechyl w prawo)' : 'Widok listy (przechyl w lewo)',
            icon: Icon(_viewMode == _ViewMode.list ? Icons.grid_view : Icons.view_list),
            onPressed: () => _setViewMode(_viewMode == _ViewMode.list ? _ViewMode.grid : _ViewMode.list),
          ),
          IconButton(
            tooltip: 'Losowe anime (potrząśnij telefonem)',
            icon: const Icon(Icons.casino),
            onPressed: _openRandom,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Szukaj anime (np. Naruto)',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => context.read<AnimeListCubit>().search(_controller.text),
                ),
              ),
              onSubmitted: (v) => context.read<AnimeListCubit>().search(v),
            ),
          ),
          Expanded(
            child: BlocBuilder<AnimeListCubit, AnimeListState>(
              builder: (context, state) {
                if (state is AnimeListLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is AnimeListError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(state.message, textAlign: TextAlign.center),
                    ),
                  );
                }
                if (state is AnimeListLoaded) {
                  if (state.items.isEmpty) {
                    return const Center(child: Text('Brak wyników.'));
                  }

                  return _viewMode == _ViewMode.list
                      ? _buildList(state)
                      : _buildGrid(state);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.read<AnimeListCubit>().loadTop(),
        icon: const Icon(Icons.star),
        label: const Text('TOP'),
      ),
    );
  }

  Widget _buildList(AnimeListLoaded state) {
    return ListView.separated(
      itemCount: state.items.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final a = state.items[i];
        return BlocBuilder<FavoritesCubit, FavoritesState>(
          builder: (context, favState) {
            final isFav = context.read<FavoritesCubit>().isFavorite(a.id);
            return ListTile(
              leading: a.imageUrl.isEmpty
                  ? const SizedBox(width: 50, height: 70)
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(a.imageUrl, width: 50, height: 70, fit: BoxFit.cover),
                    ),
              title: Text(a.title, maxLines: 2, overflow: TextOverflow.ellipsis),
              subtitle: Text(a.score == null ? 'Brak oceny' : 'Score: ${a.score}'),
              trailing: IconButton(
                icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
                onPressed: () {
                  HapticFeedback.selectionClick();
                  context.read<FavoritesCubit>().toggle(a.id);
                },
              ),
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AnimeDetailsPage(animeId: a.id, title: a.title),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildGrid(AnimeListLoaded state) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemCount: state.items.length,
      itemBuilder: (context, i) {
        final a = state.items[i];
        final isFav = context.read<FavoritesCubit>().isFavorite(a.id);

        return InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AnimeDetailsPage(animeId: a.id, title: a.title),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: a.imageUrl.isEmpty
                      ? const SizedBox.shrink()
                      : Image.network(a.imageUrl, fit: BoxFit.cover),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              a.score == null ? 'Brak oceny' : 'Score: ${a.score}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
                            onPressed: () {
                              HapticFeedback.selectionClick();
                              context.read<FavoritesCubit>().toggle(a.id);
                              setState(() {}); // reflect icon instantly in grid
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
