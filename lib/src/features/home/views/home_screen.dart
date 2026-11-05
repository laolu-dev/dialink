import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import 'package:dialink/src/app/router/app_router.dart';
import 'package:dialink/src/app/router/routes.dart';
import 'package:dialink/src/app/shell/home_shell.dart';
import 'package:dialink/src/app/theme/app_palette.dart';
import 'package:dialink/src/core/utils/extensions.dart';
import 'package:dialink/src/data/appointments/models/appointment_model.dart';
import 'package:dialink/src/shared/controllers/appointments_controller.dart';
import 'package:dialink/src/shared/controllers/session_controller.dart';
import 'package:dialink/src/shared/widgets/app_surface.dart';
import 'package:dialink/src/shared/widgets/buttons.dart';
import 'package:dialink/src/shared/widgets/headers.dart';
import 'package:dialink/src/shared/widgets/message_state.dart';
import 'package:dialink/src/shared/widgets/notice_banner.dart';
import 'package:dialink/src/shared/widgets/skeleton.dart';
import 'package:dialink/src/shared/widgets/visit_card.dart';

/// The Home tab: a greeting, the next visit and shortcuts.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionProvider).value;
    if (user == null) return const SizedBox.shrink();

    final appointments = ref.watch(appointmentsProvider(user.id));
    final selectTab = ref.read(selectedTabProvider.notifier).select;
    final p = context.palette;

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await Future.wait([
                      ref.refresh(appointmentsProvider(user.id).future),
                      ref.read(sessionProvider.notifier).reload(),
                    ]);
                  },
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat(
                                    'EEEE, d MMMM',
                                  ).format(DateTime.now()),
                                  style: context.textTheme.bodyMedium!.copyWith(
                                    color: p.muted,
                                  ),
                                ),
                                Semantics(
                                  header: true,
                                  child: Text(
                                    "Hi, ${user.firstName}",
                                    style: context.textTheme.headlineMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      20.0.verticalSpacing,
                      if (!user.emailVerified) ...[
                        NoticeBanner(
                          icon: Iconsax.sms_notification,
                          title: "Confirm your email",
                          message:
                              "You need to confirm it before you can book.",
                          onTap: () =>
                              context.router.pushNamed(RouteName.verify),
                        ),
                        20.0.verticalSpacing,
                      ],
                      const SectionLabel("Next visit"),
                      switch (appointments) {
                        AsyncData(:final value) => switch (_nextVisit(value)) {
                          final next? => VisitCard(appointment: next),
                          null => AppSurface(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 4,
                              children: [
                                Text(
                                  "No upcoming visits",
                                  style: context.textTheme.titleMedium,
                                ),
                                Text(
                                  "Find a doctor and pick a time that suits you.",
                                  style: context.textTheme.bodyMedium!.copyWith(
                                    color: p.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        },
                        AsyncError(:final error) => AppSurface(
                          child: MessageState.error(
                            error,
                            onRetry: () =>
                                ref.invalidate(appointmentsProvider(user.id)),
                          ),
                        ),
                        _ => const SkeletonCard(lines: 3),
                      },
                    ],
                  ),
                ),
              ),
              // The main action sits low, within thumb reach.
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: PrimaryButton(
                  label: "Book a visit",
                  icon: Iconsax.add,
                  onPressed: () => selectTab(ShellTab.find),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// The soonest requested or confirmed visit that hasn't ended.
  static AppointmentModel? _nextVisit(List<AppointmentModel> appointments) {
    final now = DateTime.now();
    final upcoming = appointments
        .where((a) => a.status.isActive && a.endTime.isAfter(now))
        .toList();
    if (upcoming.isEmpty) return null;
    upcoming.sort((a, b) => a.startTime.compareTo(b.startTime));
    return upcoming.first;
  }
}
