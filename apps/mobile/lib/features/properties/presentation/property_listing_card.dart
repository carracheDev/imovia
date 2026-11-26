import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/providers.dart';
import '../../../core/theme/imovia_colors.dart';
import '../../home/data/home_repository.dart';

class PropertyListingCard extends ConsumerWidget {
  const PropertyListingCard({
    super.key,
    required this.property,
    required this.onTap,
    required this.onFavorite,
  });

  final HomeProperty property;
  final VoidCallback onTap;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final referencePhoto =
        property.category == 'APARTMENT' || property.category == 'STUDIO'
        ? 'assets/images/living-room.jpg'
        : 'assets/images/villa_exterior.webp';
    final mediaId = property.coverMediaId;
    final imageUrl = mediaId == null
        ? null
        : ref.watch(
            propertyImageUrlProvider(
              PropertyMediaRef(slug: property.slug, mediaId: mediaId),
            ),
          );
    return Material(
      color: ImoviaColors.white,
      elevation: 1.2,
      shadowColor: const Color(0x190B0B0B),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: ImoviaColors.border),
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: 190,
                    width: double.infinity,
                    child: imageUrl == null
                        ? _ReferencePhoto(asset: referencePhoto)
                        : imageUrl.when(
                            data: (url) => Image.network(
                              url,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) =>
                                  _ReferencePhoto(asset: referencePhoto),
                            ),
                            loading: () => _ReferencePhoto(
                              asset: referencePhoto,
                              loading: true,
                            ),
                            error: (_, _) =>
                                _ReferencePhoto(asset: referencePhoto),
                          ),
                  ),
                  Positioned(
                    top: 11,
                    left: 11,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: !property.isAvailable
                            ? ImoviaColors.lightGray
                            : property.isVerified
                            ? const Color(0xFFE8F4EC)
                            : ImoviaColors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        !property.isAvailable
                            ? 'Indisponible'
                            : property.isVerified
                            ? '✓ Vérifié'
                            : property.operationType == 'RENT'
                            ? 'À louer'
                            : 'À vendre',
                        style: TextStyle(
                          color: property.isAvailable && property.isVerified
                              ? const Color(0xFF16803C)
                              : ImoviaColors.ink,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 9,
                    right: 9,
                    child: Material(
                      color: ImoviaColors.white,
                      shape: const CircleBorder(),
                      child: IconButton(
                        onPressed: onFavorite,
                        tooltip: 'Ajouter aux favoris',
                        icon: const Icon(Icons.favorite_border_rounded),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 12, 15, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property.price == null
                          ? 'Prix sur demande'
                          : '${_formatPrice(property.price!)} ${property.currency == 'XOF' ? 'FCFA' : property.currency}${property.operationType == 'RENT' ? ' / mois' : ''}',
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      property.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: ImoviaColors.charcoal),
                    ),
                    if (property.locationName != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 17,
                            color: ImoviaColors.gray,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              property.locationName!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: ImoviaColors.gray),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (_summaryDetails(property.details).isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 14,
                        runSpacing: 5,
                        children: _summaryDetails(property.details)
                            .map(
                              (detail) => Text(
                                detail,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: ImoviaColors.charcoal),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPrice(String price) {
    final value = num.tryParse(price);
    return value == null ? price : NumberFormat('#,##0', 'fr_FR').format(value);
  }

  List<String> _summaryDetails(Map<String, dynamic> details) {
    const fields = {
      'bedrooms': 'ch.',
      'bedroomCount': 'ch.',
      'bathrooms': 'sdb.',
      'bathroomCount': 'sdb.',
      'surfaceArea': 'm²',
      'surface': 'm²',
      'area': 'm²',
    };
    final values = <String>[];
    for (final entry in fields.entries) {
      final value = details[entry.key];
      if (value != null && value.toString().isNotEmpty) {
        final text = '${value.toString()} ${entry.value}';
        if (!values.contains(text)) values.add(text);
      }
      if (values.length == 3) break;
    }
    return values;
  }
}

class _ReferencePhoto extends StatelessWidget {
  const _ReferencePhoto({required this.asset, this.loading = false});
  final String asset;
  final bool loading;
  @override
  Widget build(BuildContext context) => loading
      ? const ColoredBox(
          color: ImoviaColors.lightGray,
          child: Center(
            child: Icon(
              Icons.photo_outlined,
              size: 40,
              color: ImoviaColors.gray,
            ),
          ),
        )
      : Image.asset(
          asset,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        );
}
