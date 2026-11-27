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
    final firstName = ref
        .watch(currentAccountProvider)
        .asData
        ?.value
        ?.firstName;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: ImoviaColors.page,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: ImoviaColors.ink,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: ImoviaColors.ink,
      ),
      child: Scaffold(
        body: SafeArea(
          top: true,
          bottom: false,
          child: RefreshIndicator(
            color: ImoviaColors.ink,
            onRefresh: () async {
              ref.invalidate(currentAccountProvider);
              await ref.refresh(homeListingsProvider.future);
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _HomeHeader(
                    controller: _searchController,
                    firstName: firstName,
                    onSubmit: _submitSearch,
                    onFilter: _openFilters,
                    onNotifications: _openNotifications,
                    onProfile:
                        widget.onOpenProfile ??
                        () => context.push<void>('/profile'),
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
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Annonces récentes',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Découvrez les dernières opportunités immobilières',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: ImoviaColors.gray),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () => _category(null, null),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Voir tout'),
                                SizedBox(width: 5),
                                Icon(Icons.arrow_forward_rounded, size: 18),
                              ],
                            ),
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
            if (label == 'Recherche') {
              _openFilters();
              return;
            }
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

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.controller,
    required this.firstName,
    required this.onSubmit,
    required this.onFilter,
    required this.onNotifications,
    required this.onProfile,
    required this.onPublish,
  });

  final TextEditingController controller;
  final String? firstName;
  final VoidCallback onSubmit;
  final VoidCallback onFilter;
  final VoidCallback onNotifications;
  final VoidCallback onProfile;
  final VoidCallback onPublish;

  String get _initials {
    final parts = (firstName ?? '').trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '';
    return parts.take(2).map((part) => part[0]).join().toUpperCase();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            InkWell(
              onTap: onProfile,
              borderRadius: BorderRadius.circular(28),
              child: CircleAvatar(
                radius: 23,
                backgroundColor: ImoviaColors.brandAccentSoft,
                child: _initials.isEmpty
                    ? const Icon(
                        Icons.person_outline_rounded,
                        color: ImoviaColors.brandAccent,
                      )
                    : Text(
                        _initials,
                        style: const TextStyle(
                          color: ImoviaColors.brandAccent,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    firstName == null || firstName!.trim().isEmpty
                        ? 'Bonjour 👋'
                        : 'Bonjour, ${firstName!.trim()}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    'Bienvenue sur IMOVIA',
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: ImoviaColors.gray),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onPublish,
              tooltip: 'Publier un bien',
              style: IconButton.styleFrom(
                backgroundColor: ImoviaColors.white,
                foregroundColor: ImoviaColors.brandAccent,
                fixedSize: const Size(44, 44),
              ),
              icon: const Icon(Icons.add_home_work_outlined),
            ),
            const SizedBox(width: 6),
            IconButton(
              onPressed: onNotifications,
              tooltip: 'Notifications',
              style: IconButton.styleFrom(
                backgroundColor: ImoviaColors.white,
                foregroundColor: ImoviaColors.ink,
                fixedSize: const Size(44, 44),
              ),
              icon: const Icon(Icons.notifications_none_rounded),
            ),
          ],
        ),
        const SizedBox(height: 22),
        ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFEAF7EC), Color(0xFFE3F2E7)],
              ),
            ),
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Positioned(
                  top: -56,
                  right: -50,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: const BoxDecoration(
                      color: Color(0x36FFFFFF),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  top: 34,
                  right: -58,
                  child: Container(
                    width: 142,
                    height: 142,
                    decoration: const BoxDecoration(
                      color: Color(0x2678C98C),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontSize: 27,
                                height: 1.12,
                                letterSpacing: -.7,
                              ),
                          children: const [
                            TextSpan(text: 'Trouvez votre bien\nidéal au '),
                            TextSpan(
                              text: 'Bénin',
                              style: TextStyle(color: ImoviaColors.brandAccent),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: 34,
                        height: 4,
                        decoration: BoxDecoration(
                          color: ImoviaColors.sun,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Maisons, appartements et terrains près de vous.',
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(color: ImoviaColors.charcoal),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 58,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: ImoviaColors.white,
                          borderRadius: BorderRadius.circular(19),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x120B0B0B),
                              blurRadius: 14,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 10),
                            const Icon(
                              Icons.search_rounded,
                              color: ImoviaColors.gray,
                              size: 23,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: controller,
                                textInputAction: TextInputAction.search,
                                onSubmitted: (_) => onSubmit(),
                                decoration: const InputDecoration(
                                  hintText: 'Bien, ville ou quartier…',
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  filled: false,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 46,
                              height: 46,
                              child: FilledButton(
                                onPressed: onFilter,
                                style: FilledButton.styleFrom(
                                  backgroundColor: ImoviaColors.brandAccent,
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: const Icon(Icons.tune_rounded, size: 21),
                              ),
                            ),
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
      ],
    ),
  );
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
    color: const Color(0xFFF0F8F1),
    borderRadius: BorderRadius.circular(18),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 84,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFDDEBE0)),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: ImoviaColors.brandAccentSoft,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 24, color: ImoviaColors.brandAccent),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge
                  ?.copyWith(color: ImoviaColors.ink, fontSize: 13),
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
    padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
    decoration: BoxDecoration(
      color: ImoviaColors.white,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: ImoviaColors.border),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0C0B0B0B),
          blurRadius: 12,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      children: [
        SizedBox(
          width: 70,
          height: 70,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: const BoxDecoration(
                  color: ImoviaColors.brandAccentSoft,
                  shape: BoxShape.circle,
                ),
              ),
              const Icon(
                Icons.home_outlined,
                size: 42,
                color: ImoviaColors.brandAccent,
              ),
              Positioned(
                right: 1,
                bottom: 4,
                child: Container(
                  width: 31,
                  height: 31,
                  decoration: const BoxDecoration(
                    color: ImoviaColors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.search_rounded,
                    size: 25,
                    color: ImoviaColors.ink,
                  ),
                ),
              ),
              const Positioned(
                right: -4,
                top: 1,
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: 14,
                  color: ImoviaColors.brandAccent,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Aucune annonce pour le moment',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          'Les nouvelles annonces apparaîtront ici dès leur publication.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: ImoviaColors.gray),
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
