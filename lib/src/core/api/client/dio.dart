import 'package:dialink/src/core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';

export 'auth_interceptor.dart';

part 'dio.g.dart';

/// Override with `--dart-define=API_BASE_URL=https://...` for other environments.
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://dialink-backend-dev.vercel.app',
);

@Riverpod(keepAlive: true)
TokenStore tokenStore(Ref ref) => TokenStore();

final BaseOptions _options = BaseOptions(
  baseUrl: "$apiBaseUrl/api/v1",
  contentType: Headers.jsonContentType,
  // The dev backend can take ~20s to answer after a quiet spell.
  connectTimeout: const Duration(seconds: 30),
  receiveTimeout: const Duration(seconds: 30),
);

@Riverpod(keepAlive: true)
AuthInterceptor authInterceptor(Ref ref) => AuthInterceptor(
  options: _options,
  tokens: ref.watch(tokenStoreProvider),
  refreshPath: ApiEndpoints.refresh,
  publicPaths: ApiEndpoints.public,
);

@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  Dio dio = Dio(_options);

  dio.interceptors.addAll([
    ref.watch(authInterceptorProvider),
    // Method, path and status only: bodies and headers carry tokens,
    // passwords and health information.
    if (kDebugMode)
      TalkerDioLogger(
        talker: AppConstants.instance.talker,
        settings: const TalkerDioLoggerSettings(
          printRequestData: false,
          printRequestHeaders: false,
          printResponseData: false,
          printResponseHeaders: false,
          printResponseMessage: false,
          printErrorData: false,
          printErrorHeaders: false,
          printRequestExtra: false,
        ),
      ),
  ]);

  return dio;
}
