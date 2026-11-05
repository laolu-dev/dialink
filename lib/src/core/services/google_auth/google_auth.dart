import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Google Sign-In on the device, for an ID token the backend verifies.
///
/// The OAuth client IDs come from the flavour's env file, via [configure]:
/// - `GOOGLE_SERVER_CLIENT_ID`: the Web client, which the backend lists in
///   `GOOGLE_CLIENT_IDS`. The ID token is issued for it on both platforms.
/// - `GOOGLE_IOS_CLIENT_ID`: the iOS client. Its reversed ID must also be a
///   URL scheme in `ios/Runner/Info.plist` (see docs/environments.md).
///
/// Android also needs an Android client with the app's SHA-1 in Google Cloud.
class GoogleAuth {
  GoogleAuth._();
  static final GoogleAuth instance = GoogleAuth._();

  String _serverClientId = '';
  String _iosClientId = '';

  /// Called once at startup, before any sign-in.
  void configure({
    required String serverClientId,
    required String iosClientId,
  }) {
    _serverClientId = serverClientId;
    _iosClientId = iosClientId;
  }

  static bool get _isIOS => defaultTargetPlatform == TargetPlatform.iOS;

  bool get isConfigured =>
      _serverClientId.isNotEmpty && (!_isIOS || _iosClientId.isNotEmpty);

  Future<void>? _initialized;

  /// The ID token, or null when the user closed the Google sheet.
  Future<String?> idToken() async {
    _initialized ??= GoogleSignIn.instance.initialize(
      clientId: _isIOS ? _iosClientId : null,
      serverClientId: _serverClientId,
    );
    await _initialized;

    try {
      final account = await GoogleSignIn.instance.authenticate();
      return account.authentication.idToken;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    }
  }

  /// Lets the next sign-in pick a different Google account.
  Future<void> signOut() async {
    if (_initialized == null) return;
    await _initialized;
    await GoogleSignIn.instance.signOut();
  }
}
