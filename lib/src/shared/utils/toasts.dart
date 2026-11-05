import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

/// Short messages at the top of the screen.
abstract final class Toasts {
  static void error(String message) {
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

  static void success(String message) {
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
