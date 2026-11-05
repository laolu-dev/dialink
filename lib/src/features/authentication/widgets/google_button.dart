import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dialink/src/core/network/result.dart';
import 'package:dialink/src/core/services/google_auth/google_auth.dart';
import 'package:dialink/src/features/authentication/controllers/authentication_controller.dart';
import 'package:dialink/src/shared/utils/toasts.dart';
import 'package:dialink/src/shared/widgets/buttons.dart';

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
      Toasts.error(
        "Google sign-in isn't set up in this build yet. Use your email for now.",
      );
      return;
    }

    final result = await ref
        .read(authenticationControllerProvider.notifier)
        .signInWithGoogle();
    switch (result) {
      case Success(value: AuthAction.accountCreated):
        Toasts.success("Welcome to Dialink. Your account is ready.");
      case Success():
        break;
      case Failure(:final value):
        Toasts.error(value.message);
    }
  }
}
