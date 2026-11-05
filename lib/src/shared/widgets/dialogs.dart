import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:dialink/src/app/theme/app_palette.dart';

/// Asks before an action that can't be undone. Returns whether to go ahead.
Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  String? message,
  required String confirmLabel,
  String cancelLabel = "Keep it",
}) async {
  final confirmed = await showAdaptiveDialog<bool>(
    context: context,
    builder: (context) => AlertDialog.adaptive(
      title: Text(title),
      content: message != null ? Text(message) : null,
      actions: [
        adaptiveAction(
          context,
          label: cancelLabel,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        adaptiveAction(
          context,
          label: confirmLabel,
          destructive: true,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

/// A dialog button that looks native on iOS and Android.
Widget adaptiveAction(
  BuildContext context, {
  required String label,
  required VoidCallback onPressed,
  bool destructive = false,
}) {
  final p = context.palette;
  if (Theme.of(context).platform == TargetPlatform.iOS) {
    return CupertinoDialogAction(
      isDestructiveAction: destructive,
      onPressed: onPressed,
      child: Text(label),
    );
  }
  return TextButton(
    style: TextButton.styleFrom(
      foregroundColor: destructive ? p.dangerFg : p.text,
    ),
    onPressed: onPressed,
    child: Text(label),
  );
}
