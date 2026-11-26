import '../../../core/network/api_client.dart';
import '../domain/api_health.dart';

class RemoteApiHealthRepository implements ApiHealthRepository {
  const RemoteApiHealthRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<ApiHealth> check() async {
    final response = await _apiClient.getJson('health');
    return ApiHealth.fromJson(response);
  }
}
