import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dialink/src/app/router/routes.dart';
import 'package:dialink/src/app/theme/app_palette.dart';
import 'package:dialink/src/core/network/result.dart';
import 'package:dialink/src/core/utils/extensions.dart';
import 'package:dialink/src/core/utils/validators.dart';
import 'package:dialink/src/features/account/controllers/account_controller.dart';
import 'package:dialink/src/shared/utils/keyboard.dart';
import 'package:dialink/src/shared/utils/toasts.dart';
import 'package:dialink/src/shared/widgets/app_scaffold.dart';
import 'package:dialink/src/shared/widgets/app_text_field.dart';
import 'package:dialink/src/shared/widgets/buttons.dart';
import 'package:go_router/go_router.dart';

/// Changing the password signs out every other device; this one stays signed in.
class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final TextEditingController current = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();

  final GlobalKey<FormState> _form = GlobalKey<FormState>();

  @override
  void dispose() {
    current.dispose();
    password.dispose();
    confirmPassword.dispose();
    closeKeyboard();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(accountControllerProvider);

    return AppScaffold(
      title: "Change password",
      makeScrollable: true,
      child: AutofillGroup(
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Other devices will be signed out. This one stays signed in.",
                style: context.textTheme.bodyMedium!.copyWith(
                  color: context.palette.muted,
                ),
              ),
              20.0.verticalSpacing,
              AppPasswordField(
                label: "Current password",
                controller: current,
                textInputAction: TextInputAction.next,
                validator: (value) =>
                    Validators.required(value!, field: "your current password"),
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
                label: "Confirm new password",
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
              8.0.verticalSpacing,
              PrimaryButton(
                label: "Change password",
                loading: controller.isLoading,
                onPressed: _submit,
              ),
              12.0.verticalSpacing,
              TextButton(
                onPressed: () => context.push(Routes.forgotPassword),
                child: const Text("Forgotten your current password?"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    closeKeyboard();

    final result = await ref
        .read(accountControllerProvider.notifier)
        .changePassword(
          currentPassword: current.text,
          newPassword: password.text,
        );
    switch (result) {
      case Success():
        Toasts.success("Password changed. Other devices have been signed out.");
        if (mounted) Navigator.of(context).pop();
      case Failure(:final value):
        Toasts.error(value.message);
    }
  }
}
