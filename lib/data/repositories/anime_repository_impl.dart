import '../../domain/entities/anime.dart';
import '../../domain/repositories/anime_repository.dart';
import '../api/jikan_api.dart';
import '../models/anime_dto.dart';

class AnimeRepositoryImpl implements AnimeRepository {
  final JikanApi api;

  AnimeRepositoryImpl(this.api);

  @override
  Future<List<Anime>> getTopAnime({int page = 1}) async {
    final json = await api.getTopAnime(page: page);
    final data = (json['data'] as List<dynamic>? ?? []);
    return data
        .map((e) => AnimeDto.fromJson(e as Map<String, dynamic>).toEntity())
        .toList();
  }

  @override
  Future<List<Anime>> searchAnime(String query, {int page = 1}) async {
    final json = await api.searchAnime(query, page: page);
    final data = (json['data'] as List<dynamic>? ?? []);
    return data
        .map((e) => AnimeDto.fromJson(e as Map<String, dynamic>).toEntity())
        .toList();
  }

  @override
  Future<Anime> getAnimeDetails(int id) async {
    final json = await api.getAnimeDetails(id);
    final data = (json['data'] as Map<String, dynamic>);
    return AnimeDto.fromJson(data).toEntity();
  }
}
