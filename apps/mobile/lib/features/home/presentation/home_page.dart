import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/providers.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/imovia_colors.dart';
import '../../properties/presentation/property_listing_card.dart';
import '../data/home_repository.dart';

typedef HomeSearchAction = void Function(String query);
typedef HomeCategoryAction = void Function(String? category, String? operation);
typedef HomePropertyAction = void Function(HomeProperty property);
typedef HomeFiltersAction = void Function();
typedef HomeFavoritesAction = void Function();

class HomePage extends ConsumerStatefulWidget {
  const HomePage({
    super.key,
    this.onSearch,
    this.onCategory,
    this.onProperty,
    this.onFilters,
    this.onFavorites,
    this.onOpenProfile,
    this.onOpenNotifications,
    this.onPublishProperty,
  });

  final HomeSearchAction? onSearch;
  final HomeCategoryAction? onCategory;
  final HomePropertyAction? onProperty;
  final HomeFiltersAction? onFilters;
  final HomeFavoritesAction? onFavorites;
  final HomeFavoritesAction? onOpenProfile;
  final HomeFavoritesAction? onOpenNotifications;
  final HomeFavoritesAction? onPublishProperty;

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showComingSoon(String target) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$target sera disponible dans son prochain écran.'),
      ),
    );
  }

  void _submitSearch() {
    FocusScope.of(context).unfocus();
    final action = widget.onSearch;
    if (action == null) {
      _showComingSoon('La recherche');
      return;
    }
    action(_searchController.text.trim());
  }

  void _openFilters() {
    final action = widget.onFilters;
    if (action == null) {
      _showComingSoon('Les filtres avancés');
    } else {
      action();
    }
  }

  void _openNotifications() {
    final action = widget.onOpenNotifications;
    if (action == null) {
      _showComingSoon('Les notifications');
    } else {
      action();
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
  Widget build(BuildContext context) {
    final listings = ref.watch(homeListingsProvider);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: ImoviaColors.ink,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: ImoviaColors.ink,
      ),
      child: Scaffold(
        body: SafeArea(
          top: false,
          child: RefreshIndicator(
            color: ImoviaColors.ink,
            onRefresh: () => ref.refresh(homeListingsProvider.future),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _HeroSearch(
                    controller: _searchController,
                    onSubmit: _submitSearch,
                    onFilter: _openFilters,
                    onNotifications: _openNotifications,
                    onPublish:
                        widget.onPublishProperty ??
                        () => context.push<void>('/advertiser/setup'),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 24, 18, 24),
                  sliver: SliverList.list(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _CategoryTile(
                              icon: Icons.home_outlined,
                              label: 'À vendre',
                              onTap: () => _category(null, 'SALE'),
                            ),
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: _CategoryTile(
                              icon: Icons.key_rounded,
                              label: 'À louer',
                              onTap: () => _category(null, 'RENT'),
                            ),
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: _CategoryTile(
                              icon: Icons.hexagon_outlined,
                              label: 'Terrains',
                              onTap: () => _category('LAND', null),
                            ),
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: _CategoryTile(
                              icon: Icons.spa_outlined,
                              label: 'Services',
                              onTap: () => _showComingSoon('Les services'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Nos biens en vedette',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          TextButton(
                            onPressed: () => _category(null, null),
                            child: const Text('Voir tout'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      listings.when(
                        loading: () => const _LoadingListings(),
                        error: (error, _) => _LoadError(
                          onRetry: () => ref.invalidate(homeListingsProvider),
                        ),
                        data: (items) => items.isEmpty
                            ? const _EmptyListings()
                            : Column(
                                children: [
                                  for (final item in items) ...[
                                    _PropertyCard(
                                      property: item,
                                      onTap: () {
                                        final action = widget.onProperty;
                                        if (action == null) {
                                          _showComingSoon(
                                            'Le détail de l’annonce',
                                          );
                                        } else {
                                          action(item);
                                        }
                                      },
                                      onFavorite: () => _addFavorite(item),
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _BottomNavigation(
          onTap: (label) {
            if (label == 'Favoris' && widget.onFavorites != null) {
              widget.onFavorites!();
              return;
            }
            if (label == 'Profil' && widget.onOpenProfile != null) {
              widget.onOpenProfile!();
              return;
            }
            if (label != 'Accueil') _showComingSoon(label);
          },
        ),
      ),
    );
  }

  void _category(String? category, String? operation) {
    final action = widget.onCategory;
    if (action == null) {
      _showComingSoon('Les résultats de recherche');
    } else {
      action(category, operation);
    }
  }
}

class _HeroSearch extends StatelessWidget {
  const _HeroSearch({
    required this.controller,
    required this.onSubmit,
    required this.onFilter,
    required this.onNotifications,
    required this.onPublish,
  });

  final TextEditingController controller;
  final VoidCallback onSubmit;
  final VoidCallback onFilter;
  final VoidCallback onNotifications;
  final VoidCallback onPublish;

  @override
  Widget build(BuildContext context) {
    final statusBar = MediaQuery.paddingOf(context).top;
    final height = (MediaQuery.sizeOf(context).height * .56).clamp(
      420.0,
      470.0,
    );
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/nouveau_logo.png', fit: BoxFit.cover),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x61000000),
                  Color(0x10000000),
                  Color(0xAA000000),
                ],
                stops: [0, .42, 1],
              ),
            ),
          ),
          Positioned(
            top: statusBar + 18,
            left: 24,
            right: 24,
            child: Row(
              children: [
                Image.asset(
                  'assets/images/IMOVIA_logos_decoupes/11_symbole_blanc_transparent.png',
                  width: 32,
                  height: 28,
                ),
                const SizedBox(width: 8),
                const Text(
                  'IMOVIA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -.4,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: onPublish,
                  tooltip: 'Publier un bien',
                  color: Colors.white,
                  icon: const Icon(Icons.add_home_work_outlined, size: 24),
                ),
                IconButton(
                  onPressed: onNotifications,
                  tooltip: 'Notifications',
                  color: Colors.white,
                  icon: const Icon(Icons.notifications_none_rounded, size: 27),
                ),
              ],
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 98,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontSize: 30,
                      height: 1.12,
                      letterSpacing: -.8,
                    ),
                    children: const [
                      TextSpan(text: 'Trouvez votre\nbien idéal '),
                      TextSpan(
                        text: 'au Bénin',
                        style: TextStyle(color: ImoviaColors.sun),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 9),
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ImoviaColors.sun,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 9),
                const Text(
                  'Maisons, appartements, terrains…\nen quelques clics.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 18,
            right: 18,
            bottom: 18,
            height: 58,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x35000000),
                    blurRadius: 16,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.search_rounded,
                    color: ImoviaColors.ink,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => onSubmit(),
                      decoration: const InputDecoration(
                        hintText: 'Rechercher un bien, une ville…',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: FilledButton(
                      onPressed: onFilter,
                      style: FilledButton.styleFrom(
                        backgroundColor: ImoviaColors.brandAccent,
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        shape: const CircleBorder(),
                      ),
                      child: const Icon(Icons.tune_rounded, size: 22),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: ImoviaColors.brandAccentSoft,
    borderRadius: BorderRadius.circular(18),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 92,
        decoration: BoxDecoration(
          border: Border.all(color: ImoviaColors.white),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: ImoviaColors.ink),
            const SizedBox(height: 7),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge
                  ?.copyWith(color: ImoviaColors.ink, fontSize: 12),
            ),
          ],
        ),
      ),
    ),
  );
}

class _PropertyCard extends StatelessWidget {
  const _PropertyCard({
    required this.property,
    required this.onTap,
    required this.onFavorite,
  });

  final HomeProperty property;
  final VoidCallback onTap;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) => PropertyListingCard(
    property: property,
    onTap: onTap,
    onFavorite: onFavorite,
  );
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder({this.loading = false});
  final bool loading;

  @override
  Widget build(BuildContext context) => Container(
    color: ImoviaColors.lightGray,
    alignment: Alignment.center,
    child: Icon(
      loading ? Icons.photo_outlined : Icons.home_work_outlined,
      size: 42,
      color: ImoviaColors.gray,
    ),
  );
}

class _LoadingListings extends StatelessWidget {
  const _LoadingListings();

  @override
  Widget build(BuildContext context) => const Column(
    children: [_ListingSkeleton(), SizedBox(height: 16), _ListingSkeleton()],
  );
}

class _ListingSkeleton extends StatelessWidget {
  const _ListingSkeleton();

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
        SizedBox(height: 190, child: _PhotoPlaceholder(loading: true)),
        Expanded(child: ColoredBox(color: ImoviaColors.white)),
      ],
    ),
  );
}

