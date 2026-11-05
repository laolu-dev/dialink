import 'package:dialink/src/config/router/route_names.dart';
import 'package:dialink/src/features/authentication/presentation/views/appearance_screen.dart';
import 'package:dialink/src/features/authentication/presentation/views/change_password_screen.dart';
import 'package:dialink/src/features/authentication/presentation/views/forgot_password_screen.dart';
import 'package:dialink/src/features/authentication/presentation/views/patient_profile_screen.dart';
import 'package:dialink/src/features/authentication/presentation/views/signup_screen.dart';
import 'package:dialink/src/features/authentication/presentation/views/verify_email_screen.dart';
import 'package:dialink/src/features/book-appointment/presentation/views/provider_slots_screen.dart';
import 'package:dialink/src/features/landing/landing_screen.dart';
import 'package:dialink/src/features/shell/home_shell.dart';
import 'package:flutter/material.dart';

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
          builder: (context) => LandingScreen(),
        );

      case RouteName.signup:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => SignupScreen(),
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
        if (arg is! ProviderSlotsArgs) return _unknownRoute();
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => ProviderSlotsScreen(args: arg),
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
