import '../entities/anime.dart';

abstract class AnimeRepository {
  Future<List<Anime>> getTopAnime({int page = 1});
  Future<List<Anime>> searchAnime(String query, {int page = 1});
  Future<Anime> getAnimeDetails(int id);
}
