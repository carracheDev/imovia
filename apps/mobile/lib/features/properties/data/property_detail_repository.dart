import '../../../core/network/api_client.dart';

class PropertyDetail {
  const PropertyDetail({
    required this.id,
    required this.slug,
    required this.title,
    required this.description,
    required this.category,
    required this.operationType,
    required this.price,
    required this.currency,
    required this.locationName,
    required this.ownerDisplayName,
    required this.details,
    required this.visitInstructions,
    required this.media,
  });

  final String id;
  final String slug;
  final String title;
  final String description;
  final String category;
  final String operationType;
  final String? price;
  final String currency;
  final String? locationName;
  final String? ownerDisplayName;
  final Map<String, dynamic> details;
  final String? visitInstructions;
  final List<PropertyDetailMedia> media;

  factory PropertyDetail.fromJson(Map<String, dynamic> json) {
    final location = json['location'];
    final rawDetails = json['details'];
    final rawMedia = json['media'];
    final rawAdvertiser = json['advertiser'];
    final ownerName = json['ownerDisplayName'];
    return PropertyDetail(
      id: json['id'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      operationType: json['operationType'] as String? ?? '',
      price: json['price']?.toString(),
      currency: json['currency'] as String? ?? 'XOF',
      locationName: location is Map<String, dynamic>
          ? location['name'] as String?
          : null,
      ownerDisplayName: ownerName is String && ownerName.isNotEmpty
          ? ownerName
          : rawAdvertiser is Map<String, dynamic>
          ? _advertiserName(rawAdvertiser)
          : null,
      details: rawDetails is Map<String, dynamic> ? rawDetails : const {},
      visitInstructions: json['visitInstructions'] as String?,
      media: rawMedia is List
          ? rawMedia
                .whereType<Map<String, dynamic>>()
                .map(PropertyDetailMedia.fromJson)
                .toList(growable: false)
          : const [],
    );
  }

  static String? _advertiserName(Map<String, dynamic> advertiser) {
    final agent = advertiser['agentProfile'];
    final owner = advertiser['ownerProfile'];
    final profileName = agent is Map<String, dynamic>
        ? agent['displayName']
        : owner is Map<String, dynamic>
        ? owner['displayName']
        : null;
    if (profileName is String && profileName.isNotEmpty) return profileName;
    final first = advertiser['firstName'] as String? ?? '';
    final last = advertiser['lastName'] as String? ?? '';
    final name = '$first $last'.trim();
    return name.isEmpty ? null : name;
  }
}

class PropertyDetailMedia {
  const PropertyDetailMedia({required this.id, required this.position});

  final String id;
  final int position;

  factory PropertyDetailMedia.fromJson(Map<String, dynamic> json) =>
      PropertyDetailMedia(
        id: json['id'] as String? ?? '',
        position: json['position'] as int? ?? 0,
      );
}

class PropertyContact {
  const PropertyContact({this.phone, this.whatsApp});

  final String? phone;
  final String? whatsApp;
}

abstract interface class PropertyDetailRepository {
  Future<PropertyDetail> load(String slug);
  Future<PropertyContact> loadContact(String slug);
  Future<String> loadMediaUrl(String slug, String mediaId);
}

class RemotePropertyDetailRepository implements PropertyDetailRepository {
  const RemotePropertyDetailRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<PropertyDetail> load(String slug) async => PropertyDetail.fromJson(
    await _apiClient.getJson('properties/${Uri.encodeComponent(slug)}'),
  );

  @override
  Future<PropertyContact> loadContact(String slug) async {
    final response = await _apiClient.getJson(
      'properties/${Uri.encodeComponent(slug)}/contact',
    );
    return PropertyContact(
      phone: response['phone'] as String?,
      whatsApp: response['whatsApp'] as String?,
    );
  }

  @override
  Future<String> loadMediaUrl(String slug, String mediaId) async {
    final response = await _apiClient.getJson(
      'properties/${Uri.encodeComponent(slug)}/media/${Uri.encodeComponent(mediaId)}',
    );
    final url = response['url'];
    if (url is! String || Uri.tryParse(url)?.hasScheme != true) {
      throw const ApiException('The API returned an invalid media URL.');
    }
    return url;
  }
}
