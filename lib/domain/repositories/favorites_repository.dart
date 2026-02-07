abstract class FavoritesRepository {
  Future<Set<int>> loadFavoriteIds();
  Future<void> saveFavoriteIds(Set<int> ids);
}
