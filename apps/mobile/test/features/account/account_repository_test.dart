import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imovia_mobile/core/network/api_client.dart';
import 'package:imovia_mobile/features/account/data/account_repository.dart';

void main() {
  test(
    'uses the API routes for OTP, profile, notifications, and logout',
    () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test/api/'));
      final calls = <RequestOptions>[];
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            calls.add(options);
            final data = switch (options.uri.path) {
              '/api/auth/otp/verify' => {'sessionToken': 'session-test'},
              '/api/auth/me' => {
                'id': 'user-1',
                'email': 'sam@example.test',
                'firstName': 'Sam',
                'lastName': 'Test',
                'roles': ['SEEKER'],
                'accountStatus': 'ACTIVE',
              },
              '/api/users/me/profile' => {
                'id': 'user-1',
                'email': 'sam@example.test',
                'firstName': 'Sami',
                'lastName': 'Test',
                'roles': ['SEEKER'],
              },
              '/api/users/me/notifications' => {
                'items': [
                  {
                    'id': 'notification-1',
                    'type': 'LISTING_APPROVED',
                    'title': 'Annonce publiée',
                    'message': 'Votre annonce est en ligne.',
                    'createdAt': '2026-01-01T10:00:00.000Z',
                    'readAt': null,
                    'propertyId': 'property-1',
                    'property': {'slug': 'villa-test'},
                  },
                ],
                'unread': 1,
                'pagination': {
                  'page': 1,
                  'pageSize': 30,
                  'total': 1,
                  'totalPages': 1,
                },
              },
              _ => <String, dynamic>{'message': 'ok'},
            };
            handler.resolve(
              Response<Map<String, dynamic>>(
                requestOptions: options,
                statusCode: 200,
                data: data,
              ),
            );
          },
        ),
      );
      final repository = RemoteAccountRepository(ApiClient(dio));

      await repository.requestCode(' sam@example.test ');
      expect(
        await repository.verifyCode('sam@example.test', '123456'),
        'session-test',
      );
      final user = await repository.currentUser();
      expect(user.firstName, 'Sam');
      final updated = await repository.updateProfile(
        firstName: 'Sami',
        lastName: 'Test',
      );
      expect(updated.firstName, 'Sami');
      final notifications = await repository.notifications();
      expect(notifications.unread, 1);
      expect(notifications.items.single.propertySlug, 'villa-test');
      await repository.markNotificationRead('notification-1');
      await repository.logout();

      expect(calls.map((call) => call.method), [
        'POST',
        'POST',
        'GET',
        'PATCH',
        'GET',
        'PATCH',
        'POST',
      ]);
      expect(calls.map((call) => call.uri.path), [
        '/api/auth/otp/request',
        '/api/auth/otp/verify',
        '/api/auth/me',
        '/api/users/me/profile',
        '/api/users/me/notifications',
        '/api/users/me/notifications/notification-1/read',
        '/api/auth/logout',
      ]);
      dio.close(force: true);
    },
  );
}
