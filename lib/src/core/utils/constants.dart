import 'package:flutter/material.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:toastification/toastification.dart';

class AppConstants {
  AppConstants._();
  static final AppConstants _instance = AppConstants._();
  static AppConstants get instance => _instance;

  final Talker talker = TalkerFlutter.init(
    settings: TalkerSettings(
      colors: {
        TalkerKey.httpResponse: AnsiPen()..green(),
        TalkerKey.route: AnsiPen()..cyan(),
        TalkerKey.error: AnsiPen()..red(),
        TalkerKey.debug: AnsiPen()..yellow(),
        TalkerKey.info: AnsiPen()
          ..rgb(r: 100 / 255, g: 181 / 255, b: 246 / 255),
        TalkerKey.riverpodAdd: AnsiPen()
          ..rgb(r: 76 / 255, g: 175 / 255, b: 80 / 255),
        TalkerKey.riverpodUpdate: AnsiPen()
          ..rgb(r: 33 / 255, g: 150 / 255, b: 243 / 255),
        TalkerKey.riverpodFail: AnsiPen()
          ..rgb(r: 244 / 255, g: 67 / 255, b: 54 / 255),
        TalkerKey.riverpodDispose: AnsiPen()
          ..rgb(r: 255 / 255, g: 152 / 255, b: 0 / 255),
      },
    ),
  );

  void closeKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  static String? nameValidator(String name) {
    if (name.trim().isEmpty) {
      return 'Enter a name';
    } else if (name.length > 100) {
      return 'Use at most 100 characters';
    }
    return null;
  }

  /// E.164, e.g. +2348012345678. Empty is allowed when [optional].
  static String? phoneNumberValidator(String phone, {bool optional = false}) {
    final RegExp regex = RegExp(r"^\+[1-9]\d{6,14}$");

    if (phone.isEmpty) {
      return optional ? null : 'Enter a phone number';
    } else if (!regex.hasMatch(phone)) {
      return 'Use the international format, e.g. +2348012345678';
    }
    return null;
  }

  static String? emailValidator(String email) {
    final RegExp regex = RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$");

    if (email.isEmpty) {
      return 'Enter an email';
    } else if (!regex.hasMatch(email.trim())) {
      return 'Enter a valid email';
    }
    return null;
  }

  /// For sign-in: the account's existing password may predate the 12-character rule.
  static String? requiredValidator(
    String value, {
    String field = 'this field',
  }) {
    if (value.isEmpty) {
      return 'Enter $field';
    }
    return null;
  }

  /// For a new password: 12 to 128 characters.
  static String? passwordValidator(String password) {
    if (password.isEmpty) {
      return 'Enter a password.';
    } else if (password.length < 12) {
      return 'Use at least 12 characters.';
    } else if (password.length > 128) {
      return 'Use at most 128 characters.';
    }
    return null;
  }

  static String? confirmPasswordValidator(
    String? newPassword, {
    required String oldPassword,
  }) {
    if (newPassword == null || newPassword.isEmpty) {
      return 'required';
    } else if (newPassword != oldPassword) {
      return 'The passwords are not the same.';
    }
    return null;
  }

  void showError(String message) {
    toastification.show(
      type: ToastificationType.error,
      style: ToastificationStyle.flatColored,
      title: Text("Error"),
      description: Text(message),
      alignment: Alignment.topLeft,
      showProgressBar: false,
      autoCloseDuration: const Duration(seconds: 3),
      borderRadius: BorderRadius.circular(12.0),
    );
  }

  void showSuccess(String message) {
    toastification.show(
      type: ToastificationType.success,
      style: ToastificationStyle.flatColored,
      title: Text("Successful"),
      description: Text(message),
      showProgressBar: false,
      alignment: Alignment.topLeft,
      autoCloseDuration: const Duration(seconds: 3),
      borderRadius: BorderRadius.circular(12.0),
    );
  }
}

/// Paths under `/api/v1`.
class ApiEndpoints {
  static const String signup = "/auth/signup";
  static const String login = "/auth/login";
  static const String google = "/auth/google";
  static const String refresh = "/auth/refresh";
  static const String logout = "/auth/logout";
  static const String logoutAll = "/auth/logout-all";
  static const String verifyEmail = "/auth/verify-email";
  static const String resendVerification = "/auth/verify-email/resend";
  static const String forgotPassword = "/auth/forgot-password";
  static const String resetPassword = "/auth/reset-password";
  static const String changePassword = "/auth/change-password";

  /// Sent without a token: the server rejects an expired one even here.
  static const Set<String> public = {
    signup,
    login,
    google,
    refresh,
    logout,
    verifyEmail,
    forgotPassword,
    resetPassword,
  };

  static String user(String id) => "/users/$id";
  static String patientProfile(String userId) =>
      "/users/$userId/patient-profile";

  static const String providers = "/providers";
  static const String specialties = "/providers/specialties";
  static String provider(String id) => "/providers/$id";
  static String availability(String providerId) =>
      "/providers/$providerId/availability";

  static const String appointments = "/appointments";
  static String userAppointments(String userId) => "/appointments/user/$userId";
  static String appointment(String id) => "/appointments/$id";
  static String cancelAppointment(String id) => "/appointments/$id/cancel";
  static String rescheduleAppointment(String id) =>
      "/appointments/$id/reschedule";
}
