import 'package:flutter/foundation.dart';
import 'package:titan_tunes/network/network_api_client.dart';

// ─────────────────────────────────────────────────────────────────────────────
// LoginResult — résultat de la connexion depuis le backend
// ─────────────────────────────────────────────────────────────────────────────
class LoginResult {
  final String token;
  final String? refreshToken;
  final String userId;
  final String username;
  final String? email;
  final String role;

  const LoginResult({
    required this.token,
    this.refreshToken,
    required this.userId,
    required this.username,
    this.email,
    required this.role,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// ApiAuthService — appels /auth/* vers le backend Spring Boot
// ─────────────────────────────────────────────────────────────────────────────
class ApiAuthService {
  final NetworkApiClient _client;
  ApiAuthService({required NetworkApiClient client}) : _client = client;

  // ── Connexion ─────────────────────────────────────────────────────────────
  /// Retourne [LoginResult] ou lance une [Exception] avec le message backend.
  Future<LoginResult> login({
    required String emailOuUsername,
    required String password,
  }) async {
    try {
      final response = await _client.post(
        '/auth/login',
        data: {'emailOuUsername': emailOuUsername, 'password': password},
      );

      final body = _parseBody(response.data);
      _assertSuccess(body, response.statusCode ?? 0);

      final data = body['data'] as Map<String, dynamic>? ?? body;
      final token = data['token'] as String? ?? '';
      if (token.isEmpty) throw Exception('Token absent dans la réponse.');

      final refreshToken = data['refreshToken'] as String?;

      return LoginResult(
        token: token,
        refreshToken: refreshToken,
        userId: (data['id'] ?? '').toString(),
        username: data['username'] as String? ?? emailOuUsername,
        email: data['email'] as String?,
        role: data['role'] as String? ?? 'ROLE_AUDITEUR',
      );
    } catch (e) {
      debugPrint('ApiAuthService.login error: $e');
      rethrow;
    }
  }

  // ── Inscription ──────────────────────────────────────────────────────────
  /// Retourne null si succès, sinon le message d'erreur.
  Future<String?> register({
    required String username,
    required String email,
    required String password,
    required String telephone,
    String role = 'ROLE_AUDITEUR',
    String? artistName,
  }) async {
    try {
      final response = await _client.post(
        '/auth/register',
        data: {
          'username': username,
          'email': email,
          'password': password,
          'telephone': telephone,
          'role': role,
          if (artistName != null && artistName.isNotEmpty)
            'artistName': artistName,
        },
      );

      final body = _parseBody(response.data);
      final code = response.statusCode ?? 0;
      if (code == 409) return 'Email ou nom d\'utilisateur déjà utilisé.';
      _assertSuccess(body, code);
      return null; // succès
    } catch (e) {
      debugPrint('ApiAuthService.register error: $e');
      return e.toString().replaceFirst('Exception: ', '');
    }
  }

  // ── Déconnexion (Blacklist token) ─────────────────────────────────────────
  Future<bool> logout() async {
    try {
      final response = await _client.post('/auth/logout');
      return (response.statusCode ?? 0) < 400;
    } catch (e) {
      debugPrint('ApiAuthService.logout error: $e');
      return false;
    }
  }

  // ── Refresh Token direct ──────────────────────────────────────────────────
  Future<Map<String, String>?> refreshTokens(String refreshToken) async {
    try {
      final response = await _client.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      final body = _parseBody(response.data);
      _assertSuccess(body, response.statusCode ?? 0);

      final data = body['data'] as Map<String, dynamic>? ?? body;
      final newAccessToken =
          data['accessToken'] as String? ?? data['token'] as String?;
      final newRefreshToken = data['refreshToken'] as String?;

      if (newAccessToken != null && newAccessToken.isNotEmpty) {
        return {
          'accessToken': newAccessToken,
          'refreshToken': newRefreshToken ?? refreshToken,
        };
      }
      return null;
    } catch (e) {
      debugPrint('ApiAuthService.refreshTokens error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> getCurrentUserProfile({String? userId}) async {
    try {
      // Essayer d'abord /auth/me (nouvel endpoint)
      final response = await _client.get('/auth/me');
      final body = _parseBody(response.data);
      _assertSuccess(body, response.statusCode ?? 0);

      final data = body['data'];
      if (data is Map<String, dynamic>) return data;
      if (data is Map) return Map<String, dynamic>.from(data);
      return body;
    } catch (e) {
      // Si /auth/me échoue (404 ou autre), essayer /utilisateurs/{id}
      if (userId != null && userId.isNotEmpty) {
        try {
          final response = await _client.get('/utilisateurs/$userId');
          final body = _parseBody(response.data);
          _assertSuccess(body, response.statusCode ?? 0);

          final data = body['data'];
          if (data is Map<String, dynamic>) return data;
          if (data is Map) return Map<String, dynamic>.from(data);
          return body;
        } catch (e2) {
          debugPrint('ApiAuthService.getUserProfile fallback error: $e2');
        }
      }
      debugPrint('ApiAuthService.getUserProfile error: $e');
      rethrow;
    }
  }

  // ── Mot de passe oublié ───────────────────────────────────────────────────
  Future<String?> forgotPassword({required String email}) async {
    try {
      final response = await _client.post(
        '/auth/forgot-password',
        data: {'email': email},
      );
      final body = _parseBody(response.data);
      _assertSuccess(body, response.statusCode ?? 0);
      return body['message'] as String? ?? 'Lien envoyé avec succès.';
    } catch (e) {
      debugPrint('ApiAuthService.forgotPassword error: $e');
      return e.toString().replaceFirst('Exception: ', '');
    }
  }

  // ── Reset mot de passe ────────────────────────────────────────────────────
  Future<String?> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await _client.post(
        '/auth/reset-password',
        data: {'token': token, 'password': newPassword},
      );
      final body = _parseBody(response.data);
      _assertSuccess(body, response.statusCode ?? 0);
      return null;
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    }
  }

  // ── OAuth2 callback (Google / Facebook) ──────────────────────────────────
  Future<LoginResult> oauth2Callback({
    required String accessToken,
    required String provider, // 'GOOGLE' | 'FACEBOOK'
    String role = 'ROLE_AUDITEUR',
    String? email,
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final response = await _client.post(
        '/auth/oauth2/callback',
        data: {
          'accessToken': accessToken,
          'provider': provider.toUpperCase(),
          'role': role,
          if (email?.isNotEmpty == true) 'email': email,
          if (displayName?.isNotEmpty == true) 'displayName': displayName,
          if (photoUrl?.isNotEmpty == true) 'photoUrl': photoUrl,
        },
      );

      final body = _parseBody(response.data);
      _assertSuccess(body, response.statusCode ?? 0);

      final data = (body['data'] as Map<String, dynamic>?) ?? body;
      final token = data['token'] as String? ?? '';
      if (token.isEmpty) throw Exception('Token absent dans la réponse OAuth2.');

      final refreshToken = data['refreshToken'] as String?;

      return LoginResult(
        token: token,
        refreshToken: refreshToken,
        userId: (data['id'] ?? '').toString(),
        username: data['username'] as String? ??
            (email?.split('@').first ?? provider),
        email: data['email'] as String? ?? email,
        role: data['role'] as String? ?? role,
      );
    } catch (e) {
      debugPrint('ApiAuthService.oauth2Callback error: $e');
      rethrow;
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Map<String, dynamic> _parseBody(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return {};
  }

  void _assertSuccess(Map<String, dynamic> body, int statusCode) {
    final success =
        body['success'] as bool? ?? (statusCode >= 200 && statusCode < 300);
    if (!success) {
      String msg = body['message'] as String? ?? 'Erreur $statusCode';
      final errors = body['errors'];
      if (errors is List && errors.isNotEmpty) {
        msg = '$msg: ${errors.join(', ')}';
      } else if (errors is Map && errors.isNotEmpty) {
        msg = '$msg: ${errors.entries.map((e) => '${e.key}: ${e.value}').join(', ')}';
      }
      throw Exception(msg);
    }
  }
}
