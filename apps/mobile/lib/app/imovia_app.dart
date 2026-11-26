import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../core/theme/imovia_theme.dart';
import '../features/home/presentation/home_page.dart';
import '../features/properties/presentation/property_detail_page.dart';
import '../features/properties/presentation/favorites_page.dart';
import '../features/properties/presentation/contact_page.dart';
import '../features/account/presentation/sign_in_page.dart';
import '../features/account/presentation/profile_page.dart';
import '../features/account/presentation/notifications_page.dart';
import '../features/account/presentation/settings_page.dart';
import '../features/account/presentation/advertiser_setup_page.dart';
import '../features/search/domain/search_criteria.dart';
import '../features/search/presentation/search_page.dart';
import '../features/search/presentation/results_page.dart';

class ImoviaApp extends StatelessWidget {
  const ImoviaApp({super.key});

  static final _router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => HomePage(
          onSearch: (query) => _openSearch(
            context,
            SearchCriteria(query: query.isEmpty ? null : query),
          ),
          onCategory: (category, operation) => _openSearch(
            context,
            SearchCriteria(category: category, operationType: operation),
          ),
          onFilters: () => _openSearch(context, const SearchCriteria()),
          onProperty: (property) => context.push<void>(
            '/properties/${Uri.encodeComponent(property.slug)}',
          ),
          onFavorites: () => context.push<void>('/favorites'),
          onOpenProfile: () => context.push<void>('/profile'),
          onOpenNotifications: () => context.push<void>('/notifications'),
          onPublishProperty: () => context.push<void>('/advertiser/setup'),
        ),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => SearchPage(
          initialCriteria: state.extra is SearchCriteria
              ? state.extra! as SearchCriteria
              : const SearchCriteria(),
        ),
      ),
      GoRoute(
        path: '/results',
        builder: (context, state) => ResultsPage(
          criteria: state.extra is SearchCriteria
              ? state.extra! as SearchCriteria
              : const SearchCriteria(),
        ),
      ),
      GoRoute(
        path: '/properties/:slug/contact',
        builder: (context, state) =>
            ContactPage(slug: state.pathParameters['slug']!),
      ),
      GoRoute(
        path: '/properties/:slug',
        builder: (context, state) =>
            PropertyDetailPage(slug: state.pathParameters['slug']!),
      ),
      GoRoute(
        path: '/favorites',
        builder: (context, state) => const FavoritesPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) =>
            SignInPage(returnTo: state.uri.queryParameters['returnTo'] ?? '/'),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsPage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/advertiser/setup',
        builder: (context, state) => const AdvertiserSetupPage(),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'IMOVIA',
      debugShowCheckedModeBanner: false,
      theme: ImoviaTheme.light,
      routerConfig: _router,
    );
  }

  static void _openSearch(BuildContext context, SearchCriteria criteria) =>
      context.push<void>('/search', extra: criteria);
}
