import '../../../core/network/api_client.dart';

class PropertyDraft {
  const PropertyDraft({
    required this.id,
    required this.slug,
    required this.title,
    required this.publicationStatus,
  });

  final String id;
  final String slug;
  final String title;
  final String publicationStatus;

  factory PropertyDraft.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final slug = json['slug'];
    final title = json['title'];
    final status = json['publicationStatus'];
    if (id is! String ||
        slug is! String ||
        title is! String ||
        status is! String) {
      throw const ApiException('The API returned an invalid property draft.');
    }
    return PropertyDraft(
      id: id,
      slug: slug,
      title: title,
      publicationStatus: status,
    );
  }
}

abstract interface class PropertyDraftRepository {
  Future<PropertyDraft> createDraft({
    required String title,
    required String description,
    required String category,
    required String operationType,
    required String locationId,
    String? price,
  });
}

class RemotePropertyDraftRepository implements PropertyDraftRepository {
  const RemotePropertyDraftRepository(this._api);

  final ApiClient _api;

  @override
  Future<PropertyDraft> createDraft({
    required String title,
    required String description,
    required String category,
    required String operationType,
    required String locationId,
    String? price,
  }) async {
    final response = await _api.postJson(
      'properties',
      body: {
        'title': title.trim(),
        'description': description.trim(),
        'category': category,
        'operationType': operationType,
        'locationId': locationId,
        if (price != null && price.trim().isNotEmpty) 'price': price.trim(),
      },
    );
    return PropertyDraft.fromJson(response);
  }
}
