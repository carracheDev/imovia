import 'package:dio/dio.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiClient {
  const ApiClient(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final data = await _request(
      () => _dio.get<Object?>(path, queryParameters: queryParameters),
    );
    if (data is Map<String, dynamic>) return data;
    throw const ApiException('The API returned an invalid response.');
  }

  Future<List<Map<String, dynamic>>> getJsonList(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final data = await _request(
      () => _dio.get<Object?>(path, queryParameters: queryParameters),
    );
    if (data is List<Object?> &&
        data.every((item) => item is Map<String, dynamic>)) {
      return data.cast<Map<String, dynamic>>();
    }
    throw const ApiException('The API returned an invalid response.');
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    Object? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    final data = await _request(
      () => _dio.post<Object?>(
        path,
        data: body,
        queryParameters: queryParameters,
      ),
    );
    if (data is Map<String, dynamic>) return data;
    throw const ApiException('The API returned an invalid response.');
  }

  Future<Map<String, dynamic>> patchJson(String path, {Object? body}) async {
    final data = await _request(() => _dio.patch<Object?>(path, data: body));
    if (data is Map<String, dynamic>) return data;
    throw const ApiException('The API returned an invalid response.');
  }

  Future<void> delete(String path) async {
    await _request(() => _dio.delete<Object?>(path));
  }

  Future<Object?> _request(Future<Response<Object?>> Function() request) async {
    try {
      return (await request()).data;
    } on DioException catch (error) {
      throw ApiException(
        'The API request failed. Please try again.',
        statusCode: error.response?.statusCode,
      );
    }
  }
}
