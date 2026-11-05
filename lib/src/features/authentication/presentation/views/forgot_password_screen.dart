import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import 'package:dialink/src/core/core.dart';

import 'package:dialink/src/widgets/common.dart';
import 'package:dialink/src/widgets/custom_textfield.dart';
import 'package:dialink/src/widgets/custom_scaffold.dart';

import 'package:dialink/src/features/authentication/presentation/controller/authentication_controller.dart';

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
    AppConstants.instance.closeKeyboard();
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
              CustomTextfield(
                label: "Email",
                hint: "name@example.com",
                icon: Iconsax.sms,
                controller: email,
                inputType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                validator: (value) => AppConstants.emailValidator(value!),
              )
            else ...[
              CustomTextfield(
                label: "Code",
                hint: "Paste the code from the email",
                icon: Iconsax.password_check,
                controller: code,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.oneTimeCode],
                validator: (value) => AppConstants.requiredValidator(
                  value!.trim(),
                  field: "the code",
                ),
              ),
              CustomPasswordTextfield(
                label: "New password",
                hint: "At least 12 characters",
                controller: password,
                isNewPassword: true,
                textInputAction: TextInputAction.next,
                validator: (value) => AppConstants.passwordValidator(value!),
              ),
              CustomPasswordTextfield(
                label: "Confirm password",
                hint: "Re-enter password",
                controller: confirmPassword,
                isNewPassword: true,
                textInputAction: TextInputAction.done,
                onSubmitted: _submit,
                validator: (value) => AppConstants.confirmPasswordValidator(
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
    AppConstants.instance.closeKeyboard();

    final notifier = ref.read(authenticationControllerProvider.notifier);
    final result = _emailSent
        ? await notifier.resetPassword(
            token: code.text.trim(),
            password: password.text,
          )
        : await notifier.forgotPassword(email.text.trim());

    switch (result) {
      case Success(value: AuthAction.passwordReset):
        AppConstants.instance.showSuccess(
          "Password changed. Sign in with your new password.",
        );
        // Signed out now: the session listener may already have gone back
        // to the start, taking this screen with it.
        if (mounted) {
          context.router.popUntil((route) => route.isFirst);
        }
      case Success():
        if (mounted) setState(() => _emailSent = true);
      case Failure(:final value):
        AppConstants.instance.showError(value.message);
    }
  }
}
