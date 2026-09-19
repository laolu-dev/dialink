import 'package:dialink/src/core/core.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';

part 'dio.g.dart';

@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  Dio dio = Dio(
    BaseOptions(
      baseUrl: "https://dia-link.onrender.com",
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  )..interceptors.addAll(
      [
        TalkerDioLogger(
          talker: AppConstants.instance.talker,
          settings: const TalkerDioLoggerSettings(),
        )
      ],
    );

  return dio;
}
