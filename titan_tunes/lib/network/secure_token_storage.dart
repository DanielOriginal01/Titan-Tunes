import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureTokenStorage {
  static const _accessTokenKey = 'access_token';
  static const _accessTokenExpiryKey = 'access_token_expiry';
  static const _refreshTokenKey = 'refresh_token';

  final FlutterSecureStorage _storage;

  const SecureTokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> writeAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  Future<String?> readAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  Future<void> deleteAccessToken() async {
    await _storage.delete(key: _accessTokenKey);
  }

  Future<void> writeRefreshToken(String refreshToken) async {
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<String?> readRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: _refreshTokenKey);
  }

  Future<void> writeAccessTokenExpiry(DateTime expiry) async {
    await _storage.write(
      key: _accessTokenExpiryKey,
      value: expiry.toIso8601String(),
    );
  }

  Future<DateTime?> readAccessTokenExpiry() async {
    final value = await _storage.read(key: _accessTokenExpiryKey);
    if (value == null) return null;
    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteAccessTokenExpiry() async {
    await _storage.delete(key: _accessTokenExpiryKey);
  }

  Future<void> clearAll() async {
    await Future.wait([
      deleteAccessToken(),
      deleteAccessTokenExpiry(),
      deleteRefreshToken(),
    ]);
  }
}
