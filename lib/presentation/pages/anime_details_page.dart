import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';

import '../../domain/repositories/anime_repository.dart';
import '../cubits/anime_details_cubit.dart';
import '../cubits/favorites_cubit.dart';

class AnimeDetailsPage extends StatelessWidget {
  final int animeId;
  final String title;

  const AnimeDetailsPage({
    super.key,
    required this.animeId,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (ctx) => AnimeDetailsCubit(ctx.read<AnimeRepository>())..load(animeId),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          actions: [
            BlocBuilder<FavoritesCubit, FavoritesState>(
              builder: (context, state) {
                final isFav = context.read<FavoritesCubit>().isFavorite(animeId);
                return IconButton(
                  icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    context.read<FavoritesCubit>().toggle(animeId);
                  },
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<AnimeDetailsCubit, AnimeDetailsState>(
          builder: (context, state) {
            if (state is AnimeDetailsLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is AnimeDetailsError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(state.message, textAlign: TextAlign.center),
                ),
              );
            }
            if (state is AnimeDetailsLoaded) {
              final a = state.anime;
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (a.imageUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(a.imageUrl, height: 260, fit: BoxFit.cover),
                    ),
                  const SizedBox(height: 12),
                  Text(a.title, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text('Score: ${a.score ?? "-"}'),
                  Text('Odcinki: ${a.episodes ?? "-"}'),
                  Text('Status: ${a.status ?? "-"}'),
                  const SizedBox(height: 12),
                  Text(a.synopsis?.trim().isNotEmpty == true ? a.synopsis! : 'Brak opisu.'),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
