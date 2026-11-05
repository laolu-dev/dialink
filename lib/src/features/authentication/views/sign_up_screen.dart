import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

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

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final TextEditingController firstname = TextEditingController();
  final TextEditingController lastname = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController phoneNo = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();

  final GlobalKey<FormState> _form = GlobalKey<FormState>();

  @override
  void dispose() {
    firstname.dispose();
    lastname.dispose();
    email.dispose();
    password.dispose();
    phoneNo.dispose();
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
      child: AutofillGroup(
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ScreenHeader(
                title: "Create your account",
                subtitle: "Book visits with doctors in a few taps.",
              ),
              24.0.verticalSpacing,
              AppTextField(
                label: "First name",
                hint: "e.g. Amara",
                controller: firstname,
                inputType: TextInputType.name,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.givenName],
                validator: (value) => Validators.name(value!),
              ),
              AppTextField(
                label: "Last name",
                hint: "e.g. Okafor",
                controller: lastname,
                inputType: TextInputType.name,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.familyName],
                validator: (value) => Validators.name(value!),
              ),
              AppTextField(
                label: "Email",
                hint: "name@example.com",
                icon: Iconsax.sms,
                controller: email,
                inputType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                validator: (value) => Validators.email(value!),
              ),
              AppTextField(
                label: "Phone number (optional)",
                hint: "+2348012345678",
                icon: Iconsax.call,
                controller: phoneNo,
                inputType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.telephoneNumber],
                validator: (value) => Validators.phone(value!, optional: true),
              ),
              AppPasswordField(
                label: "Password",
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
                onSubmitted: _createAccount,
                validator: (value) => Validators.confirmPassword(
                  value!,
                  oldPassword: password.text,
                ),
              ),
              8.0.verticalSpacing,
              PrimaryButton(
                label: "Create account",
                loading: controller.isLoading,
                onPressed: _createAccount,
              ),
              16.0.verticalSpacing,
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    "Already have an account?",
                    style: context.textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Sign in"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// The new account is signed in, which opens home.
  Future<void> _createAccount() async {
    if (!_form.currentState!.validate()) return;
    closeKeyboard();

    final payload = <String, dynamic>{
      "firstName": firstname.text.trim(),
      "lastName": lastname.text.trim(),
      if (phoneNo.text.trim().isNotEmpty) "phone": phoneNo.text.trim(),
      "email": email.text.trim(),
      "password": password.text,
    };

    final result = await ref
        .read(authenticationControllerProvider.notifier)
        .createAccount(payload);
    switch (result) {
      case Success():
        Toasts.success(
          "Account created. We've emailed you a code to confirm your address.",
        );
      case Failure(:final value):
        Toasts.error(value.message);
    }
  }
}
