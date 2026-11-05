import 'dart:async';
import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:dialink/src/core/network/api_client.dart';
import 'package:dialink/src/core/network/api_exception.dart';
import 'package:dialink/src/core/services/google_auth/google_auth.dart';
import 'package:dialink/src/core/storage/token_store.dart';
import 'package:dialink/src/data/auth/auth_repository.dart';
import 'package:dialink/src/data/users/models/user_model.dart';
import 'package:dialink/src/data/users/user_repository.dart';
import 'package:dialink/src/shared/utils/toasts.dart';
part 'session_controller.g.dart';

/// The signed-in patient, or null when signed out.
///
/// On launch it restores the session from the stored refresh token. If the
/// account was saved last time, it opens on that straight away and checks
/// with the server in the background. It goes back to null when the user
/// signs out or the server ends the session.
@Riverpod(keepAlive: true)
class Session extends _$Session {
  AuthenticationRepository get _repository => ref.read(authRepoProvider);
  TokenStore get _tokens => ref.read(tokenStoreProvider);

  @override
  Future<UserModel?> build() async {
    final tokens = ref.watch(tokenStoreProvider);
    void onExpired() {
      state = const AsyncData(null);
      Toasts.error("Your session ended. Please sign in again.");
    }

    tokens.sessionExpired.addListener(onExpired);
    ref.onDispose(() => tokens.sessionExpired.removeListener(onExpired));

    listenSelf((_, next) {
      final user = next.value;
      if (user == null) return;
      tokens.saveUser(jsonEncode(user.toJson())).ignore();
    });

    if (await tokens.readRefreshToken() == null) return null;

    final cached = await _cachedUser(tokens);
    if (cached != null) {
      unawaited(_revalidate(cached));
      return cached;
    }
    return _restore();
  }

  /// Refreshes the tokens and loads the account. Null if the server refused
  /// the session; throws if it could not be reached.
  Future<UserModel?> _restore() async {
    final tokens = _tokens;
    if (!await ref.read(authInterceptorProvider).refresh()) {
      // Refused: the tokens are gone and the user signs in again. Otherwise
      // the server could not be reached, so keep them and let the user retry.
      if (await tokens.readRefreshToken() == null) return null;
      throw const ClientException(
        message: "Couldn't reach Dialink. Check your connection and try again.",
      );
    }
    return _loadUser();
  }

  /// Replaces the saved account with the server's, unless the user has moved
  /// on (signed out or in as someone else) meanwhile.
  Future<void> _revalidate(UserModel cached) async {
    try {
      final user = await _restore();
      if (ref.mounted && state.value?.id == cached.id) state = AsyncData(user);
    } catch (_) {
      // Offline: keep the saved account. Requests refresh the tokens again.
    }
  }

  static Future<UserModel?> _cachedUser(TokenStore tokens) async {
    try {
      final json = await tokens.readUser();
      if (json == null) return null;
      return UserModel.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Called after the tokens are stored by a sign-in or password change.
  /// Returns whether the account could be loaded.
  Future<bool> signedIn() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_loadUser);
    return !state.hasError;
  }

  /// Re-reads the account, e.g. after the email address was confirmed.
  /// Returns whether it worked; on failure the current account is kept.
  Future<bool> reload() async {
    try {
      final user = await _loadUser();
      if (user != null) state = AsyncData(user);
      return true;
    } catch (_) {
      return false;
    }
  }

  void setUser(UserModel user) => state = AsyncData(user);

  /// The server accepted the code: show it as confirmed even if re-reading
  /// the account fails.
  Future<void> emailVerified() async {
    if (await reload()) return;
    final user = state.value;
    if (user != null) state = AsyncData(user.copyWith(emailVerified: true));
  }

  Future<void> logout() async {
    await _repository.logout();
    unawaited(GoogleAuth.instance.signOut().catchError((Object _) {}));
    state = const AsyncData(null);
  }

  Future<UserModel?> _loadUser() async {
    final id = _tokens.userId;
    if (id == null) return null;

    final result = await ref.read(userRepoProvider).getUser(id);
    return result.fold(
      (user) => user,
      (error) => error.isUnauthorized ? null : throw error,
    );
  }
}
