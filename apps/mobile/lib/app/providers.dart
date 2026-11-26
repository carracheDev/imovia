import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../core/network/api_client.dart';
import '../core/network/api_config.dart';
import '../core/security/session_token_store.dart';
import '../features/foundation/data/api_health_repository.dart';
import '../features/foundation/domain/api_health.dart';
import '../features/account/data/account_repository.dart';
import '../features/home/data/home_repository.dart';
import '../features/properties/data/property_detail_repository.dart';
import '../features/properties/data/favorites_repository.dart';
import '../features/search/data/search_repository.dart';

final sessionTokenStoreProvider = Provider<SessionTokenStore>((ref) {
  return SecureSessionTokenStore(const FlutterSecureStorage());
});

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 8),
      sendTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 12),
      headers: const {
        Headers.acceptHeader: Headers.jsonContentType,
        Headers.contentTypeHeader: Headers.jsonContentType,
      },
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final requestUri = options.uri;
        final apiBaseUri = ApiConfig.baseUri;
        if (requestUri.origin != apiBaseUri.origin ||
            !requestUri.path.startsWith(apiBaseUri.path)) {
          handler.reject(
            DioException(
              requestOptions: options,
              message: 'API client cannot send requests outside its base path.',
            ),
          );
          return;
        }
        final token = await ref.read(sessionTokenStoreProvider).readToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ),
  );

  ref.onDispose(() => dio.close(force: true));
  return dio;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(dioProvider));
});

final apiHealthRepositoryProvider = Provider<ApiHealthRepository>((ref) {
  return RemoteApiHealthRepository(ref.watch(apiClientProvider));
});

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  return RemoteAccountRepository(ref.watch(apiClientProvider));
});

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return RemoteHomeRepository(ref.watch(apiClientProvider));
});

final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  return RemoteSearchRepository(ref.watch(apiClientProvider));
});

final propertyDetailRepositoryProvider = Provider<PropertyDetailRepository>((
  ref,
) {
  return RemotePropertyDetailRepository(ref.watch(apiClientProvider));
});

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return RemoteFavoritesRepository(ref.watch(apiClientProvider));
});

final homeListingsProvider = FutureProvider.autoDispose<List<HomeProperty>>((
  ref,
) {
  return ref.watch(homeRepositoryProvider).loadRecent();
});

final propertyImageUrlProvider = FutureProvider.autoDispose
    .family<String, PropertyMediaRef>((ref, media) {
      return ref.watch(homeRepositoryProvider).loadMediaUrl(media);
    });
