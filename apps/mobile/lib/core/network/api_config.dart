const _configuredApiBaseUrl = String.fromEnvironment('API_BASE_URL');
const _defaultApiBaseUrl = 'https://imovia-1.onrender.com/api';

abstract final class ApiConfig {
  static Uri get baseUri {
    final configured = _configuredApiBaseUrl.trim();
    final value = configured.isNotEmpty ? configured : _defaultApiBaseUrl;
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw const FormatException('API_BASE_URL must be an absolute URL.');
    }
    final normalizedPath = uri.path.endsWith('/') ? uri.path : '${uri.path}/';
    return uri.replace(path: normalizedPath);
  }

  static String get baseUrl => baseUri.toString();
}
