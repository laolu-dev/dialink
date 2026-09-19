import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dialink/src/config/router/route_names.dart';
import 'package:dialink/src/core/utils/constants.dart';
import 'package:dialink/src/core/utils/enums.dart';
import 'package:dialink/src/core/utils/extensions.dart';

import 'package:dialink/src/widgets/custom_dropdown.dart';
import 'package:dialink/src/widgets/custom_scaffold.dart';
import 'package:dialink/src/widgets/custom_textfield.dart';

import 'package:dialink/src/features/authentication/presentation/controller/authentication_controller.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final TextEditingController firstname = TextEditingController();
  final TextEditingController lastname = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController gender = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController phoneNo = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();

  final GlobalKey<FormState> _form = GlobalKey<FormState>();

  @override
  void dispose() {
    firstname.dispose();
    lastname.dispose();
    email.dispose();
    gender.dispose();
    password.dispose();
    phoneNo.dispose();
    confirmPassword.dispose();
    _form.currentState?.dispose();
    AppConstants.instance.closeKeyboard();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(authenticationControllerProvider);

    ref.listen(
      authenticationControllerProvider,
      (_, state) {
        state.maybeWhen(
          data: (value) {
            context.router
                .pushNamedAndRemoveUntil(RouteName.login, (route) => false);
          },
          error: (e, st) {
            AppConstants.instance.showError(e.toString());
          },
          orElse: () {},
        );
      },
    );

    return AppScaffold(
      makeScrollable: true,
      child: Form(
        key: _form,
        child: Column(
          children: [
            Center(
              child: Text(
                "Sign up",
                style: context.textTheme.displaySmall!.copyWith(
                  fontFamily: AppConstants.instance.cooperBtFont,
                ),
              ),
            ),
            4.0.verticalSpacing,
            Text(
              "Create an account with us.",
              style: context.textTheme.titleLarge,
            ),
            48.0.verticalSpacing,
            Row(
              spacing: 12,
              children: [
                Flexible(
                  child: CustomTextfield(
                    label: "First Name",
                    hint: "Enter first name",
                    controller: firstname,
                    inputType: TextInputType.name,
                    validator: (value) => AppConstants.nameValidator(value!),
                  ),
                ),
                Flexible(
                  child: CustomTextfield(
                    label: "Last Name",
                    hint: "Enter last name",
                    controller: lastname,
                    inputType: TextInputType.name,
                    validator: (value) => AppConstants.nameValidator(value!),
                  ),
                ),
              ],
            ),
            Row(
              spacing: 12,
              children: [
                Flexible(
                  flex: 2,
                  child: CustomTextfield(
                    label: "Phone number",
                    hint: "Enter phone number",
                    controller: phoneNo,
                    inputType: TextInputType.phone,
                    validator: (value) =>
                        AppConstants.phoneNumberValidator(value!),
                  ),
                ),
                Flexible(
                  child: CustomDropdown(
                    label: "Gender",
                    hint: "Select Gender",
                    controller: gender,
                    options:
                        Gender.values.map((value) => value.gender).toList(),
                  ),
                ),
              ],
            ),
            CustomTextfield(
              label: "Email",
              hint: "Enter your email address",
              controller: email,
              inputType: TextInputType.emailAddress,
              validator: (value) => AppConstants.emailValidator(value!),
            ),
            CustomPasswordTextfield(
              label: "Password",
              hint: "Enter password",
              controller: password,
              validator: (value) => AppConstants.passwordValidator(value!),
            ),
            CustomPasswordTextfield(
              label: "Confirm password",
              hint: "Re-enter password",
              controller: confirmPassword,
              validator: (value) => AppConstants.confirmPasswordValidator(
                value!,
                oldPassword: password.text,
              ),
            ),
            16.0.verticalSpacing,
            switch (controller.isLoading) {
              true => CircularProgressIndicator(),
              _ => TextButton(
                  onPressed: _createAccount,
                  child: Text("Create Account"),
                ),
            },
            74.0.verticalSpacing,
            Text.rich(
              TextSpan(
                text: "Already have an account? ",
                children: [
                  TextSpan(
                    text: "Login",
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        HapticFeedback.heavyImpact();
                        context.router.popAndPushNamed(RouteName.login);
                      },
                    style: context.textTheme.titleMedium!
                        .copyWith(color: AppColors.primary),
                  ),
                ],
              ),
              style: context.textTheme.titleSmall,
            )
          ],
        ),
      ),
    );
  }

  void _createAccount() {
    Map<String, dynamic> payload = {
      "firstName": firstname.text,
      "lastName": lastname.text,
      "phoneNumber": phoneNo.text,
      "gender": gender.text,
      "email": email.text,
      "password": confirmPassword.text,
    };

    if (_form.currentState!.validate()) {
      ref
          .read(authenticationControllerProvider.notifier)
          .createAccount(payload);
    }
  }
}
