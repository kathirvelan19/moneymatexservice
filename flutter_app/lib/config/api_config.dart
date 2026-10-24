/// Centralized configuration for MoneyMateX backend API connectivity.
///
/// Supports compile-time configuration via `--dart-define=API_BASE_URL=https://YOUR-RENDER-SERVICE.onrender.com`
/// while maintaining safe defaults and URL normalization.
class ApiConfig {
  /// Default URL for the deployed Render service.
  /// Can be overridden at build time via `--dart-define=API_BASE_URL=https://moneymatexservice.onrender.com`
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://moneymatexservice.onrender.com',
  );

  /// Returns the base URL with whitespace and trailing slashes stripped.
  static String get normalizedBaseUrl {
    final trimmed = baseUrl.trim();
    if (trimmed.endsWith('/')) {
      return trimmed.substring(0, trimmed.length - 1);
    }
    return trimmed;
  }

  /// Returns the base URL guaranteed to point to the `/api` route prefix.
  ///
  /// If [normalizedBaseUrl] already ends with `/api`, it is returned directly;
  /// otherwise `/api` is cleanly appended.
  static String get apiBaseUrl {
    final base = normalizedBaseUrl;
    if (base.endsWith('/api')) {
      return base;
    }
    return '$base/api';
  }

  /// Timeout duration for HTTP requests to accommodate Render free-tier cold starts.
  static const Duration requestTimeout = Duration(seconds: 90);
}
