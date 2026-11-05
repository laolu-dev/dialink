import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Holds the session tokens.
///
/// The access token lives only in memory. The refresh token is kept in the
/// platform secure store (Keychain / Android Keystore) so the session survives
/// a restart. Both are replaced together whenever the server issues a new pair.
///
/// The signed-in account is kept beside them, so the app can open on it at
/// launch, and is cleared with them.
class TokenStore {
  TokenStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _refreshTokenKey = 'dialink.refreshToken';
  static const _userKey = 'dialink.user';

  String? _accessToken;
  String? _refreshToken;
  bool _loaded = false;

  /// Fires when the session ends without the user asking: a refresh was refused
  /// because the account was signed out elsewhere, suspended or deactivated.
  final ValueNotifier<int> sessionExpired = ValueNotifier(0);

  String? get accessToken => _accessToken;

  Future<String?> readRefreshToken() async {
    if (!_loaded) {
      _refreshToken = await _storage.read(key: _refreshTokenKey);
      _loaded = true;
    }
    return _refreshToken;
  }

  Future<void> save({
    required String accessToken,
    required String refreshToken,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _loaded = true;
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<void> clear() async {
    _accessToken = null;
    _refreshToken = null;
    _loaded = true;
    await Future.wait([
      _storage.delete(key: _refreshTokenKey),
      _storage.delete(key: _userKey),
    ]);
  }

  /// The last signed-in account, as JSON, or null.
  Future<String?> readUser() => _storage.read(key: _userKey);

  Future<void> saveUser(String json) =>
      _storage.write(key: _userKey, value: json);

  Future<void> expire() async {
    await clear();
    sessionExpired.value++;
  }

  /// The signed-in user's id: the `sub` claim of the access token.
  String? get userId => _claims?['sub'] as String?;

  /// `PATIENT`, `PROVIDER` or `ADMIN`.
  String? get role => _claims?['role'] as String?;

  Map<String, dynamic>? get _claims {
    final parts = _accessToken?.split('.');
    if (parts == null || parts.length != 3) return null;
    try {
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      return jsonDecode(payload) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}
