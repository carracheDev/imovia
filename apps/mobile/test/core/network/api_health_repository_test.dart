import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imovia_mobile/core/network/api_client.dart';
import 'package:imovia_mobile/features/foundation/data/api_health_repository.dart';

void main() {
  test('reads the API and database health response', () async {
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
              data: {'status': 'ok', 'database': 'connected'},
            ),
          );
        },
      ),
    );
    final repository = RemoteApiHealthRepository(ApiClient(dio));

    final health = await repository.check();

    expect(health.status, 'ok');
    expect(health.database, 'connected');
    expect(requested.uri.path, '/api/health');
    dio.close(force: true);
  });

  test('maps API errors to a safe typed exception', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test/api/'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.reject(
            DioException(
              requestOptions: options,
              response: Response<void>(
                requestOptions: options,
                statusCode: 503,
              ),
            ),
          );
        },
      ),
    );
    final repository = RemoteApiHealthRepository(ApiClient(dio));

    await expectLater(
      repository.check(),
      throwsA(
        isA<ApiException>().having((error) => error.statusCode, 'status', 503),
      ),
    );
    dio.close(force: true);
  });
}
