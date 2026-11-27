import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imovia_mobile/core/network/api_client.dart';
import 'package:imovia_mobile/features/properties/data/property_draft_repository.dart';

void main() {
  test('creates an owner listing draft through the properties API', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test/api/'));
    late RequestOptions request;
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          request = options;
          handler.resolve(
            Response<Map<String, dynamic>>(
              requestOptions: options,
              statusCode: 201,
              data: {
                'id': 'draft-1',
                'slug': 'villa-cotonou-abc12345',
                'title': 'Villa à Cotonou',
                'publicationStatus': 'DRAFT',
              },
            ),
          );
        },
      ),
    );
    final repository = RemotePropertyDraftRepository(ApiClient(dio));

    final draft = await repository.createDraft(
      title: ' Villa à Cotonou ',
      description: 'Belle villa avec cour, eau et électricité.',
      category: 'VILLA',
      operationType: 'RENT',
      locationId: 'neighborhood-fidjrosse',
      price: '250000',
    );

    expect(request.method, 'POST');
    expect(request.uri.path, '/api/properties');
    expect(request.data, {
      'title': 'Villa à Cotonou',
      'description': 'Belle villa avec cour, eau et électricité.',
      'category': 'VILLA',
      'operationType': 'RENT',
      'locationId': 'neighborhood-fidjrosse',
      'price': '250000',
    });
    expect(draft.id, 'draft-1');
    expect(draft.publicationStatus, 'DRAFT');
    dio.close(force: true);
  });
}
