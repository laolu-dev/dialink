import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import 'package:dialink/src/app/router/routes.dart';
import 'package:dialink/src/app/theme/app_palette.dart';
import 'package:dialink/src/app/theme/theme_settings_controller.dart';
import 'package:dialink/src/core/network/result.dart';
import 'package:dialink/src/core/utils/extensions.dart';
import 'package:dialink/src/features/account/controllers/account_controller.dart';
import 'package:dialink/src/shared/controllers/session_controller.dart';
import 'package:dialink/src/shared/utils/toasts.dart';
import 'package:dialink/src/shared/widgets/app_surface.dart';
import 'package:dialink/src/shared/widgets/dialogs.dart';
import 'package:dialink/src/shared/widgets/headers.dart';
import 'package:dialink/src/shared/widgets/initials_avatar.dart';
import 'package:go_router/go_router.dart';

/// The Account tab: the patient, appearance and security.
class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionProvider).value;
    if (user == null) return const SizedBox.shrink();

    final p = context.palette;
    final settings = ref.watch(themeSettingsControllerProvider);

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              const ScreenHeader(title: "Account"),
              16.0.verticalSpacing,
              // The whole card opens the patient's details to edit.
              Semantics(
                button: true,
                hint: "Edit your details",
                child: AppSurface(
                  onTap: () => context.push(Routes.details),
                  child: Row(
                    spacing: 14,
                    children: [
                      InitialsAvatar(name: user.name, size: 56),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: context.textTheme.titleMedium,
                            ),
                            Text(
                              user.email,
                              style: context.textTheme.bodyMedium!.copyWith(
                                color: p.muted,
                              ),
                            ),
                            4.0.verticalSpacing,
                            Row(
                              spacing: 4,
                              children: [
                                Icon(
                                  user.emailVerified
                                      ? Iconsax.verify
                                      : Iconsax.info_circle,
                                  size: 16,
                                  color: user.emailVerified
                                      ? p.successFg
                                      : p.warningFg,
                                ),
                                Flexible(
                                  child: Text(
                                    user.emailVerified
                                        ? "Email confirmed"
                                        : "Email not confirmed",
                                    style: context.textTheme.labelMedium!
                                        .copyWith(
                                          color: user.emailVerified
                                              ? p.successFg
                                              : p.warningFg,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Icon(Iconsax.edit_2, size: 20, color: p.primary),
                    ],
                  ),
                ),
              ),
              24.0.verticalSpacing,
              const SectionLabel("Your account"),
              _Rows(
                rows: [
                  _Row(
                    icon: Iconsax.brush_1,
                    label: "Appearance",
                    detail: settings.theme.label,
                    onTap: () => context.push(Routes.appearance),
                  ),
                  _Row(
                    icon: Iconsax.personalcard,
                    label: "Your details",
                    onTap: () => context.push(Routes.details),
                  ),
                  if (!user.emailVerified)
                    _Row(
                      icon: Iconsax.sms_notification,
                      label: "Confirm your email",
                      onTap: () => context.push(Routes.verifyEmail),
                    ),
                  _Row(
                    icon: Iconsax.key,
                    label: "Change password",
                    onTap: () => context.push(Routes.changePassword),
                  ),
                ],
              ),
              16.0.verticalSpacing,
              _Rows(
                rows: [
                  _Row(
                    icon: Iconsax.logout,
                    label: "Sign out",
                    onTap: () => _signOut(context, ref),
                  ),
                  _Row(
                    icon: Iconsax.shield_cross,
                    label: "Sign out on all devices",
                    destructive: true,
                    onTap: () => _signOutEverywhere(context, ref),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await confirmAction(
      context,
      title: "Sign out?",
      confirmLabel: "Sign out",
      cancelLabel: "Stay signed in",
    );
    if (confirmed) await ref.read(sessionProvider.notifier).logout();
  }

  Future<void> _signOutEverywhere(BuildContext context, WidgetRef ref) async {
    final confirmed = await confirmAction(
      context,
      title: "Sign out everywhere?",
      message: "You'll be signed out on every device, including this one.",
      confirmLabel: "Sign out",
      cancelLabel: "Keep me signed in",
    );
    if (!confirmed) return;

    // On success the session listener goes back to the start.
    final result = await ref
        .read(accountControllerProvider.notifier)
        .logoutAll();
    if (result case Failure(:final value)) {
      Toasts.error(value.message);
    }
  }
}

class _Rows extends StatelessWidget {
  const _Rows({required this.rows});

  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (final (i, row) in rows.indexed) ...[
            if (i > 0) const Divider(height: 1, indent: 16, endIndent: 16),
            row,
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.label,
    required this.onTap,
    this.detail,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final String? detail;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final color = destructive ? p.dangerFg : p.text;
    return ListTile(
      minTileHeight: 56,
      leading: Icon(icon, color: destructive ? p.dangerFg : p.primary),
      title: Text(
        label,
        style: context.textTheme.bodyLarge!.copyWith(color: color),
      ),
      subtitle: detail != null
          ? Text(detail!, style: context.textTheme.bodySmall)
          : null,
      trailing: Icon(Iconsax.arrow_right_3, color: p.muted, size: 18),
      onTap: onTap,
    );
  }
}
