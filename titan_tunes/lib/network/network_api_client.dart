import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:titan_tunes/network/secure_token_storage.dart';

class TokenVault {
  final SecureTokenStorage _storage;
  String? accessToken;
  String? refreshToken;
  DateTime? accessTokenExpiry;

  TokenVault({SecureTokenStorage? storage})
      : _storage = storage ?? const SecureTokenStorage();

  bool get hasToken =>
      accessToken?.isNotEmpty == true && !isAccessTokenExpired;

  bool get hasRefreshToken => refreshToken?.isNotEmpty == true;

  bool get isAccessTokenExpired =>
      accessTokenExpiry != null && DateTime.now().isAfter(accessTokenExpiry!);

  Future<void> initialize() async {
    accessToken = await _storage.readAccessToken();
    refreshToken = await _storage.readRefreshToken();
    accessTokenExpiry = await _storage.readAccessTokenExpiry();
    if (isAccessTokenExpired && !hasRefreshToken) {
      await clear();
    }
  }

  Future<void> setTokens({
    required String token,
    String? refreshToken,
    DateTime? expiry,
  }) async {
    accessToken = token;
    accessTokenExpiry = expiry;
    await _storage.writeAccessToken(token);

    if (refreshToken != null && refreshToken.isNotEmpty) {
      this.refreshToken = refreshToken;
      await _storage.writeRefreshToken(refreshToken);
    }
    if (expiry != null) {
      await _storage.writeAccessTokenExpiry(expiry);
    }
  }

  Future<void> setToken(String token, {DateTime? expiry}) async {
    await setTokens(token: token, expiry: expiry);
  }

  Future<void> clear() async {
    accessToken = null;
    refreshToken = null;
    accessTokenExpiry = null;
    await _storage.clearAll();
  }
}

class NetworkApiClient {
  final Dio _dio;
  final Dio _refreshDio;
  final TokenVault tokenVault;
  final String baseUrl;
  Completer<bool>? _refreshCompleter;

  NetworkApiClient({required this.tokenVault, required this.baseUrl})
      : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 30),
            sendTimeout: const Duration(seconds: 15),
            responseType: ResponseType.json,
            validateStatus: (status) => status != null && status < 500,
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          ),
        ),
        _refreshDio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 15),
            responseType: ResponseType.json,
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          ),
        ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (tokenVault.accessToken?.isNotEmpty == true) {
            options.headers['Authorization'] =
                'Bearer ${tokenVault.accessToken}';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) async {
          // Si le backend renvoie un code 401 dans une réponse 200/401 avec validateStatus < 500
          if (response.statusCode == 401 && tokenVault.hasRefreshToken) {
            final refreshed = await _tryRefreshToken();
            if (refreshed) {
              try {
                final newOptions = response.requestOptions;
                newOptions.headers['Authorization'] =
                    'Bearer ${tokenVault.accessToken}';
                final retryRes = await _dio.fetch(newOptions);
                return handler.resolve(retryRes);
              } catch (e) {
                return handler.next(response);
              }
            }
          }
          return handler.next(response);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401 && tokenVault.hasRefreshToken) {
            final refreshed = await _tryRefreshToken();
            if (refreshed) {
              try {
                final options = error.requestOptions;
                options.headers['Authorization'] =
                    'Bearer ${tokenVault.accessToken}';
                final response = await _dio.fetch(options);
                return handler.resolve(response);
              } catch (e) {
                return handler.next(error);
              }
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  Dio get rawDio => _dio;

  Future<bool> _tryRefreshToken() async {
    if (_refreshCompleter != null) {
      return await _refreshCompleter!.future;
    }

    final currentRefreshToken = tokenVault.refreshToken;
    if (currentRefreshToken == null || currentRefreshToken.isEmpty) {
      return false;
    }

    _refreshCompleter = Completer<bool>();

    try {
      final response = await _refreshDio.post(
        '/auth/refresh',
        data: {'refreshToken': currentRefreshToken},
      );

      final data = response.data;
      if (response.statusCode == 200 && data != null) {
        final Map<String, dynamic> body =
            data is Map<String, dynamic> ? data : Map<String, dynamic>.from(data as Map);

        final tokenData = body['data'] as Map<String, dynamic>? ?? body;
        final newAccessToken =
            tokenData['accessToken'] as String? ?? tokenData['token'] as String?;
        final newRefreshToken = tokenData['refreshToken'] as String?;

        if (newAccessToken != null && newAccessToken.isNotEmpty) {
          await tokenVault.setTokens(
            token: newAccessToken,
            refreshToken: newRefreshToken ?? currentRefreshToken,
            expiry: DateTime.now().add(const Duration(hours: 1)),
          );
          _refreshCompleter!.complete(true);
          _refreshCompleter = null;
          return true;
        }
      }
    } catch (e) {
      debugPrint('Error while refreshing token: $e');
    }

    await tokenVault.clear();
    _refreshCompleter!.complete(false);
    _refreshCompleter = null;
    return false;
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _dio.get<T>(path, queryParameters: queryParameters, options: options);

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _dio.post<T>(path,
          data: data, queryParameters: queryParameters, options: options);

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _dio.put<T>(path,
          data: data, queryParameters: queryParameters, options: options);

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _dio.delete<T>(path,
          data: data, queryParameters: queryParameters, options: options);
}
