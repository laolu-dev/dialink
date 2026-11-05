import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:dialink/src/core/services/local_cache.dart';

/// Adds the bearer token and recovers from an expired one.
///
/// On a `401` it refreshes once and retries the request. Refreshes are
/// single-flight: the server treats two refreshes with the same token as theft
/// and ends every session, so concurrent requests wait on the one in progress.
/// If the refresh is refused, the stored tokens are cleared and
/// [TokenStore.sessionExpired] fires.
///
/// [publicPaths] are sent without a token and never trigger a refresh: the
/// server rejects an expired token even on public endpoints, and refreshing
/// around a logout would rotate the very token being revoked.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required BaseOptions options,
    required this.tokens,
    required this.refreshPath,
    this.publicPaths = const {},
  }) : _dio = Dio(options);

  final TokenStore tokens;
  final String refreshPath;
  final Set<String> publicPaths;

  /// A bare client, without this interceptor, for refreshes and retries.
  final Dio _dio;
  Completer<bool>? _refreshing;

  static const _retriedKey = 'auth.retried';
  static const _authenticatedKey = 'auth.authenticated';

  bool _isPublic(RequestOptions options) => publicPaths.contains(options.path);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_isPublic(options)) return handler.next(options);

    var token = tokens.accessToken;

    // After a restart only the refresh token is known: get an access token first.
    if (token == null && await tokens.readRefreshToken() != null) {
      if (await refresh()) token = tokens.accessToken;
    }

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
      options.extra[_authenticatedKey] = true;
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;
    final shouldRefresh =
        err.response?.statusCode == 401 &&
        options.extra[_authenticatedKey] == true &&
        options.extra[_retriedKey] != true;

    if (!shouldRefresh) return handler.next(err);

    // Another request refreshed while this one was in flight: retry with the
    // new token rather than rotating again.
    final current = tokens.accessToken;
    final alreadyRefreshed =
        current != null &&
        options.headers['Authorization'] != 'Bearer $current';

    if (!alreadyRefreshed && !await refresh()) return handler.next(err);

    try {
      options.extra[_retriedKey] = true;
      options.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
      handler.resolve(await _dio.fetch(options));
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  @visibleForTesting
  set debugHttpClientAdapter(HttpClientAdapter adapter) =>
      _dio.httpClientAdapter = adapter;

  /// Exchanges the refresh token for a new pair. Returns whether it worked.
  ///
  /// Never throws: callers wait on it, so any failure must still complete it.
  Future<bool> refresh() {
    final inFlight = _refreshing;
    if (inFlight != null) return inFlight.future;

    final completer = _refreshing = Completer<bool>();
    _doRefresh()
        .catchError((Object _) => false)
        .then(completer.complete)
        .whenComplete(() => _refreshing = null);
    return completer.future;
  }

  Future<bool> _doRefresh() async {
    final refreshToken = await tokens.readRefreshToken();
    if (refreshToken == null) return false;

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        refreshPath,
        data: {'refreshToken': refreshToken},
      );
      final body = response.data;
      final accessToken = body?['accessToken'];
      final newRefreshToken = body?['refreshToken'];
      if (accessToken is! String || newRefreshToken is! String) return false;

      await tokens.save(
        accessToken: accessToken,
        refreshToken: newRefreshToken,
      );
      return true;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      // Refused: the session is over. Other failures (offline, cold start)
      // keep the tokens so the next attempt can succeed.
      if (status == 401 || status == 400) await tokens.expire();
      return false;
    }
  }
}
