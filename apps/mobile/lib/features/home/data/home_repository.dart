import '../../../core/network/api_client.dart';

class PropertyMediaRef {
  const PropertyMediaRef({required this.slug, required this.mediaId});

  final String slug;
  final String mediaId;

  @override
  bool operator ==(Object other) =>
      other is PropertyMediaRef &&
      other.slug == slug &&
      other.mediaId == mediaId;

  @override
  int get hashCode => Object.hash(slug, mediaId);
}

class HomeProperty {
  const HomeProperty({
    required this.id,
    required this.slug,
    required this.title,
    required this.category,
    required this.operationType,
    required this.price,
    required this.currency,
    required this.locationName,
    required this.coverMediaId,
    this.details = const {},
    this.isVerified = false,
    this.isAvailable = true,
  });

  final String id;
  final String slug;
  final String title;
  final String category;
  final String operationType;
  final String? price;
  final String currency;
  final String? locationName;
  final String? coverMediaId;
  final Map<String, dynamic> details;
  final bool isVerified;
  final bool isAvailable;

  factory HomeProperty.fromJson(Map<String, dynamic> json) {
    final media = json['media'] is List ? json['media'] as List : const [];
    final mediaMaps = media.whereType<Map<String, dynamic>>().toList();
    final cover = mediaMaps
        .where((item) => item['isCover'] == true)
        .firstOrNull;
    final selectedMedia = cover ?? (mediaMaps.isEmpty ? null : mediaMaps.first);
    final location = json['location'];
    final advertiser = json['advertiser'];
    final agentProfile = advertiser is Map<String, dynamic>
        ? advertiser['agentProfile']
        : null;
    final rawDetails = json['details'];

    return HomeProperty(
      id: json['id'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? '',
      operationType: json['operationType'] as String? ?? '',
      price: json['price']?.toString(),
      currency: json['currency'] as String? ?? 'XOF',
      locationName: location is Map<String, dynamic>
          ? location['name'] as String?
          : null,
      coverMediaId: selectedMedia?['id'] as String?,
      details: rawDetails is Map<String, dynamic> ? rawDetails : const {},
      isVerified:
          agentProfile is Map<String, dynamic> &&
          agentProfile['verificationStatus'] == 'APPROVED',
      isAvailable:
          json['availability'] == null || json['availability'] == 'AVAILABLE',
    );
  }
}

abstract interface class HomeRepository {
  Future<List<HomeProperty>> loadRecent();
  Future<String> loadMediaUrl(PropertyMediaRef media);
}

class RemoteHomeRepository implements HomeRepository {
  const RemoteHomeRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<HomeProperty>> loadRecent() async {
    final response = await _apiClient.getJson(
      'properties',
      queryParameters: const {'page': 1, 'pageSize': 4},
    );
    final items = response['items'];
    if (items is! List ||
        !items.every((item) => item is Map<String, dynamic>)) {
      throw const ApiException('The API returned an invalid property list.');
    }
    return items
        .cast<Map<String, dynamic>>()
        .map(HomeProperty.fromJson)
        .toList(growable: false);
  }

  @override
  Future<String> loadMediaUrl(PropertyMediaRef media) async {
    final response = await _apiClient.getJson(
      'properties/${Uri.encodeComponent(media.slug)}/media/${Uri.encodeComponent(media.mediaId)}',
    );
    final url = response['url'];
    if (url is! String || Uri.tryParse(url)?.hasScheme != true) {
      throw const ApiException('The API returned an invalid media URL.');
    }
    return url;
  }
}
