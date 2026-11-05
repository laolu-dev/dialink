import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import 'package:dialink/src/app/theme/app_palette.dart';
import 'package:dialink/src/core/utils/extensions.dart';

/// An empty list or a failed load, with an optional action.
class MessageState extends StatelessWidget {
  const MessageState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  /// For a failed load: shows the error and a retry button.
  factory MessageState.error(Object error, {required VoidCallback onRetry}) =>
      MessageState(
        icon: Iconsax.warning_2,
        title: "Something went wrong",
        message: error.toString(),
        actionLabel: "Try again",
        onAction: onRetry,
      );

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: p.tint, shape: BoxShape.circle),
              child: Icon(icon, color: p.primary, size: 28),
            ),
            4.0.verticalSpacing,
            Text(
              title,
              textAlign: TextAlign.center,
              style: context.textTheme.titleMedium,
            ),
            if (message != null)
              Text(
                message!,
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium!.copyWith(color: p.muted),
              ),
            if (actionLabel != null) ...[
              8.0.verticalSpacing,
              OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
