import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dialink/src/core/network/auth_interceptor.dart';
import 'package:dialink/src/core/storage/token_store.dart';

/// A fake server: `/auth/refresh` issues token pairs, `/auth/logout` is
/// public, every other path answers 200 only to the current access token.
class _FakeServer implements HttpClientAdapter {
  _FakeServer({this.refuseRefresh = false, this.malformedRefresh = false});

  final bool refuseRefresh;
  final bool malformedRefresh;
  int refreshCalls = 0;
  String validAccessToken = 'expired';

  /// The `Authorization` header of each request, by path.
  final Map<String, List<Object?>> authByPath = {};

  /// Runs before a protected path answers, e.g. to refresh mid-flight.
  Future<void> Function()? beforeAnswer;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    authByPath
        .putIfAbsent(options.path, () => [])
        .add(options.headers['Authorization']);

    if (options.path == '/auth/refresh') {
      refreshCalls++;
      if (malformedRefresh) return _json(200, {'unexpected': true});
      if (refuseRefresh) {
        return _json(401, {
          'type': 'urn:dialink:problem:invalid-refresh-token',
        });
      }
      validAccessToken = 'access-$refreshCalls';
      return _json(200, {
        'accessToken': validAccessToken,
        'refreshToken': 'refresh-$refreshCalls',
      });
    }

    if (options.path == '/auth/logout') return _json(204, {});

    final auth = options.headers['Authorization'];
    await beforeAnswer?.call();
    beforeAnswer = null;
    return auth == 'Bearer $validAccessToken'
        ? _json(200, {'ok': true})
        : _json(401, {'type': 'about:blank'});
  }

  ResponseBody _json(int status, Map<String, dynamic> body) =>
      ResponseBody.fromString(
        jsonEncode(body),
        status,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );

  @override
  void close({bool force = false}) {}
}

/// A secure store that cannot be written to, e.g. a locked keychain.
class _BrokenStore extends TokenStore {
  @override
  Future<void> save({
    required String accessToken,
    required String refreshToken,
  }) => Future.error(StateError('keychain locked'));
}

void main() {
  late TokenStore tokens;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    tokens = TokenStore();
  });

  (Dio, _FakeServer) client(_FakeServer server) {
    final options = BaseOptions(baseUrl: 'https://api.test');
    final interceptor = AuthInterceptor(
      options: options,
      tokens: tokens,
      refreshPath: '/auth/refresh',
      publicPaths: const {'/auth/refresh', '/auth/logout'},
    );
    // The interceptor's own client must hit the same fake server.
    interceptor.debugHttpClientAdapter = server;
    final dio = Dio(options)
      ..httpClientAdapter = server
      ..interceptors.add(interceptor);
    return (dio, server);
  }

  test('refreshes once for concurrent 401s and retries each request', () async {
    await tokens.save(accessToken: 'expired', refreshToken: 'refresh-0');
    final (dio, server) = client(_FakeServer());
    server.validAccessToken = 'not-yet-issued';

    final responses = await Future.wait([
      dio.get('/a'),
      dio.get('/b'),
      dio.get('/c'),
    ]);

    expect(responses.map((r) => r.statusCode), everyElement(200));
    expect(server.refreshCalls, 1);
    expect(tokens.accessToken, 'access-1');
    expect(await tokens.readRefreshToken(), 'refresh-1');
  });

  test('gets an access token first after a restart', () async {
    FlutterSecureStorage.setMockInitialValues({
      'dialink.refreshToken': 'refresh-0',
    });
    tokens = TokenStore();
    final (dio, server) = client(_FakeServer());

    final response = await dio.get('/a');

    expect(response.statusCode, 200);
    expect(server.refreshCalls, 1);
  });

  test('a refused refresh clears the session and reports it', () async {
    await tokens.save(accessToken: 'expired', refreshToken: 'refresh-0');
    final (dio, server) = client(_FakeServer(refuseRefresh: true));
    server.validAccessToken = 'not-yet-issued';
    var expired = 0;
    tokens.sessionExpired.addListener(() => expired++);

    await expectLater(dio.get('/a'), throwsA(isA<DioException>()));

    expect(expired, 1);
    expect(tokens.accessToken, isNull);
    expect(await tokens.readRefreshToken(), isNull);
  });

  test('a 401 from a signed-out request is not retried', () async {
    final (dio, server) = client(_FakeServer());

    await expectLater(dio.get('/a'), throwsA(isA<DioException>()));
    expect(server.refreshCalls, 0);
  });

  test(
    'an unexpected refresh response fails the refresh instead of hanging',
    () async {
      await tokens.save(accessToken: 'expired', refreshToken: 'refresh-0');
      final (dio, server) = client(_FakeServer(malformedRefresh: true));
      server.validAccessToken = 'not-yet-issued';

      await expectLater(
        dio.get('/a').timeout(const Duration(seconds: 2)),
        throwsA(isA<DioException>()),
      );
      // Not refused, so the session is kept for the next attempt.
      expect(await tokens.readRefreshToken(), 'refresh-0');
    },
  );

  test(
    'a 401 after another request refreshed retries without refreshing',
    () async {
      await tokens.save(accessToken: 'old', refreshToken: 'refresh-0');
      final (dio, server) = client(_FakeServer());
      server.validAccessToken = 'access-new';
      server.beforeAnswer = () =>
          tokens.save(accessToken: 'access-new', refreshToken: 'refresh-new');

      final response = await dio.get('/a');

      expect(response.statusCode, 200);
      expect(server.refreshCalls, 0);
      expect(server.authByPath['/a'], ['Bearer old', 'Bearer access-new']);
    },
  );

  test('public paths get no token and never trigger a refresh', () async {
    await tokens.save(accessToken: 'expired', refreshToken: 'refresh-0');
    final (dio, server) = client(_FakeServer());

    await dio.post('/auth/logout', data: {'refreshToken': 'refresh-0'});

    expect(server.authByPath['/auth/logout'], [null]);
    expect(server.refreshCalls, 0);
  });

  test('a refresh that fails outside the network still finishes', () async {
    await tokens.save(accessToken: 'expired', refreshToken: 'refresh-0');
    final broken = _BrokenStore();
    final interceptor = AuthInterceptor(
      options: BaseOptions(baseUrl: 'https://api.test'),
      tokens: broken,
      refreshPath: '/auth/refresh',
    )..debugHttpClientAdapter = _FakeServer();
    // The broken store still reads the refresh token saved above.
    FlutterSecureStorage.setMockInitialValues({
      'dialink.refreshToken': 'refresh-0',
    });

    final first = interceptor.refresh();
    final second = interceptor.refresh();

    expect(
      await Future.wait([first, second]).timeout(const Duration(seconds: 2)),
      [false, false],
    );
    // Not stuck: the next attempt starts a new refresh.
    expect(identical(interceptor.refresh(), first), isFalse);
  });
}
