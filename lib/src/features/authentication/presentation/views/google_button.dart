import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dialink/src/core/core.dart';
import 'package:dialink/src/core/services/google_auth.dart';
import 'package:dialink/src/widgets/common.dart';

import 'package:dialink/src/features/authentication/presentation/controller/authentication_controller.dart';

/// "Continue with Google". Signing in opens home from the session listener.
class GoogleButton extends ConsumerWidget {
  const GoogleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SecondaryButton(
      label: "Continue with Google",
      icon: Icons.g_mobiledata_rounded,
      onPressed: ref.watch(authenticationControllerProvider).isLoading
          ? null
          : () => _signIn(ref),
    );
  }

  Future<void> _signIn(WidgetRef ref) async {
    if (!GoogleAuth.instance.isConfigured) {
      AppConstants.instance.showError(
        "Google sign-in isn't set up in this build yet. Use your email for now.",
      );
      return;
    }

    final result = await ref
        .read(authenticationControllerProvider.notifier)
        .signInWithGoogle();
    switch (result) {
      case Success(value: AuthAction.accountCreated):
        AppConstants.instance.showSuccess(
          "Welcome to Dialink. Your account is ready.",
        );
      case Success():
        break;
      case Failure(:final value):
        AppConstants.instance.showError(value.message);
    }
  }
}
