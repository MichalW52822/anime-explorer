import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/anime_repository.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../cubits/anime_list_cubit.dart';
import '../cubits/favorites_cubit.dart';
import 'anime_list_page.dart';
import 'favorites_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final animeRepo = context.read<AnimeRepository>();
    final favRepo = context.read<FavoritesRepository>();

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AnimeListCubit(animeRepo)..loadTop()),
        BlocProvider(create: (_) => FavoritesCubit(favRepo)..load()),
      ],
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: [
            AnimeListPage(isActive: _index == 0),
            const FavoritesPage(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.star), label: 'Top/Szukaj'),
            NavigationDestination(icon: Icon(Icons.favorite), label: 'Ulubione'),
          ],
        ),
      ),
    );
  }
}
