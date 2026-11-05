import 'package:flutter/material.dart';

import 'package:dialink/src/app/router/routes.dart';
import 'package:dialink/src/app/shell/home_shell.dart';
import 'package:dialink/src/features/account/views/change_password_screen.dart';
import 'package:dialink/src/features/account/views/patient_profile_screen.dart';
import 'package:dialink/src/features/appearance/views/appearance_screen.dart';
import 'package:dialink/src/features/authentication/views/forgot_password_screen.dart';
import 'package:dialink/src/features/authentication/views/sign_in_screen.dart';
import 'package:dialink/src/features/authentication/views/sign_up_screen.dart';
import 'package:dialink/src/features/authentication/views/verify_email_screen.dart';
import 'package:dialink/src/features/booking/views/doctor_times_screen.dart';

class AppRouter {
  AppRouter._();
  static final AppRouter _instance = AppRouter._();
  final GlobalKey<NavigatorState> _routerKey = GlobalKey<NavigatorState>();

  static AppRouter get instance => _instance;
  GlobalKey<NavigatorState> get routerKey => _routerKey;

  Route<dynamic>? routes(RouteSettings settings) {
    final arg = settings.arguments;

    switch (settings.name) {
      case RouteName.landing:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => SignInScreen(),
        );

      case RouteName.signup:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => SignUpScreen(),
        );

      case RouteName.forgotPassword:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) =>
              ForgotPasswordScreen(email: arg is String ? arg : null),
        );

      case RouteName.verify:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => VerifyEmailScreen(),
        );

      case RouteName.home:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => HomeShell(),
        );

      case RouteName.providerSlots:
        if (arg is! DoctorTimesArgs) return _unknownRoute();
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => DoctorTimesScreen(args: arg),
        );

      case RouteName.appearance:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => AppearanceScreen(),
        );

      case RouteName.patientProfile:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => PatientProfileScreen(),
        );

      case RouteName.changePassword:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => ChangePasswordScreen(),
        );

      default:
        return _unknownRoute();
    }
  }

  Route<dynamic> _unknownRoute() {
    return MaterialPageRoute(
      builder: (context) {
        return Scaffold(
          appBar: AppBar(centerTitle: true, title: Text("Router Error")),
          body: Center(child: Text("Screen does not exist")),
        );
      },
    );
  }
}

extension RouterContext on BuildContext {
  NavigatorState get router => AppRouter.instance.routerKey.currentState!;
}
