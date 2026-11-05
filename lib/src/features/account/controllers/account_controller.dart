import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:dialink/src/core/network/api_exception.dart';
import 'package:dialink/src/core/network/result.dart';
import 'package:dialink/src/data/auth/auth_repository.dart';
import 'package:dialink/src/data/users/models/patient_profile_model.dart';
import 'package:dialink/src/data/users/user_repository.dart';
import 'package:dialink/src/features/authentication/controllers/authentication_controller.dart';
import 'package:dialink/src/shared/controllers/session_controller.dart';
part 'account_controller.g.dart';

/// The outcome of an account change, for the screen to react to.
enum AccountAction { passwordChanged, profileSaved, signedOutEverywhere }

typedef AccountResult = Result<AccountAction, ClientException>;

/// Changes to the signed-in patient's account. The state tracks the last
/// one, for spinners; each change returns its outcome to the screen that
/// started it, as in [AuthenticationController].
@riverpod
class AccountController extends _$AccountController {
  @override
  FutureOr<AccountAction?> build() => null;

  Future<AccountResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) => _run((auth, users, session) async {
    final result = await auth.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
    return switch (result) {
      Success() => const Success(AccountAction.passwordChanged),
      Failure(:final value) => Failure(value),
    };
  });

  Future<AccountResult> updateAccount(
    String userId, {
    required Map<String, dynamic> account,
    required PatientProfileModel profile,
  }) => _run((auth, users, session) async {
    final updated = await users.updateUser(userId, account);
    switch (updated) {
      case Failure(:final value):
        return Failure(value);
      case Success(:final value):
        session.setUser(value);
    }

    final saved = await users.savePatientProfile(userId, profile);
    if (saved case Failure(:final value)) return Failure(value);

    if (ref.mounted) ref.invalidate(patientProfileProvider(userId));
    return const Success(AccountAction.profileSaved);
  });

  Future<AccountResult> logoutAll() => _run((auth, users, session) async {
    final result = await auth.logoutAll();
    if (result case Failure(:final value)) return Failure(value);

    await session.logout();
    return const Success(AccountAction.signedOutEverywhere);
  });

  /// Reads the dependencies before the first `await`, so a change that
  /// outlives its screen can still finish, and only sets the state while
  /// this controller is mounted.
  Future<AccountResult> _run(
    Future<AccountResult> Function(
      AuthenticationRepository auth,
      UserRepository users,
      Session session,
    )
    action,
  ) async {
    final auth = ref.read(authRepoProvider);
    final users = ref.read(userRepoProvider);
    final session = ref.read(sessionProvider.notifier);
    state = const AsyncLoading();

    final result = await action(auth, users, session);

    if (ref.mounted) {
      state = switch (result) {
        Success(:final value) => AsyncData(value),
        Failure(:final value) => AsyncError(value, StackTrace.current),
      };
    }
    return result;
  }
}
