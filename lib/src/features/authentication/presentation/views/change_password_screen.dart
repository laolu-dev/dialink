import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dialink/src/config/router/route_names.dart';
import 'package:dialink/src/core/core.dart';
import 'package:dialink/src/widgets/common.dart';
import 'package:dialink/src/widgets/custom_scaffold.dart';
import 'package:dialink/src/widgets/custom_textfield.dart';

import 'package:dialink/src/features/authentication/presentation/controller/authentication_controller.dart';

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
    AppConstants.instance.closeKeyboard();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(authenticationControllerProvider);

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
              CustomPasswordTextfield(
                label: "Current password",
                controller: current,
                textInputAction: TextInputAction.next,
                validator: (value) => AppConstants.requiredValidator(
                  value!,
                  field: "your current password",
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
                label: "Confirm new password",
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
              8.0.verticalSpacing,
              PrimaryButton(
                label: "Change password",
                loading: controller.isLoading,
                onPressed: _submit,
              ),
              12.0.verticalSpacing,
              TextButton(
                onPressed: () =>
                    context.router.pushNamed(RouteName.forgotPassword),
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
    AppConstants.instance.closeKeyboard();

    final result = await ref
        .read(authenticationControllerProvider.notifier)
        .changePassword(
          currentPassword: current.text,
          newPassword: password.text,
        );
    switch (result) {
      case Success():
        AppConstants.instance.showSuccess(
          "Password changed. Other devices have been signed out.",
        );
        if (mounted) Navigator.of(context).pop();
      case Failure(:final value):
        AppConstants.instance.showError(value.message);
    }
  }
}
