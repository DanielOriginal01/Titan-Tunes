import 'package:flutter/foundation.dart';

/// Configuration des endpoints backend Titan Tunes
class ApiConfig {
  static const String webOrLocalBaseUrl = 'http://localhost:8080/api/v1';
  static const String androidEmulatorBaseUrl = 'http://192.168.1.79:8080/api/v1';
  static const String swaggerDocUrl = 'http://localhost:8080/swagger-ui.html';

  /// Détection automatique de la base URL appropriée selon la plateforme
  static String get defaultBaseUrl {
    if (kIsWeb) {
      return webOrLocalBaseUrl;
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return androidEmulatorBaseUrl;
    }
    return webOrLocalBaseUrl;
  }

  /// Construit une URL complète pour un fichier media (audio, cover, photo).
  /// [relativePath] peut être une URL complète, un path relatif ou vide.
  /// [endpoint] est l'endpoint backend de fallback (ex: '/chansons/123/cover').
  static String resolveMediaUrl(String relativePath, {String endpoint = ''}) {
    if (relativePath.startsWith('http')) return relativePath;
    if (relativePath.isNotEmpty && endpoint.isEmpty) {
      return '$defaultBaseUrl/$relativePath';
    }
    if (endpoint.isNotEmpty) return '$defaultBaseUrl$endpoint';
    return '';
  }
}
