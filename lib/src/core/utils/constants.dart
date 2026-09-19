import 'package:dialink/src/core/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:toastification/toastification.dart';

const String _male =
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcShIu93nkUhwwHnxeOf5xkXC_F93lItlkVty1LRMY2L35oNACzMPxoBHllmdYUwqznoLsc&usqp=CAU";
const String _female =
    "https://uxwing.com/wp-content/themes/uxwing/download/peoples-avatars/woman-user-circle-black-icon.png";

class AppConstants {
  AppConstants._();
  static final AppConstants _instance = AppConstants._();
  static AppConstants get instance => _instance;

  final String poppinsFont = "Poppins";
  final String cooperBtFont = "Cooper BT";

  String genderPic(String gender) {
    final genderType = Gender.values.firstWhere(
        (type) => type.gender.toLowerCase() == gender.toLowerCase());
    return switch (genderType) {
      Gender.male => _male,
      Gender.female => _female
    };
  }

  String dobFormatter(String dob) {
    final dateTime = DateTime.parse(dob);
    return DateFormat("yyyy-MM-dd").format(dateTime);
  }

  String appointmentDateFormatter(String appointmentDate) {
    final dateTime = DateTime.parse(appointmentDate);
    return DateFormat("yyyy-MM-dd").format(dateTime);
  }

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
    final RegExp regex = RegExp(r"^[A-Za-z]+$");
    final bool isValid = regex.hasMatch(name);

    if (name.isEmpty) {
      return 'Enter a name';
    } else if (!isValid) {
      return 'Enter a valid name';
    }
    return null;
  }

  static String? phoneNumberValidator(String phone) {
    final RegExp regex = RegExp(r"^\d{1,14}$");
    final bool isValid = regex.hasMatch(phone);

    if (phone.isEmpty) {
      return 'Enter a phone number';
    } else if (!isValid) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  static String? emailValidator(String email) {
    final RegExp regex = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    final bool isValid = regex.hasMatch(email);

    if (email.isEmpty) {
      return 'Enter a email';
    } else if (!isValid) {
      return 'Enter a valid email';
    }
    return null;
  }

  static String? passwordValidator(String password) {
    if (password.isEmpty) {
      return 'Enter a password.';
    }
    return null;
  }

  static String? confirmPasswordValidator(String? newPassword,
      {required String oldPassword}) {
    if (newPassword != oldPassword) {
      return 'The passwords are not the same.';
    } else if (newPassword!.isEmpty) {
      return 'required';
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

class AppColors {
  static const Color primary = Color(0xFF6C63FF);
  static const Color secondary = Color(0xFFA8D5E2);
  static const Color error = Color(0xFFFF6F61);
  static const Color success = Color(0xFF9FE6A0);
  static const Color background = Color(0xFFF7F9FB);
  static const Color textColor = Color(0xFF3C4043);
  static const Color white = Colors.white;
}

class ApiEndpoints {
  static const String createAccount = "/accounts";
  static const String login = "/accounts/login";
  static const String getAppointments = "/appointments";
  static const String createAppointment = "/appointments/create";
  static const String confirmAppointment = "/appointments/confirm";
  static String deleteAppointment(String id) => "/appointments/delete/$id";
}
