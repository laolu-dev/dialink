import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import 'package:dialink/src/core/core.dart';
import 'package:dialink/src/widgets/surface.dart';

/// The main action of a screen, full width. Shows a spinner while [loading].
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: loading ? () {} : onPressed,
        child: loading
            ? SizedBox.square(
                dimension: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: p.onPrimary,
                  semanticsLabel: '$label in progress',
                ),
              )
            : _Label(label: label, icon: icon),
      ),
    );
  }
}

/// A supporting action, full width.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        child: _Label(label: label, icon: icon),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final text = Text(label, textAlign: TextAlign.center);
    if (icon == null) return text;
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        Icon(icon, size: 20),
        Flexible(child: text),
      ],
    );
  }
}

/// A screen's title and an optional line under it.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        Semantics(
          header: true,
          child: Text(title, style: context.textTheme.headlineMedium),
        ),
        if (subtitle != null)
          Text(
            subtitle!,
            style: context.textTheme.bodyLarge!.copyWith(
              color: context.palette.muted,
            ),
          ),
      ],
    );
  }
}

/// A small heading above a group of content.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: context.textTheme.labelLarge!.copyWith(
            color: context.palette.muted,
          ),
        ),
      ),
    );
  }
}

/// Initials in a tinted circle.
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({super.key, required this.name, this.size = 44});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final initials = name
        .replaceFirst('Dr. ', '')
        .split(' ')
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part.characters.first.toUpperCase())
        .join();

    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: p.tint, shape: BoxShape.circle),
        child: Text(
          initials,
          style: context.textTheme.labelLarge!.copyWith(
            color: p.primary,
            fontSize: size * .34,
          ),
        ),
      ),
    );
  }
}

/// Status colour, icon and label. Never colour alone.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final AppointmentStatus status;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final (bg, fg, icon) = switch (status) {
      AppointmentStatus.requested => (
        p.warningBg,
        p.warningFg,
        Iconsax.timer_1,
      ),
      AppointmentStatus.confirmed => (
        p.successBg,
        p.successFg,
        Iconsax.tick_circle,
      ),
      AppointmentStatus.completed => (
        p.neutralBg,
        p.neutralFg,
        Iconsax.task_square,
      ),
      AppointmentStatus.cancelled => (
        p.dangerBg,
        p.dangerFg,
        Iconsax.close_circle,
      ),
      AppointmentStatus.noShow => (p.dangerBg, p.dangerFg, Iconsax.user_remove),
      AppointmentStatus.unknown => (
        p.neutralBg,
        p.neutralFg,
        Iconsax.info_circle,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
        border: p.outlinedStatus ? Border.all(color: fg, width: 1.5) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          Icon(icon, size: 14, color: fg),
          // Wraps rather than overflows at large text sizes.
          Flexible(
            child: Text(
              status.label,
              style: context.textTheme.labelMedium!.copyWith(color: fg),
            ),
          ),
        ],
      ),
    );
  }
}

/// A tappable notice, e.g. to confirm the email address.
class NoticeBanner extends StatelessWidget {
  const NoticeBanner({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String message;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return AppSurface(
      color: p.warningBg,
      borderColor: p.warningFg.withValues(alpha: p.outlinedStatus ? 1 : .35),
      padding: const EdgeInsets.all(14),
      radius: 18,
      onTap: onTap,
      child: Row(
        spacing: 12,
        children: [
          Icon(icon, color: p.warningFg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.textTheme.titleSmall!.copyWith(
                    color: p.warningFg,
                  ),
                ),
                Text(
                  message,
                  style: context.textTheme.bodyMedium!.copyWith(
                    color: p.warningFg,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null) Icon(Iconsax.arrow_right_3, color: p.warningFg),
        ],
      ),
    );
  }
}

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
