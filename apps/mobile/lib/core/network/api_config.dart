import 'dart:io';

const _configuredApiBaseUrl = String.fromEnvironment('API_BASE_URL');

abstract final class ApiConfig {
  static Uri get baseUri {
    final configured = _configuredApiBaseUrl.trim();
    final value = configured.isNotEmpty
        ? configured
        : Platform.isAndroid
        ? 'http://10.0.2.2:3000/api'
        : 'http://127.0.0.1:3000/api';
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw const FormatException('API_BASE_URL must be an absolute URL.');
    }
    final normalizedPath = uri.path.endsWith('/') ? uri.path : '${uri.path}/';
    return uri.replace(path: normalizedPath);
  }

  static String get baseUrl => baseUri.toString();
}
