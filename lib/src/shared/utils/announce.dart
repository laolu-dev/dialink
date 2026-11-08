import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

/// Reads [message] out to screen-reader users, for changes they can't see
/// happen, such as a banner appearing after a failed booking.
void announce(BuildContext context, String message) {
  SemanticsService.sendAnnouncement(
    View.of(context),
    message,
    Directionality.of(context),
  );
}

/// [announce] for code with no [BuildContext], such as toasts raised by a
/// controller. Uses the app's only window.
void announceInApp(String message) {
  final view = PlatformDispatcher.instance.implicitView;
  if (view == null) return;
  SemanticsService.sendAnnouncement(view, message, TextDirection.ltr);
}
