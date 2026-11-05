import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import 'package:dialink/src/app/router/routes.dart';
import 'package:dialink/src/app/theme/app_palette.dart';
import 'package:dialink/src/app/theme/theme_settings_controller.dart';
import 'package:dialink/src/core/network/result.dart';
import 'package:dialink/src/core/utils/extensions.dart';
import 'package:dialink/src/core/utils/validators.dart';
import 'package:dialink/src/features/authentication/controllers/authentication_controller.dart';
import 'package:dialink/src/features/authentication/widgets/google_button.dart';
import 'package:dialink/src/shared/utils/keyboard.dart';
import 'package:dialink/src/shared/utils/toasts.dart';
import 'package:dialink/src/shared/widgets/app_scaffold.dart';
import 'package:dialink/src/shared/widgets/app_text_field.dart';
import 'package:dialink/src/shared/widgets/buttons.dart';
import 'package:go_router/go_router.dart';

/// Sign in with email and password, or with Google.
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  final GlobalKey<FormState> _form = GlobalKey<FormState>();

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    closeKeyboard();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(authenticationControllerProvider);
    final theme = ref.watch(themeSettingsControllerProvider).theme;
    final p = context.palette;

    return AppScaffold(
      makeScrollable: true,
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Image.asset(
                theme.iconAsset,
                width: 76,
                height: 76,
                semanticLabel: "Dialink",
              ),
            ),
          ),
          16.0.verticalSpacing,
          Text(
            "Dialink",
            textAlign: TextAlign.center,
            style: context.textTheme.displaySmall,
          ),
          4.0.verticalSpacing,
          Text(
            "See a doctor without the waiting room",
            textAlign: TextAlign.center,
            style: context.textTheme.bodyLarge!.copyWith(color: p.muted),
          ),
          32.0.verticalSpacing,
          AutofillGroup(
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                  AppPasswordField(
                    label: "Password",
                    hint: "Your password",
                    controller: password,
                    textInputAction: TextInputAction.done,
                    onSubmitted: _login,
                    validator: (value) =>
                        Validators.required(value!, field: "your password"),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context.push(
                        Routes.forgotPassword,
                        extra: email.text.trim(),
                      ),
                      child: const Text("Forgot password?"),
                    ),
                  ),
                  12.0.verticalSpacing,
                  PrimaryButton(
                    label: "Sign in",
                    loading: controller.isLoading,
                    onPressed: _login,
                  ),
                  // The alternative: under the main sign-in, not above it.
                  20.0.verticalSpacing,
                  Row(
                    spacing: 12,
                    children: [
                      const Expanded(child: Divider()),
                      Text("or", style: context.textTheme.bodySmall),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  20.0.verticalSpacing,
                  const GoogleButton(),
                  16.0.verticalSpacing,
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        "New to Dialink?",
                        style: context.textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () =>
                            context.push(Routes.signUp),
                        child: const Text("Create an account"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// A successful sign-in opens home from the session listener.
  Future<void> _login() async {
    if (!_form.currentState!.validate()) return;
    closeKeyboard();

    final result = await ref
        .read(authenticationControllerProvider.notifier)
        .login(email: email.text.trim(), password: password.text);
    if (result case Failure(:final value)) {
      Toasts.error(value.message);
    }
  }
}
