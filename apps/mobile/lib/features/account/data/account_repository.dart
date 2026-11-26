import '../../../core/network/api_client.dart';

class AccountUser {
  const AccountUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.roles,
    required this.accountStatus,
  });

  final String id;
  final String? email;
  final String? firstName;
  final String? lastName;
  final List<String> roles;
  final String accountStatus;

  factory AccountUser.fromJson(Map<String, dynamic> json) => AccountUser(
    id: json['id'] as String? ?? '',
    email: json['email'] as String?,
    firstName: json['firstName'] as String?,
    lastName: json['lastName'] as String?,
    roles: (json['roles'] as List? ?? const []).whereType<String>().toList(),
    accountStatus: json['accountStatus'] as String? ?? 'ACTIVE',
  );
}

class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.read,
    this.propertyId,
    this.propertySlug,
  });

  final String id;
  final String type;
  final String title;
  final String message;
  final DateTime? createdAt;
  final bool read;
  final String? propertyId;
  final String? propertySlug;

  factory NotificationItem.fromJson(Map<String, dynamic> json) =>
      NotificationItem(
        id: json['id'] as String? ?? '',
        type: json['type'] as String? ?? '',
        title: json['title'] as String? ?? '',
        message: json['message'] as String? ?? '',
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
        read: json['readAt'] != null,
        propertyId: json['propertyId'] as String?,
        propertySlug: json['property'] is Map<String, dynamic>
            ? (json['property'] as Map<String, dynamic>)['slug'] as String?
            : null,
      );
}

class NotificationPage {
  const NotificationPage({required this.items, required this.unread});
  final List<NotificationItem> items;
  final int unread;
}

abstract interface class AccountRepository {
  Future<void> requestCode(String email);
  Future<String> verifyCode(String email, String code);
  Future<AccountUser> currentUser();
  Future<AccountUser> updateProfile({
    required String firstName,
    required String lastName,
    String? role,
    String? displayName,
    String? businessName,
  });
  Future<void> logout();
  Future<NotificationPage> notifications();
  Future<void> markNotificationRead(String id);
}

class RemoteAccountRepository implements AccountRepository {
  const RemoteAccountRepository(this._api);
  final ApiClient _api;

  @override
  Future<void> requestCode(String email) async {
    await _api.postJson('auth/otp/request', body: {'email': email.trim()});
  }

  @override
  Future<String> verifyCode(String email, String code) async {
    final response = await _api.postJson(
      'auth/otp/verify',
      body: {'email': email.trim(), 'code': code.trim()},
    );
    final token = response['sessionToken'];
    if (token is! String || token.isEmpty) {
      throw const ApiException('The API returned an invalid session token.');
    }
    return token;
  }

  @override
  Future<AccountUser> currentUser() async =>
      AccountUser.fromJson(await _api.getJson('auth/me'));

  @override
  Future<AccountUser> updateProfile({
    required String firstName,
    required String lastName,
    String? role,
    String? displayName,
    String? businessName,
  }) async => AccountUser.fromJson(
    await _api.patchJson(
      'users/me/profile',
      body: {
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'role': ?role,
        if (displayName != null && displayName.trim().isNotEmpty)
          'displayName': displayName.trim(),
        if (businessName != null && businessName.trim().isNotEmpty)
          'businessName': businessName.trim(),
      },
    ),
  );

  @override
  Future<void> logout() async {
    await _api.postJson('auth/logout');
  }

  @override
  Future<NotificationPage> notifications() async {
    final response = await _api.getJson(
      'users/me/notifications',
      queryParameters: const {'page': 1, 'pageSize': 30},
    );
    final rawItems = response['items'];
    final unread = response['unread'];
    if (rawItems is! List ||
        !rawItems.every((item) => item is Map<String, dynamic>) ||
        unread is! int) {
      throw const ApiException('The API returned invalid notifications.');
    }
    return NotificationPage(
      items: rawItems
          .cast<Map<String, dynamic>>()
          .map(NotificationItem.fromJson)
          .toList(growable: false),
      unread: unread,
    );
  }

  @override
  Future<void> markNotificationRead(String id) async {
    await _api.patchJson(
      'users/me/notifications/${Uri.encodeComponent(id)}/read',
    );
  }
}
