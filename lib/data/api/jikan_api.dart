import 'package:dio/dio.dart';

class JikanApi {
  final Dio _dio;

  JikanApi(Dio dio)
      : _dio = dio
    ..options = BaseOptions(
      baseUrl: 'https://api.jikan.moe/v4',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
    );

  Future<Map<String, dynamic>> getTopAnime({int page = 1}) async {
    final res = await _dio.get('/top/anime', queryParameters: {'page': page});
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> searchAnime(String query, {int page = 1}) async {
    final res = await _dio.get('/anime', queryParameters: {'q': query, 'page': page});
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getAnimeDetails(int id) async {
    final res = await _dio.get('/anime/$id');
    return res.data as Map<String, dynamic>;
  }
}
