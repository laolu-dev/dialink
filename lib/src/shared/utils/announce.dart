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
