import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/anime.dart';
import '../../domain/repositories/anime_repository.dart';

sealed class AnimeDetailsState extends Equatable {
  const AnimeDetailsState();
  @override
  List<Object?> get props => [];
}

class AnimeDetailsLoading extends AnimeDetailsState {
  const AnimeDetailsLoading();
}

class AnimeDetailsLoaded extends AnimeDetailsState {
  final Anime anime;
  const AnimeDetailsLoaded(this.anime);

  @override
  List<Object?> get props => [anime];
}

class AnimeDetailsError extends AnimeDetailsState {
  final String message;
  const AnimeDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}

class AnimeDetailsCubit extends Cubit<AnimeDetailsState> {
  final AnimeRepository repo;

  AnimeDetailsCubit(this.repo) : super(const AnimeDetailsLoading());

  Future<void> load(int id) async {
    emit(const AnimeDetailsLoading());
    try {
      final anime = await repo.getAnimeDetails(id);
      emit(AnimeDetailsLoaded(anime));
    } catch (e) {
      emit(AnimeDetailsError('Nie udało się pobrać szczegółów: $e'));
    }
  }
}
