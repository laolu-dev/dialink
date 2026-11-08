import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:dialink/src/app/router/routes.dart';
import 'package:dialink/src/app/shell/home_shell.dart';
import 'package:dialink/src/features/account/views/account_screen.dart';
import 'package:dialink/src/features/account/views/change_password_screen.dart';
import 'package:dialink/src/features/account/views/patient_profile_screen.dart';
import 'package:dialink/src/features/appearance/views/appearance_screen.dart';
import 'package:dialink/src/features/authentication/views/forgot_password_screen.dart';
import 'package:dialink/src/features/authentication/views/sign_in_screen.dart';
import 'package:dialink/src/features/authentication/views/sign_up_screen.dart';
import 'package:dialink/src/features/authentication/views/verify_email_screen.dart';
import 'package:dialink/src/features/booking/views/booked_screen.dart';
import 'package:dialink/src/features/booking/views/doctor_times_screen.dart';
import 'package:dialink/src/features/booking/views/find_doctor_screen.dart';
import 'package:dialink/src/features/home/views/home_screen.dart';
import 'package:dialink/src/features/onboarding/controllers/onboarding_controller.dart';
import 'package:dialink/src/features/onboarding/views/onboarding_screen.dart';
import 'package:dialink/src/features/visits/views/visits_screen.dart';
import 'package:dialink/src/shared/controllers/session_controller.dart';
import 'package:dialink/src/shared/views/splash_screen.dart';
import 'package:dialink/src/shared/widgets/message_state.dart';

part 'app_router.g.dart';

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// Signed-out screens a signed-in patient is sent home from.
const _signedOutOnly = {Routes.welcome, Routes.signIn, Routes.signUp};

/// Screens open without signing in, once onboarding is seen.
const _public = {Routes.signIn, Routes.signUp, Routes.forgotPassword};

/// The app's navigation. It follows the session: restoring shows the
/// splash, signing in opens home, and signing out, or the server ending the
/// session, goes back to sign-in.
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final refresh = ValueNotifier(0);
  ref
    ..listen(sessionProvider, (_, _) => refresh.value++)
    ..listen(onboardingSeenProvider, (_, _) => refresh.value++)
    ..onDispose(refresh.dispose);

  final router = GoRouter(
    navigatorKey: _rootKey,
    initialLocation: Routes.splash,
    refreshListenable: refresh,
    redirect: (context, state) => _redirect(ref, state.matchedLocation),
    errorBuilder: (context, state) => const _NotFound(),
    routes: [
      GoRoute(path: Routes.splash, builder: (_, _) => const _Splash()),
      GoRoute(
        path: Routes.welcome,
        builder: (_, _) => const OnboardingScreen(),
      ),
      GoRoute(path: Routes.signIn, builder: (_, _) => const SignInScreen()),
      GoRoute(path: Routes.signUp, builder: (_, _) => const SignUpScreen()),
      GoRoute(
        path: Routes.forgotPassword,
        builder: (_, state) => ForgotPasswordScreen(
          email: state.extra is String ? state.extra as String : null,
        ),
      ),
      GoRoute(
        path: Routes.verifyEmail,
        builder: (_, _) => const VerifyEmailScreen(),
      ),
      GoRoute(
        path: '/doctors/:id',
        builder: (_, state) => switch (state.extra) {
          final DoctorTimesArgs args => DoctorTimesScreen(args: args),
          _ => DoctorTimesLoader(doctorId: state.pathParameters['id']!),
        },
      ),
      GoRoute(
        path: Routes.booked,
        // Only reachable straight after a booking; otherwise show the visits.
        redirect: (_, state) =>
            state.extra is BookedArgs ? null : Routes.visits,
        builder: (_, state) => BookedScreen(args: state.extra! as BookedArgs),
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => HomeShell(navigationShell: shell),
        branches: [
          _tab(Routes.home, const HomeScreen()),
          _tab(Routes.find, const FindDoctorScreen()),
          _tab(Routes.visits, const VisitsScreen()),
          _tab(
            Routes.account,
            const AccountScreen(),
            routes: [
              // Over the tabs, as their own screens.
              _over('details', const PatientProfileScreen()),
              _over('appearance', const AppearanceScreen()),
              _over('change-password', const ChangePasswordScreen()),
            ],
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
}

StatefulShellBranch _tab(
  String path,
  Widget screen, {
  List<RouteBase> routes = const [],
}) => StatefulShellBranch(
  routes: [GoRoute(path: path, builder: (_, _) => screen, routes: routes)],
);

GoRoute _over(String path, Widget screen) => GoRoute(
  path: path,
  parentNavigatorKey: _rootKey,
  builder: (_, _) => screen,
);

String? _redirect(Ref ref, String location) {
  final session = ref.read(sessionProvider);

  // Restoring a saved session, or it failed: the splash, which picks up
  // from the native launch screen and offers a retry.
  if (!session.hasValue) {
    return location == Routes.splash ? null : Routes.splash;
  }

  if (session.value != null) {
    final leaving =
        location == Routes.splash || _signedOutOnly.contains(location);
    return leaving ? Routes.home : null;
  }

  // First launch, signed out: what the app does, before sign-in.
  if (!ref.read(onboardingSeenProvider)) {
    return location == Routes.welcome ? null : Routes.welcome;
  }
  return _public.contains(location) ? null : Routes.signIn;
}

class _Splash extends ConsumerWidget {
  const _Splash();

  @override
  Widget build(BuildContext context, WidgetRef ref) => SplashScreen(
    error: ref.watch(sessionProvider).error,
    onRetry: () => ref.invalidate(sessionProvider),
  );
}

class _NotFound extends StatelessWidget {
  const _NotFound();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: MessageState(
      icon: Icons.explore_off_outlined,
      title: "This page doesn't exist",
      actionLabel: "Go home",
      onAction: () => context.go(Routes.home),
    ),
  );
}
