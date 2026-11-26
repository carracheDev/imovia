import '../../../core/network/api_client.dart';
import '../../home/data/home_repository.dart';

class FavoritePage {
  const FavoritePage({required this.items, required this.totalPages});
  final List<HomeProperty> items;
  final int totalPages;
}

abstract interface class FavoritesRepository {
  Future<FavoritePage> load({int page = 1, int pageSize = 20});
  Future<void> add(String propertyId);
  Future<void> remove(String propertyId);
}

class RemoteFavoritesRepository implements FavoritesRepository {
  const RemoteFavoritesRepository(this._api);
  final ApiClient _api;

  @override
  Future<FavoritePage> load({int page = 1, int pageSize = 20}) async {
    final response = await _api.getJson(
      'users/me/favorites',
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    final rawItems = response['items'];
    final pagination = response['pagination'];
    if (rawItems is! List ||
        !rawItems.every((item) => item is Map<String, dynamic>) ||
        pagination is! Map<String, dynamic> ||
        pagination['totalPages'] is! int) {
      throw const ApiException('The API returned an invalid favorites list.');
    }
    return FavoritePage(
      items: rawItems
          .cast<Map<String, dynamic>>()
          .map(HomeProperty.fromJson)
          .toList(growable: false),
      totalPages: pagination['totalPages'] as int,
    );
  }

  @override
  Future<void> add(String propertyId) async {
    await _api.postJson(
      'users/me/favorites/${Uri.encodeComponent(propertyId)}',
    );
  }

  @override
  Future<void> remove(String propertyId) async {
    await _api.delete('users/me/favorites/${Uri.encodeComponent(propertyId)}');
  }
}
