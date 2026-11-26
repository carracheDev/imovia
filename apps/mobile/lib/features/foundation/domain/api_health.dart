import '../../../core/network/api_client.dart';

class ApiHealth {
  const ApiHealth({required this.status, required this.database});

  final String status;
  final String database;

  factory ApiHealth.fromJson(Map<String, dynamic> json) {
    final status = json['status'];
    final database = json['database'];
    if (status is! String || database is! String) {
      throw const ApiException(
        'The health response is missing required fields.',
      );
    }
    return ApiHealth(status: status, database: database);
  }
}

abstract interface class ApiHealthRepository {
  Future<ApiHealth> check();
}
