import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import 'package:dialink/src/shared/utils/announce.dart';

/// Short messages near the bottom of the screen, where a thumb-driven eye
/// already is. They stay long enough to read, and screen readers hear them.
abstract final class Toasts {
  static void error(String message) => _show(message, ToastificationType.error);

  static void success(String message) =>
      _show(message, ToastificationType.success);

  /// About 3 words a second, plus time to notice it: never under 4 seconds,
  /// never over 10.
  @visibleForTesting
  static Duration readingTime(String message) {
    final words = message.trim().split(RegExp(r'\s+')).length;
    final seconds = (2 + words / 3).clamp(4, 10);
    return Duration(milliseconds: (seconds * 1000).round());
  }

  static void _show(String message, ToastificationType type) {
    toastification.show(
      type: type,
      style: ToastificationStyle.flatColored,
      // The message leads; the icon and colour already say what kind it is.
      title: Text(message, maxLines: 6),
      alignment: Alignment.bottomCenter,
      // Clears the floating tab bar and the screens' pinned buttons.
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 96),
      showProgressBar: false,
      autoCloseDuration: readingTime(message),
      borderRadius: BorderRadius.circular(12.0),
    );
    announceInApp(message);
  }
}
