import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imovia_mobile/core/network/api_client.dart';
import 'package:imovia_mobile/features/properties/data/favorites_repository.dart';

void main() {
  test('loads the authenticated favorite list and maps its property', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test/api/'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) => handler.resolve(
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
                  'operationType': 'RENT',
                  'price': '250000',
                  'currency': 'XOF',
                  'location': {'name': 'Cotonou'},
                  'media': [
                    {'id': 'media-1', 'isCover': true},
                  ],
                },
              ],
              'pagination': {
                'page': 1,
                'pageSize': 20,
                'total': 1,
                'totalPages': 1,
              },
            },
          ),
        ),
      ),
    );
    final repository = RemoteFavoritesRepository(ApiClient(dio));

    final page = await repository.load();

    expect(page.totalPages, 1);
    expect(page.items.single.title, 'Villa à Cotonou');
    expect(page.items.single.coverMediaId, 'media-1');
    dio.close(force: true);
  });

  test(
    'adds and removes a favorite through the authenticated API routes',
    () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test/api/'));
      final requestedMethods = <String>[];
      final requestedPaths = <String>[];
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requestedMethods.add(options.method);
            requestedPaths.add(options.uri.path);
            handler.resolve(
              Response<Map<String, dynamic>>(
                requestOptions: options,
                statusCode: 200,
                data: const {},
              ),
            );
          },
        ),
      );
      final repository = RemoteFavoritesRepository(ApiClient(dio));

      await repository.add('property-1');
      await repository.remove('property-1');

      expect(requestedMethods, ['POST', 'DELETE']);
      expect(requestedPaths, [
        '/api/users/me/favorites/property-1',
        '/api/users/me/favorites/property-1',
      ]);
      dio.close(force: true);
    },
  );
}
