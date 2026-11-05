import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dialink/src/core/network/api_endpoints.dart';
import 'package:dialink/src/core/network/auth_interceptor.dart';
import 'package:dialink/src/core/storage/token_store.dart';
import 'package:dialink/src/data/auth/auth_repository.dart';

/// A server that never answers.
class _SilentServer implements HttpClientAdapter {
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    requests.add(options);
    return Completer<ResponseBody>().future;
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test('signing out is local first and does not wait on the server', () async {
    FlutterSecureStorage.setMockInitialValues({});
    final tokens = TokenStore();
    await tokens.save(accessToken: 'expired', refreshToken: 'refresh-0');
    final server = _SilentServer();
    final options = BaseOptions(baseUrl: 'https://api.test');
    final interceptor = AuthInterceptor(
      options: options,
      tokens: tokens,
      refreshPath: ApiEndpoints.refresh,
      publicPaths: ApiEndpoints.public,
    )..debugHttpClientAdapter = server;
    final dio = Dio(options)
      ..httpClientAdapter = server
      ..interceptors.add(interceptor);

    await AuthenticationRepository(
      dio,
      tokens,
    ).logout().timeout(const Duration(seconds: 1));
    await pumpEventQueue();

    expect(tokens.accessToken, isNull);
    expect(await tokens.readRefreshToken(), isNull);
    // One revoke, sent with the old refresh token and no expired bearer, so
    // nothing refreshes around it.
    expect(server.requests.map((r) => r.path), [ApiEndpoints.logout]);
    expect(server.requests.single.headers['Authorization'], isNull);
    expect(server.requests.single.data, {'refreshToken': 'refresh-0'});
  });
}
