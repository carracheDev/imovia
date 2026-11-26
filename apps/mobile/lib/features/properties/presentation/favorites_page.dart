import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/providers.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/imovia_colors.dart';
import '../../home/data/home_repository.dart';
import 'property_listing_card.dart';

class FavoritesPage extends ConsumerStatefulWidget {
  const FavoritesPage({super.key});

  @override
  ConsumerState<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends ConsumerState<FavoritesPage> {
  List<HomeProperty> _items = [];
  bool _loading = true;
  bool _signedIn = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final token = await ref.read(sessionTokenStoreProvider).readToken();
    if (!mounted) return;
    if (token == null || token.isEmpty) {
      setState(() {
        _signedIn = false;
        _items = [];
        _loading = false;
      });
      return;
    }
    setState(() => _signedIn = true);
    try {
      final page = await ref.read(favoritesRepositoryProvider).load();
      if (mounted) setState(() => _items = page.items);
    } on ApiException {
      if (mounted) {
        setState(() => _error = 'Impossible de charger tes favoris.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _remove(HomeProperty property) async {
    try {
      await ref.read(favoritesRepositoryProvider).remove(property.id);
      if (mounted) {
        setState(() => _items.removeWhere((item) => item.id == property.id));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Annonce retirée des favoris.')),
        );
      }
    } on ApiException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible de modifier ce favori.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: ImoviaColors.page,
    appBar: AppBar(
      title: Text('Mes favoris', style: Theme.of(context).textTheme.titleLarge),
    ),
    body: _body(context),
    bottomNavigationBar: _navigation(context),
  );

  Widget _body(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (!_signedIn) {
      return _StateMessage(
        icon: Icons.lock_outline_rounded,
        title: 'Connecte-toi pour retrouver tes favoris',
        body: 'Tes annonces enregistrées seront réunies ici.',
        action: FilledButton(
          onPressed: () => context.push<void>('/login?returnTo=/favorites'),
          child: const Text('Se connecter'),
        ),
      );
    }
    if (_error != null) {
      return _StateMessage(
        icon: Icons.cloud_off_outlined,
        title: _error!,
        body: 'Vérifie ta connexion puis réessaie.',
        action: OutlinedButton.icon(
          onPressed: _load,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Réessayer'),
        ),
      );
    }
    if (_items.isEmpty) {
      return _StateMessage(
        icon: Icons.favorite_border_rounded,
        title: 'Aucun favori pour le moment',
        body: 'Enregistre une annonce pour la retrouver facilement.',
        action: FilledButton.icon(
          onPressed: () => context.go('/'),
          icon: const Icon(Icons.search_rounded),
          label: const Text('Explorer les annonces'),
        ),
      );
    }
    return RefreshIndicator(
      color: ImoviaColors.brandAccent,
      onRefresh: _load,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
        itemCount: _items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 15),
        itemBuilder: (context, index) {
          final property = _items[index];
          return PropertyListingCard(
            property: property,
            onTap: property.isAvailable
                ? () => context.push<void>(
                    '/properties/${Uri.encodeComponent(property.slug)}',
                  )
                : () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cette annonce n’est plus disponible.'),
                    ),
                  ),
            onFavorite: () => _remove(property),
          );
        },
      ),
    );
  }

  Widget _navigation(BuildContext context) => SafeArea(
    top: false,
    child: Container(
      margin: const EdgeInsets.fromLTRB(14, 4, 14, 10),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: ImoviaColors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _Nav(
            icon: Icons.home_outlined,
            label: 'Accueil',
            onTap: () => context.go('/'),
          ),
          _Nav(
            icon: Icons.search_rounded,
            label: 'Recherche',
            onTap: () => context.push<void>('/search'),
          ),
          _Nav(
            icon: Icons.favorite_rounded,
            label: 'Favoris',
            selected: true,
            onTap: () {},
          ),
          _Nav(
            icon: Icons.person_outline_rounded,
            label: 'Profil',
            onTap: () => context.push<void>('/profile'),
          ),
        ],
      ),
    ),
  );
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.icon,
    required this.title,
    required this.body,
    this.action,
  });
  final IconData icon;
  final String title;
  final String body;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: const BoxDecoration(
              color: ImoviaColors.brandAccentSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 34, color: ImoviaColors.brandAccent),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            body,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: ImoviaColors.gray),
          ),
          if (action != null) ...[const SizedBox(height: 18), action!],
        ],
      ),
    ),
  );
}

class _Nav extends StatelessWidget {
  const _Nav({
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: selected ? ImoviaColors.brandAccent : ImoviaColors.gray,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: selected ? ImoviaColors.brandAccent : ImoviaColors.gray,
              fontSize: 12,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ],
      ),
    ),
  );
}
