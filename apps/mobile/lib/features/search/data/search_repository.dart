import '../../../core/network/api_client.dart';
import '../../home/data/home_repository.dart';
import '../domain/search_criteria.dart';

class SearchResultsPage {
  const SearchResultsPage({
    required this.items,
    required this.total,
    required this.page,
    required this.totalPages,
  });

  final List<HomeProperty> items;
  final int total;
  final int page;
  final int totalPages;
}

class SearchLocation {
  const SearchLocation({
    required this.id,
    required this.name,
    required this.level,
    this.parentId,
    this.path,
  });

  final String id;
  final String name;
  final String level;
  final String? parentId;
  final String? path;

  factory SearchLocation.fromJson(Map<String, dynamic> json) => SearchLocation(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    level: json['level'] as String? ?? '',
    parentId: json['parentId'] as String?,
    path: json['path'] as String?,
  );
}

abstract interface class SearchRepository {
  Future<List<SearchLocation>> loadLocations({String? parentId});
  Future<List<SearchLocation>> searchLocations(String query);
  Future<int> countResults(SearchCriteria criteria);
  Future<SearchResultsPage> loadResults(
    SearchCriteria criteria, {
    required int page,
    int pageSize = 10,
  });
}

class RemoteSearchRepository implements SearchRepository {
  const RemoteSearchRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<SearchLocation>> loadLocations({String? parentId}) async {
    final data = await _apiClient.getJsonList(
      'locations',
      queryParameters: parentId == null ? null : {'parentId': parentId},
    );
    return data.map(SearchLocation.fromJson).toList(growable: false);
  }

  @override
  Future<List<SearchLocation>> searchLocations(String query) async {
    final data = await _apiClient.getJsonList(
      'locations/search',
      queryParameters: {'q': query},
    );
    return data.map(SearchLocation.fromJson).toList(growable: false);
  }

  @override
  Future<int> countResults(SearchCriteria criteria) async {
    final response = await _apiClient.getJson(
      'properties',
      queryParameters: criteria.toApiQueryParameters(),
    );
    final pagination = response['pagination'];
    final total = pagination is Map<String, dynamic>
        ? pagination['total']
        : null;
    if (total is int && total >= 0) return total;
    throw const ApiException('The API returned an invalid result count.');
  }

  @override
  Future<SearchResultsPage> loadResults(
    SearchCriteria criteria, {
    required int page,
    int pageSize = 10,
  }) async {
    final response = await _apiClient.getJson(
      'properties',
      queryParameters: {
        ...criteria.toApiQueryParameters(),
        'page': page,
        'pageSize': pageSize,
      },
    );
    final rawItems = response['items'];
    final pagination = response['pagination'];
    if (rawItems is! List ||
        !rawItems.every((item) => item is Map<String, dynamic>) ||
        pagination is! Map<String, dynamic>) {
      throw const ApiException('The API returned an invalid result page.');
    }
    final total = pagination['total'];
    final currentPage = pagination['page'];
    final totalPages = pagination['totalPages'];
    if (total is! int || currentPage is! int || totalPages is! int) {
      throw const ApiException('The API returned invalid pagination data.');
    }
    return SearchResultsPage(
      items: rawItems
          .cast<Map<String, dynamic>>()
          .map(HomeProperty.fromJson)
          .toList(growable: false),
      total: total,
      page: currentPage,
      totalPages: totalPages,
    );
  }
}
