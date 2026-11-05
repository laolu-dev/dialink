import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import 'package:dialink/src/app/router/app_router.dart';
import 'package:dialink/src/core/network/result.dart';
import 'package:dialink/src/core/utils/extensions.dart';
import 'package:dialink/src/core/utils/validators.dart';
import 'package:dialink/src/features/authentication/controllers/authentication_controller.dart';
import 'package:dialink/src/shared/utils/keyboard.dart';
import 'package:dialink/src/shared/utils/toasts.dart';
import 'package:dialink/src/shared/widgets/app_scaffold.dart';
import 'package:dialink/src/shared/widgets/app_text_field.dart';
import 'package:dialink/src/shared/widgets/buttons.dart';
import 'package:dialink/src/shared/widgets/headers.dart';

/// Asks for a reset email, then takes the code from it and a new password.
///
/// Reset links open `/reset-password#token=…`; until the app handles that
/// link, the code is pasted here.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key, this.email});

  final String? email;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  late final TextEditingController email = TextEditingController(
    text: widget.email,
  );
  final TextEditingController code = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();

  final GlobalKey<FormState> _form = GlobalKey<FormState>();

  bool _emailSent = false;

  @override
  void dispose() {
    email.dispose();
    code.dispose();
    password.dispose();
    confirmPassword.dispose();
    closeKeyboard();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(authenticationControllerProvider);

    return AppScaffold(
      showBackButton: true,
      makeScrollable: true,
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ScreenHeader(
              title: "Reset password",
              subtitle: switch (_emailSent) {
                false => "We'll email you a code to reset your password.",
                true =>
                  "If an account exists for ${email.text.trim()}, we've emailed a code. It works for 30 minutes.",
              },
            ),
            28.0.verticalSpacing,
            if (!_emailSent)
              AppTextField(
                label: "Email",
                hint: "name@example.com",
                icon: Iconsax.sms,
                controller: email,
                inputType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                validator: (value) => Validators.email(value!),
              )
            else ...[
              AppTextField(
                label: "Code",
                hint: "Paste the code from the email",
                icon: Iconsax.password_check,
                controller: code,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.oneTimeCode],
                validator: (value) =>
                    Validators.required(value!.trim(), field: "the code"),
              ),
              AppPasswordField(
                label: "New password",
                hint: "At least 12 characters",
                controller: password,
                isNewPassword: true,
                textInputAction: TextInputAction.next,
                validator: (value) => Validators.password(value!),
              ),
              AppPasswordField(
                label: "Confirm password",
                hint: "Re-enter password",
                controller: confirmPassword,
                isNewPassword: true,
                textInputAction: TextInputAction.done,
                onSubmitted: _submit,
                validator: (value) => Validators.confirmPassword(
                  value,
                  oldPassword: password.text,
                ),
              ),
            ],
            8.0.verticalSpacing,
            PrimaryButton(
              label: _emailSent ? "Set password" : "Send code",
              loading: controller.isLoading,
              onPressed: _submit,
            ),
            if (_emailSent) ...[
              8.0.verticalSpacing,
              TextButton(
                onPressed: controller.isLoading
                    ? null
                    : () => setState(() => _emailSent = false),
                child: const Text("Send a new code"),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    closeKeyboard();

    final notifier = ref.read(authenticationControllerProvider.notifier);
    final result = _emailSent
        ? await notifier.resetPassword(
            token: code.text.trim(),
            password: password.text,
          )
        : await notifier.forgotPassword(email.text.trim());

    switch (result) {
      case Success(value: AuthAction.passwordReset):
        Toasts.success("Password changed. Sign in with your new password.");
        // Signed out now: the session listener may already have gone back
        // to the start, taking this screen with it.
        if (mounted) {
          context.router.popUntil((route) => route.isFirst);
        }
      case Success():
        if (mounted) setState(() => _emailSent = true);
      case Failure(:final value):
        Toasts.error(value.message);
    }
  }
}
