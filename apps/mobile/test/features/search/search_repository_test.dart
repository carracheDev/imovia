import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imovia_mobile/core/network/api_client.dart';
import 'package:imovia_mobile/features/search/data/search_repository.dart';
import 'package:imovia_mobile/features/search/domain/search_criteria.dart';

void main() {
  test('loads child localities from the internal locations API', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test/api/'));
    late RequestOptions requested;
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requested = options;
          handler.resolve(
            Response<List<Map<String, dynamic>>>(
              requestOptions: options,
              statusCode: 200,
              data: [
                {
                  'id': 'commune-cotonou',
                  'name': 'Cotonou',
                  'slug': 'cotonou',
                  'level': 'COMMUNE',
                  'parentId': 'department-littoral',
                },
              ],
            ),
          );
        },
      ),
    );
    final repository = RemoteSearchRepository(ApiClient(dio));

    final locations = await repository.loadLocations(
      parentId: 'department-littoral',
    );

    expect(requested.uri.path, '/api/locations');
    expect(requested.queryParameters, {'parentId': 'department-littoral'});
    expect(locations.single.name, 'Cotonou');
    expect(locations.single.level, 'COMMUNE');
    dio.close(force: true);
  });

  test('searches localities and reads their administrative path', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test/api/'));
    late RequestOptions requested;
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requested = options;
          handler.resolve(
            Response<List<Map<String, dynamic>>>(
              requestOptions: options,
              statusCode: 200,
              data: [
                {
                  'id': 'neighborhood-fidjrosse',
                  'name': 'Fidjrossè',
                  'level': 'NEIGHBORHOOD',
                  'parentId': 'arrondissement-12',
                  'path': 'Littoral · Cotonou · 12e arrondissement · Fidjrossè',
                },
              ],
            ),
          );
        },
      ),
    );
    final repository = RemoteSearchRepository(ApiClient(dio));

    final locations = await repository.searchLocations('fidj');

    expect(requested.uri.path, '/api/locations/search');
    expect(requested.queryParameters, {'q': 'fidj'});
    expect(locations.single.name, 'Fidjrossè');
    expect(locations.single.path, contains('Cotonou'));
    dio.close(force: true);
  });

  test('counts search matches with supported criteria from the API', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test/api/'));
    late RequestOptions requested;
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requested = options;
          handler.resolve(
            Response<Map<String, dynamic>>(
              requestOptions: options,
              statusCode: 200,
              data: {
                'items': [],
                'pagination': {
                  'page': 1,
                  'pageSize': 1,
                  'total': 7,
                  'totalPages': 7,
                },
              },
            ),
          );
        },
      ),
    );
    final repository = RemoteSearchRepository(ApiClient(dio));

    final count = await repository.countResults(
      const SearchCriteria(
        query: 'Cotonou',
        operationType: 'RENT',
        category: 'APARTMENT',
        locationId: 'commune-cotonou',
        priceMin: '50000',
        priceMax: '300000',
      ),
    );

    expect(count, 7);
    expect(requested.uri.path, '/api/properties');
    expect(requested.queryParameters, {
      'q': 'Cotonou',
      'operationType': 'RENT',
      'category': 'APARTMENT',
      'locationId': 'commune-cotonou',
      'priceMin': '50000',
      'priceMax': '300000',
      'page': 1,
      'pageSize': 1,
    });
    dio.close(force: true);
  });

  test('loads a paginated API result page with the active filters', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test/api/'));
    late RequestOptions requested;
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requested = options;
          handler.resolve(
            Response<Map<String, dynamic>>(
              requestOptions: options,
              statusCode: 200,
              data: {
                'items': [
                  {
                    'id': 'property-1',
                    'slug': 'villa-cotonou',
                    'title': 'Villa à Cotonou',
                    'category': 'VILLA',
                    'operationType': 'SALE',
                    'price': '45000000',
                    'currency': 'XOF',
                    'location': {'id': 'commune-cotonou', 'name': 'Cotonou'},
                    'media': [],
                  },
                ],
                'pagination': {
                  'page': 2,
                  'pageSize': 10,
                  'total': 11,
                  'totalPages': 2,
                },
              },
            ),
          );
        },
      ),
    );
    final repository = RemoteSearchRepository(ApiClient(dio));

    final result = await repository.loadResults(
      const SearchCriteria(operationType: 'SALE', category: 'VILLA'),
      page: 2,
    );

    expect(requested.uri.path, '/api/properties');
    expect(requested.queryParameters, {
      'operationType': 'SALE',
      'category': 'VILLA',
      'page': 2,
      'pageSize': 10,
    });
    expect(result.items.single.title, 'Villa à Cotonou');
    expect(result.total, 11);
    expect(result.page, 2);
    expect(result.totalPages, 2);
    dio.close(force: true);
  });
}