class _EmptyListings extends StatelessWidget {
  const _EmptyListings();

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: ImoviaColors.white,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      children: [
        const Icon(
          Icons.search_off_rounded,
          size: 36,
          color: ImoviaColors.gray,
        ),
        const SizedBox(height: 10),
        Text(
          'Aucune annonce disponible pour le moment.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    ),
  );
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: ImoviaColors.white,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      children: [
        const Icon(
          Icons.cloud_off_outlined,
          size: 36,
          color: ImoviaColors.gray,
        ),
        const SizedBox(height: 8),
        Text(
          'Impossible de charger les annonces.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Réessayer'),
        ),
      ],
    ),
  );
}

class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation({required this.onTap});
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Container(
      margin: const EdgeInsets.fromLTRB(14, 4, 14, 10),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: ImoviaColors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140B0B0B),
            blurRadius: 18,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: _NavItem(
              icon: Icons.home_outlined,
              label: 'Accueil',
              selected: true,
              onTap: () => onTap('Accueil'),
            ),
          ),
          Expanded(
            child: _NavItem(
              icon: Icons.search_rounded,
              label: 'Recherche',
              onTap: () => onTap('Recherche'),
            ),
          ),
          Expanded(
            child: _NavItem(
              icon: Icons.favorite_border_rounded,
              label: 'Favoris',
              onTap: () => onTap('Favoris'),
            ),
          ),
          Expanded(
            child: _NavItem(
              icon: Icons.person_outline_rounded,
              label: 'Profil',
              onTap: () => onTap('Profil'),
            ),
          ),
        ],
      ),
    ),
  );
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(14),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 34,
            height: 30,
            decoration: BoxDecoration(
              color: selected
                  ? ImoviaColors.brandAccentSoft
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              icon,
              color: selected ? ImoviaColors.brandAccent : ImoviaColors.gray,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: selected ? ImoviaColors.brandAccent : ImoviaColors.gray,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
          const SizedBox(height: 3),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: selected ? 18 : 0,
            height: 3,
            decoration: BoxDecoration(
              color: ImoviaColors.brandAccent,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ],
      ),
    ),
  );
}
