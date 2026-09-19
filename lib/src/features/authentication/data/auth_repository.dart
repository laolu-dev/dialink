import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:dialink/src/core/api/exception.dart';
import 'package:dialink/src/core/core.dart';
import 'package:dialink/src/features/authentication/models/user_model.dart';

part 'auth_repository.g.dart';

class AuthenticationRepository {
  const AuthenticationRepository(this._api);
  final Dio _api;

  FutureResultOf<String> createAccount(Map<String, dynamic> payload) async {
    try {
      final response =
          await _api.post(ApiEndpoints.createAccount, data: payload);

      final result = ApiResponse<String>.fromJson(
        response.data,
        (json) => (json as Map<String, dynamic>)["id"],
      );
      return Success(result);
    } catch (e) {
      final exception = ClientException.handleException(e);
      return Failure(exception);
    }
  }

  FutureResultOf<UserModel> login(Map<String, dynamic> payload) async {
    try {
      final response = await _api.post(ApiEndpoints.login, data: payload);

      final result = ApiResponse<UserModel>.fromJson(
        response.data,
        (json) => UserModel.fromJson(json as Map<String, dynamic>),
      );

      return Success(result);
    } catch (e) {
      final exception = ClientException.handleException(e);
      return Failure(exception);
    }
  }
}

@riverpod
AuthenticationRepository authRepo(Ref ref) {
  final dio = ref.watch(dioProvider);
  return AuthenticationRepository(dio);
}
