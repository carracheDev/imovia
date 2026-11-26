class SearchCriteria {
  const SearchCriteria({
    this.query,
    this.operationType,
    this.category,
    this.locationId,
    this.locationName,
    this.priceMin,
    this.priceMax,
  });

  final String? query;
  final String? operationType;
  final String? category;
  final String? locationId;
  final String? locationName;
  final String? priceMin;
  final String? priceMax;

  Map<String, dynamic> toApiQueryParameters() => {
    if (query != null && query!.trim().isNotEmpty) 'q': query!.trim(),
    if (operationType != null) 'operationType': operationType,
    if (category != null) 'category': category,
    if (locationId != null) 'locationId': locationId,
    if (priceMin != null && priceMin!.isNotEmpty) 'priceMin': priceMin,
    if (priceMax != null && priceMax!.isNotEmpty) 'priceMax': priceMax,
    'page': 1,
    'pageSize': 1,
  };
}
