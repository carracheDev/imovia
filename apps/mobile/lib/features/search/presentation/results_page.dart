import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/providers.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/imovia_colors.dart';
import '../../../core/ui/account_bottom_nav.dart';
import '../../home/data/home_repository.dart';
import '../../properties/presentation/property_listing_card.dart';
import '../domain/search_criteria.dart';

class ResultsPage extends ConsumerStatefulWidget {
  const ResultsPage({super.key, required this.criteria});

  final SearchCriteria criteria;

  @override
  ConsumerState<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends ConsumerState<ResultsPage> {
  static const _pageSize = 10;
  final _scrollController = ScrollController();
  List<HomeProperty> _properties = [];
  int _total = 0;
  int _page = 0;
  int _totalPages = 0;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    _loadFirstPage();
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (_scrollController.position.extentAfter < 360) _loadMore();
  }

  Future<void> _loadFirstPage() async {
    setState(() {
      _isLoading = true;
      _isLoadingMore = false;
      _error = null;
      _properties = [];
      _page = 0;
      _totalPages = 0;
    });
    try {
      final result = await ref
          .read(searchRepositoryProvider)
          .loadResults(widget.criteria, page: 1, pageSize: _pageSize);
      if (!mounted) return;
      setState(() {
        _properties = result.items;
        _total = result.total;
        _page = result.page;
        _totalPages = result.totalPages;
      });
    } on ApiException {
      if (mounted) {
        setState(() => _error = 'Impossible de charger les annonces.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading ||
        _isLoadingMore ||
        _error != null ||
        _page == 0 ||
        _page >= _totalPages) {
      return;
    }
    setState(() => _isLoadingMore = true);
    try {
      final result = await ref
          .read(searchRepositoryProvider)
          .loadResults(widget.criteria, page: _page + 1, pageSize: _pageSize);
      if (!mounted) return;
      setState(() {
        _properties = [..._properties, ...result.items];
        _total = result.total;
        _page = result.page;
        _totalPages = result.totalPages;
      });
    } on ApiException {
      if (mounted) {
        setState(
          () => _error = 'La suite des annonces n’a pas pu être chargée.',
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _addFavorite(HomeProperty property) async {
    final token = await ref.read(sessionTokenStoreProvider).readToken();
    if (!mounted) return;
    if (token == null || token.isEmpty) {
      context.push<void>('/login?returnTo=/favorites');
      return;
    }
    try {
      await ref.read(favoritesRepositoryProvider).add(property.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Annonce ajoutée aux favoris.')),
        );
      }
    } on ApiException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d’ajouter ce favori.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: ImoviaColors.page,
    appBar: AppBar(
      leading: IconButton(
        onPressed: () => context.pop(),
        tooltip: 'Retour aux critères',
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      title: Text('Résultats', style: Theme.of(context).textTheme.titleLarge),
      actions: [
        IconButton(
          onPressed: () => context.pop(),
          tooltip: 'Modifier les filtres',
          icon: const Icon(Icons.tune_rounded),
        ),
        const SizedBox(width: 6),
      ],
    ),
    body: Column(
      children: [
        _CriteriaSummary(
          total: _total,
          criteria: widget.criteria,
          isLoading: _isLoading,
        ),
        Expanded(child: _buildResults(context)),
      ],
    ),
    bottomNavigationBar: const AccountBottomNav(selected: 'Recherche'),
  );

  Widget _buildResults(BuildContext context) {
    if (_isLoading && _properties.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(18),
        children: const [
          _ResultSkeleton(),
          SizedBox(height: 14),
          _ResultSkeleton(),
        ],
      );
    }
    if (_error != null && _properties.isEmpty) {
      return _ResultState(
        icon: Icons.cloud_off_outlined,
        message: _error!,
        actionLabel: 'Réessayer',
        onAction: _loadFirstPage,
      );
    }
    if (_properties.isEmpty) {
      return const _ResultState(
        icon: Icons.search_off_rounded,
        message: 'Aucune annonce ne correspond à ces critères.',
      );
    }
    return RefreshIndicator(
      color: ImoviaColors.brandAccent,
      onRefresh: _loadFirstPage,
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 26),
        itemCount: _properties.length + (_isLoadingMore ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          if (index >= _properties.length) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final property = _properties[index];
          return PropertyListingCard(
            property: property,
            onTap: () => context.push<void>(
              '/properties/${Uri.encodeComponent(property.slug)}',
            ),
            onFavorite: () => _addFavorite(property),
          );
        },
      ),
    );
  }
}

class _CriteriaSummary extends StatelessWidget {
  const _CriteriaSummary({
    required this.total,
    required this.criteria,
    required this.isLoading,
  });

  final int total;
  final SearchCriteria criteria;
  final bool isLoading;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: const EdgeInsets.fromLTRB(18, 2, 18, 10),
    padding: const EdgeInsets.fromLTRB(15, 13, 15, 12),
    decoration: BoxDecoration(
      color: ImoviaColors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: ImoviaColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isLoading
              ? 'Recherche des biens…'
              : '$total annonce${total == 1 ? '' : 's'} trouvée${total == 1 ? '' : 's'}',
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(color: ImoviaColors.brandAccent),
        ),
        if (_summaryLabels.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              for (final label in _summaryLabels)
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: ImoviaColors.gray),
                ),
            ],
          ),
        ],
      ],
    ),
  );

  List<String> get _summaryLabels => [
    if (criteria.query != null) '« ${criteria.query} »',
    if (criteria.operationType == 'SALE') 'Vente',
    if (criteria.operationType == 'RENT') 'Location',
    if (criteria.category != null) _categoryLabel(criteria.category!),
    if (criteria.locationName != null) criteria.locationName!,
    if (criteria.priceMin != null) 'Dès ${criteria.priceMin} FCFA',
    if (criteria.priceMax != null) 'Jusqu’à ${criteria.priceMax} FCFA',
  ];

  String _categoryLabel(String category) => switch (category) {
    'ROOM' => 'Chambre simple',
    'ROOM_AND_LIVING' => 'Chambre-salon',
    'STUDIO' => 'Studio',
    'APARTMENT' => 'Appartement',
    'HOUSE' => 'Maison',
    'VILLA' => 'Villa',
    'LAND' => 'Terrain',
    'SHOP' => 'Boutique',
    'COMMERCIAL_SPACE' => 'Local commercial',
    'OFFICE' => 'Bureau',
    'WAREHOUSE' => 'Entrepôt',
    _ => 'Autre',
  };
}

