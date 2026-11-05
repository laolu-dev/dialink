import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import 'package:dialink/src/core/network/result.dart';
import 'package:dialink/src/core/utils/extensions.dart';
import 'package:dialink/src/core/utils/validators.dart';
import 'package:dialink/src/features/authentication/controllers/authentication_controller.dart';
import 'package:dialink/src/shared/controllers/session_controller.dart';
import 'package:dialink/src/shared/utils/keyboard.dart';
import 'package:dialink/src/shared/utils/toasts.dart';
import 'package:dialink/src/shared/widgets/app_scaffold.dart';
import 'package:dialink/src/shared/widgets/app_text_field.dart';
import 'package:dialink/src/shared/widgets/buttons.dart';
import 'package:dialink/src/shared/widgets/headers.dart';

/// Confirms the email address with the code from the signup email.
///
/// Verification links open `/verify-email#token=…`; until the app handles
/// that link, the code is pasted here.
class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  final TextEditingController code = TextEditingController();
  final GlobalKey<FormState> _form = GlobalKey<FormState>();

  @override
  void dispose() {
    code.dispose();
    closeKeyboard();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(authenticationControllerProvider);
    final email = ref.watch(sessionProvider).value?.email;

    return AppScaffold(
      showBackButton: true,
      makeScrollable: true,
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ScreenHeader(
              title: "Confirm your email",
              subtitle:
                  "We emailed a code to ${email ?? "your address"}. "
                  "Enter it here to start booking. It works for 48 hours.",
            ),
            28.0.verticalSpacing,
            AppTextField(
              label: "Code",
              hint: "Paste the code from the email",
              icon: Iconsax.password_check,
              controller: code,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.oneTimeCode],
              validator: (value) =>
                  Validators.required(value!.trim(), field: "the code"),
            ),
            8.0.verticalSpacing,
            PrimaryButton(
              label: "Confirm",
              loading: controller.isLoading,
              onPressed: _verify,
            ),
            8.0.verticalSpacing,
            TextButton(
              onPressed: controller.isLoading
                  ? null
                  : () => _show(
                      ref
                          .read(authenticationControllerProvider.notifier)
                          .resendVerification(),
                    ),
              child: const Text("Send a new code"),
            ),
          ],
        ),
      ),
    );
  }

  void _verify() {
    if (!_form.currentState!.validate()) return;
    closeKeyboard();
    _show(
      ref
          .read(authenticationControllerProvider.notifier)
          .verifyEmail(code.text.trim()),
    );
  }

  Future<void> _show(Future<AuthResult> action) async {
    switch (await action) {
      case Success(value: AuthAction.emailVerified):
        Toasts.success("Your email is confirmed.");
        if (mounted) Navigator.of(context).pop();
      case Success():
        Toasts.success("We've sent a new code. Earlier codes no longer work.");
      case Failure(:final value):
        Toasts.error(value.message);
    }
  }
}
