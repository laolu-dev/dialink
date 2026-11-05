import 'dart:async';

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:dialink/src/core/network/api_client.dart';
import 'package:dialink/src/core/network/api_endpoints.dart';
import 'package:dialink/src/core/network/result.dart';
import 'package:dialink/src/core/storage/token_store.dart';
import 'package:dialink/src/data/auth/models/token_model.dart';
import 'package:dialink/src/data/users/models/user_model.dart';
part 'auth_repository.g.dart';

class AuthenticationRepository {
  const AuthenticationRepository(this._api, this._tokens);
  final Dio _api;
  final TokenStore _tokens;

  /// Creates a patient account. It returns no tokens: sign in next.
  FutureResultOf<UserModel> createAccount(Map<String, dynamic> payload) =>
      guard(() async {
        final response = await _api.post(ApiEndpoints.signup, data: payload);
        return UserModel.fromJson(response.data);
      });

  /// Signs in and stores the tokens. Providers and admins get [MfaRequired].
  FutureResultOf<LoginOutcome> login({
    required String email,
    required String password,
  }) => guard(() async {
    final response = await _api.post(
      ApiEndpoints.login,
      data: {"email": email, "password": password},
    );
    final outcome = LoginOutcome.fromJson(response.data);
    if (outcome is TokenPair) await _saveTokens(outcome);
    return outcome;
  });

  /// Signs in with a Google ID token and stores the tokens. Returns whether
  /// it created a new patient account.
  FutureResultOf<bool> googleSignIn(String idToken) => guard(() async {
    final response = await _api.post(
      ApiEndpoints.google,
      data: {"idToken": idToken},
    );
    await _saveTokens(TokenPair.fromJson(response.data));
    return response.statusCode == 201;
  });

  FutureResultOf<void> verifyEmail(String token) => guard(() async {
    await _api.post(ApiEndpoints.verifyEmail, data: {"token": token});
  });

  FutureResultOf<void> resendVerification() => guard(() async {
    await _api.post(ApiEndpoints.resendVerification);
  });

  /// Always succeeds whether or not the account exists.
  FutureResultOf<void> forgotPassword(String email) => guard(() async {
    await _api.post(ApiEndpoints.forgotPassword, data: {"email": email});
  });

  /// Ends every session: the user signs in again afterwards.
  FutureResultOf<void> resetPassword({
    required String token,
    required String password,
  }) => guard(() async {
    await _api.post(
      ApiEndpoints.resetPassword,
      data: {"token": token, "password": password},
    );
    await _tokens.clear();
  });

  /// Every other session ends; this one continues with the new tokens.
  FutureResultOf<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) => guard(() async {
    final response = await _api.post(
      ApiEndpoints.changePassword,
      data: {"currentPassword": currentPassword, "newPassword": newPassword},
    );
    await _saveTokens(TokenPair.fromJson(response.data));
  });

  /// Signs out on this device. The local tokens are cleared first, so this
  /// returns without waiting for the server; revoking the refresh token there
  /// carries on in the background and its failure is ignored.
  Future<void> logout() async {
    final refreshToken = await _tokens.readRefreshToken();
    await _tokens.clear();
    if (refreshToken == null) return;

    unawaited(
      _api
          .post(ApiEndpoints.logout, data: {"refreshToken": refreshToken})
          .then((_) {}, onError: (Object _) {}),
    );
  }

  FutureResultOf<void> logoutAll() => guard(() async {
    await _api.post(ApiEndpoints.logoutAll);
    await _tokens.clear();
  });

  Future<void> _saveTokens(TokenPair tokens) => _tokens.save(
    accessToken: tokens.accessToken,
    refreshToken: tokens.refreshToken,
  );
}

@riverpod
AuthenticationRepository authRepo(Ref ref) {
  return AuthenticationRepository(
    ref.watch(dioProvider),
    ref.watch(tokenStoreProvider),
  );
}
