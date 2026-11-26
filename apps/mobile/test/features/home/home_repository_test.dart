import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imovia_mobile/core/network/api_client.dart';
import 'package:imovia_mobile/features/home/data/home_repository.dart';

void main() {
  test('loads four recent public properties from the MVP API', () async {
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
                    'id': 'p-1',
                    'slug': 'villa-cotonou',
                    'title': 'Villa à Cotonou',
                    'category': 'VILLA',
                    'operationType': 'RENT',
                    'price': '250000',
                    'currency': 'XOF',
                    'location': {'id': 'loc-1', 'name': 'Cotonou'},
                    'media': [
                      {'id': 'm-1', 'isCover': true, 'position': 0},
                    ],
                  },
                ],
                'pagination': {
                  'page': 1,
                  'pageSize': 4,
                  'total': 1,
                  'totalPages': 1,
                },
              },
            ),
          );
        },
      ),
    );
    final repository = RemoteHomeRepository(ApiClient(dio));

    final properties = await repository.loadRecent();

    expect(requested.uri.path, '/api/properties');
    expect(requested.queryParameters, {'page': 1, 'pageSize': 4});
    expect(properties.single.title, 'Villa à Cotonou');
    expect(properties.single.coverMediaId, 'm-1');
    dio.close(force: true);
  });

  test('requests a signed URL for the API-approved cover media', () async {
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
              data: {'url': 'https://images.example.test/signed.jpg'},
            ),
          );
        },
      ),
    );
    final repository = RemoteHomeRepository(ApiClient(dio));

    final url = await repository.loadMediaUrl(
      const PropertyMediaRef(slug: 'villa-cotonou', mediaId: 'm-1'),
    );

    expect(requested.uri.path, '/api/properties/villa-cotonou/media/m-1');
    expect(url, 'https://images.example.test/signed.jpg');
    dio.close(force: true);
  });
}
