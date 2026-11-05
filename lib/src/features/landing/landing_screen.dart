import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import 'package:dialink/src/config/config.dart';
import 'package:dialink/src/config/router/route_names.dart';
import 'package:dialink/src/core/core.dart';
import 'package:dialink/src/features/authentication/presentation/controller/authentication_controller.dart';
import 'package:dialink/src/features/authentication/presentation/controller/session_controller.dart';
import 'package:dialink/src/features/authentication/presentation/views/google_button.dart';
import 'package:dialink/src/features/landing/splash_screen.dart';
import 'package:dialink/src/features/onboarding/onboarding_screen.dart';
import 'package:dialink/src/widgets/common.dart';
import 'package:dialink/src/widgets/custom_scaffold.dart';
import 'package:dialink/src/widgets/custom_textfield.dart';

/// The start: restores a saved session, or offers sign-in.
class LandingScreen extends ConsumerStatefulWidget {
  const LandingScreen({super.key});

  @override
  ConsumerState<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends ConsumerState<LandingScreen> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  final GlobalKey<FormState> _form = GlobalKey<FormState>();

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    AppConstants.instance.closeKeyboard();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final controller = ref.watch(authenticationControllerProvider);
    final theme = ref.watch(themeSettingsControllerProvider).theme;
    final p = context.palette;

    // Restoring a saved session, or it failed: the splash, which picks up
    // from the native launch screen.
    if (session is! AsyncData) {
      return SplashScreen(
        error: session.error,
        onRetry: () => ref.invalidate(sessionProvider),
      );
    }

    // First launch, signed out: show what the app does before sign-in.
    if (!ref.watch(onboardingSeenProvider)) return const OnboardingScreen();

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
                  CustomTextfield(
                    label: "Email",
                    hint: "name@example.com",
                    icon: Iconsax.sms,
                    controller: email,
                    inputType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    validator: (value) => AppConstants.emailValidator(value!),
                  ),
                  CustomPasswordTextfield(
                    label: "Password",
                    hint: "Your password",
                    controller: password,
                    textInputAction: TextInputAction.done,
                    onSubmitted: _login,
                    validator: (value) => AppConstants.requiredValidator(
                      value!,
                      field: "your password",
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context.router.pushNamed(
                        RouteName.forgotPassword,
                        arguments: email.text.trim(),
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
                            context.router.pushNamed(RouteName.signup),
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
    AppConstants.instance.closeKeyboard();

    final result = await ref
        .read(authenticationControllerProvider.notifier)
        .login(email: email.text.trim(), password: password.text);
    if (result case Failure(:final value)) {
      AppConstants.instance.showError(value.message);
    }
  }
}
