import '../../domain/entities/anime.dart';

class AnimeDto {
  final int id;
  final String title;
  final String imageUrl;
  final double? score;

  final String? synopsis;
  final int? episodes;
  final String? status;

  AnimeDto({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.score,
    this.synopsis,
    this.episodes,
    this.status,
  });

  factory AnimeDto.fromJson(Map<String, dynamic> json) {
    final images = json['images'] as Map<String, dynamic>?;
    final jpg = images?['jpg'] as Map<String, dynamic>?;
    final img = (jpg?['image_url'] as String?) ?? '';

    return AnimeDto(
      id: (json['mal_id'] as num).toInt(),
      title: (json['title'] as String?) ?? 'Unknown',
      imageUrl: img,
      score: (json['score'] as num?)?.toDouble(),
      synopsis: json['synopsis'] as String?,
      episodes: (json['episodes'] as num?)?.toInt(),
      status: json['status'] as String?,
    );
  }

  Anime toEntity() => Anime(
    id: id,
    title: title,
    imageUrl: imageUrl,
    score: score,
    synopsis: synopsis,
    episodes: episodes,
    status: status,
  );
}
