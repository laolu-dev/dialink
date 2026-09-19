import 'package:dialink/src/core/api/exception.dart';
import 'package:dialink/src/core/api/response/response.dart';
import 'package:dialink/src/core/api/result.dart';

typedef FutureResultOf<T> = Future<Result<ApiResponse<T>, ClientException>>;