class _ResultState extends StatelessWidget {
  const _ResultState({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: const EdgeInsets.all(24),
    children: [
      const SizedBox(height: 100),
      Icon(icon, size: 42, color: ImoviaColors.gray),
      const SizedBox(height: 12),
      Text(message, textAlign: TextAlign.center),
      if (actionLabel != null) ...[
        const SizedBox(height: 14),
        Center(
          child: OutlinedButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(actionLabel!),
          ),
        ),
      ],
    ],
  );
}

class _ResultSkeleton extends StatelessWidget {
  const _ResultSkeleton();

  @override
  Widget build(BuildContext context) => Container(
    height: 330,
    decoration: BoxDecoration(
      color: ImoviaColors.white,
      borderRadius: BorderRadius.circular(20),
    ),
    clipBehavior: Clip.antiAlias,
    child: const Column(
      children: [
        SizedBox(height: 190, child: _ResultPhotoPlaceholder()),
        Expanded(child: ColoredBox(color: ImoviaColors.white)),
      ],
    ),
  );
}

class _ResultPhotoPlaceholder extends StatelessWidget {
  const _ResultPhotoPlaceholder();

  @override
  Widget build(BuildContext context) => const ColoredBox(
    color: ImoviaColors.lightGray,
    child: Center(child: Icon(Icons.photo_outlined, color: ImoviaColors.gray)),
  );
}
