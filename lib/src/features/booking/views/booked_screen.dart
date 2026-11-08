import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import 'package:dialink/src/app/router/routes.dart';
import 'package:dialink/src/app/theme/app_palette.dart';
import 'package:dialink/src/core/utils/extensions.dart';
import 'package:dialink/src/shared/controllers/visits_view_controller.dart';
import 'package:dialink/src/shared/widgets/app_scaffold.dart';
import 'package:dialink/src/shared/widgets/app_surface.dart';
import 'package:dialink/src/shared/widgets/buttons.dart';
import 'package:dialink/src/shared/widgets/headers.dart';

/// Shown once a booking or move is sent: what was asked for, and what
/// happens next, so the patient leaves sure it went through.
class BookedScreen extends ConsumerWidget {
  const BookedScreen({super.key, required this.args});

  final BookedArgs args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final doctor = args.provider.name;
    final reason = args.reason;

    return AppScaffold(
      makeScrollable: true,
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PrimaryButton(
            label: "See your visits",
            onPressed: () {
              // The new visit is upcoming, whichever list was open before.
              ref.read(visitsShowPastProvider.notifier).show(past: false);
              context.go(Routes.visits);
            },
          ),
          TextButton(
            onPressed: () => context.go(Routes.home),
            child: const Text("Back to home"),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          24.0.verticalSpacing,
          ExcludeSemantics(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: p.successBg,
                shape: BoxShape.circle,
              ),
              child: Icon(Iconsax.tick_circle, color: p.successFg, size: 32),
            ),
          ),
          20.0.verticalSpacing,
          Semantics(
            header: true,
            child: Text(
              args.moved ? "Move requested" : "Request sent",
              style: context.textTheme.headlineSmall,
            ),
          ),
          6.0.verticalSpacing,
          Text(
            "Waiting for $doctor to confirm the time.",
            style: context.textTheme.bodyLarge!.copyWith(color: p.muted),
          ),
          24.0.verticalSpacing,
          AppSurface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                _Detail(
                  icon: Iconsax.user,
                  text: "$doctor · ${args.provider.specialty}",
                ),
                _Detail(
                  icon: Iconsax.calendar_tick,
                  text: args.when,
                  strong: true,
                ),
                if (reason != null && reason.isNotEmpty)
                  _Detail(icon: Iconsax.note_text, text: reason),
              ],
            ),
          ),
          28.0.verticalSpacing,
          const SectionLabel("What happens next"),
          const _Step(
            text:
                "Until the doctor confirms, it shows as Requested in your "
                "visits.",
          ),
          if (args.moved)
            const _Step(text: "Your previous time has been cancelled."),
          const _Step(text: "You can cancel any time before the visit."),
        ],
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.icon, required this.text, this.strong = false});

  final IconData icon;
  final String text;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Icon(icon, size: 20, color: context.palette.primary),
        Expanded(
          child: Text(
            text,
            style: strong
                ? context.textTheme.titleMedium
                : context.textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(Iconsax.arrow_right_3, size: 18, color: p.primary),
          ),
          Expanded(child: Text(text, style: context.textTheme.bodyLarge)),
        ],
      ),
    );
  }
}
