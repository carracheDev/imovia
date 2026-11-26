import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/providers.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/imovia_colors.dart';
import '../data/property_detail_repository.dart';

class PropertyDetailPage extends ConsumerStatefulWidget {
  const PropertyDetailPage({super.key, required this.slug});

  final String slug;

  @override
  ConsumerState<PropertyDetailPage> createState() => _PropertyDetailPageState();
}

class _PropertyDetailPageState extends ConsumerState<PropertyDetailPage> {
  late Future<PropertyDetail> _detailFuture;
  int _selectedPhoto = 0;
  bool _isFavoriteLoading = false;

  @override
  void initState() {
    super.initState();
    _detailFuture = ref
        .read(propertyDetailRepositoryProvider)
        .load(widget.slug);
  }

  Future<void> _addFavorite(PropertyDetail property) async {
    final token = await ref.read(sessionTokenStoreProvider).readToken();
    if (!mounted) return;
    if (token == null || token.isEmpty) {
      context.push<void>(
        '/login?returnTo=%2Fproperties%2F${Uri.encodeComponent(property.slug)}',
      );
      return;
    }
    setState(() => _isFavoriteLoading = true);
    try {
      await ref.read(favoritesRepositoryProvider).add(property.id);
      if (mounted) _message('Annonce ajoutée aux favoris.');
    } on ApiException {
      if (mounted) _message('Impossible d’ajouter ce favori.');
    } finally {
      if (mounted) setState(() => _isFavoriteLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: ImoviaColors.page,
    body: SafeArea(
      child: FutureBuilder<PropertyDetail>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _DetailError(
              onRetry: () => setState(() {
                _detailFuture = ref
                    .read(propertyDetailRepositoryProvider)
                    .load(widget.slug);
              }),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return _content(context, snapshot.data!);
        },
      ),
    ),
  );

  Widget _content(
    BuildContext context,
    PropertyDetail property,
  ) => CustomScrollView(
    slivers: [
      SliverToBoxAdapter(child: _gallery(property)),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        sliver: SliverList.list(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _categoryName(property.category),
                    style: Theme.of(context).textTheme.labelLarge
                        ?.copyWith(color: ImoviaColors.brandAccent),
                  ),
                ),
                _StatusPill(
                  label: property.operationType == 'RENT'
                      ? 'À louer'
                      : 'À vendre',
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              property.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (property.locationName != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 19,
                    color: ImoviaColors.brandAccent,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      property.locationName!,
                      style: Theme.of(context).textTheme.bodyLarge
                          ?.copyWith(color: ImoviaColors.gray),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 17),
            Text(
              '${_price(property.price)} ${property.currency == 'XOF' ? 'FCFA' : property.currency}${property.operationType == 'RENT' ? ' / mois' : ''}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: ImoviaColors.brandAccent,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (property.details.isNotEmpty) ...[
              const SizedBox(height: 24),
              _SectionTitle('Caractéristiques'),
              const SizedBox(height: 12),
              _FeatureGrid(details: property.details),
            ],
            const SizedBox(height: 24),
            _SectionTitle('Description'),
            const SizedBox(height: 9),
            Text(
              property.description.isEmpty
                  ? 'Aucune description renseignée.'
                  : property.description,
              style: Theme.of(context).textTheme.bodyLarge
                  ?.copyWith(height: 1.5),
            ),
            if (property.visitInstructions?.isNotEmpty == true) ...[
              const SizedBox(height: 22),
              _SectionTitle('Visites'),
              const SizedBox(height: 8),
              Text(
                property.visitInstructions!,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(height: 1.45),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => context.push<void>(
                  '/properties/${Uri.encodeComponent(property.slug)}/contact',
                ),
                icon: const Icon(Icons.call_outlined),
                label: const Text('Contacter l’annonceur'),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Les moyens de contact sont affichés selon les préférences de l’annonceur.',
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: ImoviaColors.gray),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _gallery(PropertyDetail property) => SizedBox(
    height: 300,
    child: Stack(
      children: [
        PageView.builder(
          itemCount: property.media.isEmpty ? 1 : property.media.length,
          onPageChanged: (index) => setState(() => _selectedPhoto = index),
          itemBuilder: (context, index) {
            if (property.media.isEmpty) return const _PhotoFallback();
            final media = property.media[index];
            return FutureBuilder<String>(
              future: ref
                  .read(propertyDetailRepositoryProvider)
                  .loadMediaUrl(property.slug, media.id),
              builder: (context, snapshot) => snapshot.hasData
                  ? Image.network(
                      snapshot.data!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const _PhotoFallback(),
                    )
                  : const _PhotoFallback(),
            );
          },
        ),
        Positioned(
          top: 10,
          left: 8,
          child: _RoundAction(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.of(context).maybePop(),
          ),
        ),
        Positioned(
          top: 10,
          right: 8,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _RoundAction(
                icon: Icons.share_outlined,
                onTap: () => SharePlus.instance.share(
                  ShareParams(
                    text:
                        '${property.title} · ${property.locationName ?? 'Bénin'}\nhttps://imovia.bj/properties/${property.slug}',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _RoundAction(
                icon: _isFavoriteLoading
                    ? Icons.hourglass_top_rounded
                    : Icons.favorite_border_rounded,
                onTap: () => _addFavorite(property),
              ),
            ],
          ),
        ),
        if (property.media.isNotEmpty)
          Positioned(
            bottom: 14,
            right: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xCC17191B),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_selectedPhoto + 1}/${property.media.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    ),
  );

  void _message(String value) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(value)));

  String _price(String? value) {
    if (value == null) return 'Prix sur demande';
    final number = num.tryParse(value);
    return number == null
        ? value
        : NumberFormat('#,##0', 'fr_FR').format(number);
  }

  String _categoryName(String value) => switch (value) {
    'ROOM' => 'Chambre simple',
    'ROOM_AND_LIVING' => 'Chambre-salon',
    'STUDIO' => 'Studio',
    'APARTMENT' => 'Appartement',
    'HOUSE' => 'Maison',
    'VILLA' => 'Villa',
    'LAND' => 'Terrain',
    'SHOP' => 'Boutique',
    'OFFICE' => 'Bureau',
    'WAREHOUSE' => 'Entrepôt',
    _ => 'Bien immobilier',
  };
}

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid({required this.details});
  final Map<String, dynamic> details;

  @override
  Widget build(BuildContext context) {
    final entries = details.entries
        .where(
          (entry) => entry.value != null && entry.value.toString().isNotEmpty,
        )
        .take(6)
        .toList();
    return Wrap(
      spacing: 9,
      runSpacing: 9,
      children: [
        for (final entry in entries)
          Container(
            width: 150,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ImoviaColors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: ImoviaColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _label(entry.key),
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: ImoviaColors.gray),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.value.toString(),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
      ],
    );
  }

  String _label(String key) => key
      .replaceAllMapped(
        RegExp(r'([A-Z])'),
        (match) => ' ${match.group(1)!.toLowerCase()}',
      )
      .replaceAll('_', ' ')
      .trim();
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;
  @override
  Widget build(BuildContext context) =>
      Text(title, style: Theme.of(context).textTheme.titleLarge);
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
    decoration: BoxDecoration(
      color: ImoviaColors.brandAccentSoft,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: const TextStyle(
        color: ImoviaColors.brandAccent,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: ImoviaColors.white,
    shape: const CircleBorder(),
    elevation: 2,
    child: IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: ImoviaColors.ink),
    ),
  );
}

class _PhotoFallback extends StatelessWidget {
  const _PhotoFallback();
  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/images/villa_exterior.webp',
    fit: BoxFit.cover,
    width: double.infinity,
    height: double.infinity,
  );
}

class _DetailError extends StatelessWidget {
  const _DetailError({required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            size: 44,
            color: ImoviaColors.gray,
          ),
          const SizedBox(height: 12),
          const Text('Impossible de charger cette annonce.'),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
          ),
        ],
      ),
    ),
  );
}
