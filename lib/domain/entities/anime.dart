import 'package:equatable/equatable.dart';

class Anime extends Equatable {
  final int id;
  final String title;
  final String imageUrl;
  final double? score;

  final String? synopsis;
  final int? episodes;
  final String? status;

  const Anime({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.score,
    this.synopsis,
    this.episodes,
    this.status,
  });

  @override
  List<Object?> get props => [id, title, imageUrl, score, synopsis, episodes, status];
}
