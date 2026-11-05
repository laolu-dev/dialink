import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:dialink/src/core/network/api_exception.dart';
import 'package:dialink/src/core/network/result.dart';
import 'package:dialink/src/core/services/google_auth/google_auth.dart';
import 'package:dialink/src/data/auth/auth_repository.dart';
import 'package:dialink/src/data/auth/models/token_model.dart';
import 'package:dialink/src/shared/controllers/session_controller.dart';
part 'authentication_controller.g.dart';

/// The outcome of an account action, for the screen to react to.
enum AuthAction {
  signedIn,
  googleCancelled,
  accountCreated,
  emailVerified,
  verificationSent,
  resetEmailSent,
  passwordReset,
}

typedef AuthResult = Result<AuthAction, ClientException>;

/// Runs account actions. The state tracks the last one, for spinners.
///
/// Each action returns its outcome to the screen that started it, which shows
/// the feedback. Listening to the state instead would also reach screens
/// further down the stack, which Riverpod pauses and replays later.
@riverpod
class AuthenticationController extends _$AuthenticationController {
  @override
  FutureOr<AuthAction?> build() => null;

  /// Signs up, then signs in with the same details.
  Future<AuthResult> createAccount(Map<String, dynamic> payload) =>
      _run((repo, session) async {
        final created = await repo.createAccount(payload);
        if (created case Failure(:final value)) return Failure(value);

        return _signIn(
          repo,
          session,
          payload['email'] as String,
          payload['password'] as String,
          AuthAction.accountCreated,
        );
      });

  Future<AuthResult> login({required String email, required String password}) =>
      _run(
        (repo, session) =>
            _signIn(repo, session, email, password, AuthAction.signedIn),
      );

  /// A new Google user gets a patient account with a confirmed address.
  Future<AuthResult> signInWithGoogle() => _run((repo, session) async {
    final String? idToken;
    try {
      idToken = await GoogleAuth.instance.idToken();
    } catch (_) {
      return const Failure(
        ClientException(message: "Couldn't open Google sign-in. Try again."),
      );
    }
    if (idToken == null) return const Success(AuthAction.googleCancelled);

    final result = await repo.googleSignIn(idToken);
    switch (result) {
      case Failure(:final value):
        return Failure(value);
      case Success(value: final created):
        if (!await session.signedIn()) return _notLoaded;
        return Success(
          created ? AuthAction.accountCreated : AuthAction.signedIn,
        );
    }
  });

  Future<AuthResult> verifyEmail(String token) => _run((repo, session) async {
    final result = await repo.verifyEmail(token);
    if (result case Failure(:final value)) return Failure(value);

    await session.emailVerified();
    return const Success(AuthAction.emailVerified);
  });

  Future<AuthResult> resendVerification() => _run((repo, session) async {
    final result = await repo.resendVerification();
    switch (result) {
      case Success():
        return const Success(AuthAction.verificationSent);
      case Failure(:final value) when value.type == 'email-already-verified':
        await session.emailVerified();
        return const Success(AuthAction.emailVerified);
      case Failure(:final value):
        return Failure(value);
    }
  });

  Future<AuthResult> forgotPassword(String email) =>
      _run((repo, session) async {
        final result = await repo.forgotPassword(email);
        return _as(result, AuthAction.resetEmailSent);
      });

  /// Ends every session, this one included.
  Future<AuthResult> resetPassword({
    required String token,
    required String password,
  }) => _run((repo, session) async {
    final result = await repo.resetPassword(token: token, password: password);
    if (result case Failure(:final value)) return Failure(value);

    // The tokens are gone; a signed-in user must not stay shown as one.
    await session.logout();
    return const Success(AuthAction.passwordReset);
  });

  /// Reads the dependencies before the first `await`, so an action that
  /// outlives its screen can still finish, and only sets the state while
  /// this controller is mounted.
  Future<AuthResult> _run(
    Future<AuthResult> Function(AuthenticationRepository repo, Session session)
    action,
  ) async {
    final repo = ref.read(authRepoProvider);
    final session = ref.read(sessionProvider.notifier);
    state = const AsyncLoading();

    final result = await action(repo, session);

    if (ref.mounted) {
      state = switch (result) {
        Success(:final value) => AsyncData(value),
        Failure(:final value) => AsyncError(value, StackTrace.current),
      };
    }
    return result;
  }

  static const AuthResult _notLoaded = Failure(
    ClientException(
      message:
          "Signed in, but your account couldn't be loaded. Please try again.",
    ),
  );

  static AuthResult _as(
    Result<void, ClientException> result,
    AuthAction action,
  ) => switch (result) {
    Success() => Success(action),
    Failure(:final value) => Failure(value),
  };

  static Future<AuthResult> _signIn(
    AuthenticationRepository repo,
    Session session,
    String email,
    String password,
    AuthAction action,
  ) async {
    final result = await repo.login(email: email, password: password);

    switch (result) {
      case Failure(:final value):
        return Failure(value);
      case Success(value: MfaRequired()):
        return const Failure(
          ClientException(
            message:
                'This app is for patients. Providers and admins sign in with the Dialink staff app.',
          ),
        );
      case Success(value: TokenPair()):
        if (!await session.signedIn()) return _notLoaded;
        return Success(action);
    }
  }
}
