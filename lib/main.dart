import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'data/api/jikan_api.dart';
import 'data/repositories/anime_repository_impl.dart';
import 'data/repositories/favorites_repository_impl.dart';

import 'domain/repositories/anime_repository.dart';
import 'domain/repositories/favorites_repository.dart';

import 'presentation/cubits/anime_list_cubit.dart';
import 'presentation/cubits/favorites_cubit.dart';
import 'presentation/pages/app_shell.dart';

void main() {
  final dio = Dio();
  final api = JikanApi(dio);

  final animeRepo = AnimeRepositoryImpl(api);
  final favoritesRepo = FavoritesRepositoryImpl();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AnimeRepository>.value(value: animeRepo),
        RepositoryProvider<FavoritesRepository>.value(value: favoritesRepo),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
            AnimeListCubit(context.read<AnimeRepository>())..loadTop(),
          ),
          BlocProvider(
            create: (context) =>
            FavoritesCubit(context.read<FavoritesRepository>())..load(),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Anime Explorer',
      theme: ThemeData(useMaterial3: true),
      home: const AppShell(),
    );
  }
}
