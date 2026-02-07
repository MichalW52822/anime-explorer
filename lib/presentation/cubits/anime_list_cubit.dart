import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/anime.dart';
import '../../domain/repositories/anime_repository.dart';

sealed class AnimeListState extends Equatable {
  const AnimeListState();
  @override
  List<Object?> get props => [];
}

class AnimeListLoading extends AnimeListState {
  const AnimeListLoading();
}

class AnimeListLoaded extends AnimeListState {
  final List<Anime> items;
  final bool isSearch;
  final String query;

  const AnimeListLoaded({
    required this.items,
    required this.isSearch,
    required this.query,
  });

  @override
  List<Object?> get props => [items, isSearch, query];
}

class AnimeListError extends AnimeListState {
  final String message;
  const AnimeListError(this.message);

  @override
  List<Object?> get props => [message];
}

class AnimeListCubit extends Cubit<AnimeListState> {
  final AnimeRepository repo;

  AnimeListCubit(this.repo) : super(const AnimeListLoading());

  Future<void> loadTop() async {
    emit(const AnimeListLoading());
    try {
      final items = await repo.getTopAnime(page: 1);
      emit(AnimeListLoaded(items: items, isSearch: false, query: ''));
    } catch (e) {
      emit(AnimeListError('Błąd pobierania TOP anime: $e'));
    }
  }

  Future<void> search(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      await loadTop();
      return;
    }
    emit(const AnimeListLoading());
    try {
      final items = await repo.searchAnime(q, page: 1);
      emit(AnimeListLoaded(items: items, isSearch: true, query: q));
    } catch (e) {
      emit(AnimeListError('Błąd wyszukiwania: $e'));
    }
  }
}
