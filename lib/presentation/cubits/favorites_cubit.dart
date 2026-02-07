import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/favorites_repository.dart';

class FavoritesState extends Equatable {
  final Set<int> ids;
  final bool loading;

  const FavoritesState({
    required this.ids,
    required this.loading,
  });

  factory FavoritesState.initial() => const FavoritesState(ids: <int>{}, loading: true);

  @override
  List<Object?> get props => [ids, loading];
}

class FavoritesCubit extends Cubit<FavoritesState> {
  final FavoritesRepository repo;

  FavoritesCubit(this.repo) : super(FavoritesState.initial());

  Future<void> load() async {
    emit(FavoritesState(ids: state.ids, loading: true));
    final ids = await repo.loadFavoriteIds();
    emit(FavoritesState(ids: ids, loading: false));
  }

  Future<void> toggle(int animeId) async {
    final next = Set<int>.from(state.ids);
    if (next.contains(animeId)) {
      next.remove(animeId);
    } else {
      next.add(animeId);
    }
    emit(FavoritesState(ids: next, loading: false));
    await repo.saveFavoriteIds(next);
  }

  bool isFavorite(int id) => state.ids.contains(id);
}
