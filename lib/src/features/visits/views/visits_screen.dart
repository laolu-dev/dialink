import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import 'package:dialink/src/core/utils/extensions.dart';
import 'package:dialink/src/data/appointments/models/appointment_model.dart';
import 'package:dialink/src/shared/controllers/appointments_controller.dart';
import 'package:dialink/src/shared/controllers/session_controller.dart';
import 'package:dialink/src/shared/controllers/visits_view_controller.dart';
import 'package:dialink/src/shared/widgets/headers.dart';
import 'package:dialink/src/shared/widgets/message_state.dart';
import 'package:dialink/src/shared/widgets/skeleton.dart';
import 'package:dialink/src/shared/widgets/visit_card.dart';
import 'package:dialink/src/app/router/routes.dart';
import 'package:go_router/go_router.dart';

/// The Visits tab: upcoming and past appointments.
class VisitsScreen extends ConsumerStatefulWidget {
  const VisitsScreen({super.key});

  @override
  ConsumerState<VisitsScreen> createState() => _VisitsScreenState();
}

class _VisitsScreenState extends ConsumerState<VisitsScreen> {
  /// Requested and confirmed visits that haven't ended are upcoming.
  static bool _isUpcoming(AppointmentModel a) =>
      a.status.isActive && a.endTime.isAfter(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(sessionProvider).value;
    if (user == null) return const SizedBox.shrink();

    final showPast = ref.watch(visitsShowPastProvider);
    final provider = appointmentsProvider(user.id);
    final appointments = ref.watch(provider);

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const ScreenHeader(title: "Your visits"),
                16.0.verticalSpacing,
                SegmentedButton<bool>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: false, label: Text("Upcoming")),
                    ButtonSegment(value: true, label: Text("Past")),
                  ],
                  selected: {showPast},
                  onSelectionChanged: (value) => ref
                      .read(visitsShowPastProvider.notifier)
                      .show(past: value.first),
                ),
                12.0.verticalSpacing,
                Expanded(
                  child: switch (appointments) {
                    AsyncData(:final value) => _buildList(
                      value.where((a) => _isUpcoming(a) != showPast).toList(),
                      onRefresh: () => ref.refresh(provider.future),
                      onEnd: ref.read(provider.notifier).loadMore,
                    ),
                    AsyncError(:final error) => MessageState.error(
                      error,
                      onRetry: () => ref.invalidate(provider),
                    ),
                    _ => const SkeletonList(count: 4, lines: 3),
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildList(
    List<AppointmentModel> visits, {
    required Future<void> Function() onRefresh,
    required Future<bool> Function() onEnd,
  }) {
    final showPast = ref.read(visitsShowPastProvider);
    // Newest first for the past; soonest first for what's coming.
    if (!showPast) {
      visits.sort((a, b) => a.startTime.compareTo(b.startTime));
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: NotificationListener<ScrollEndNotification>(
        onNotification: (notification) {
          if (notification.metrics.extentAfter < 300) onEnd();
          return false;
        },
        child: visits.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  48.0.verticalSpacing,
                  MessageState(
                    icon: Iconsax.calendar_1,
                    title: showPast ? "No past visits" : "No upcoming visits",
                    message: showPast
                        ? "Visits you've had will show here."
                        : "Book a visit and it will show here.",
                    actionLabel: showPast ? null : "Find a doctor",
                    onAction: () => context.go(Routes.find),
                  ),
                ],
              )
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(top: 4, bottom: 24),
                itemCount: visits.length,
                separatorBuilder: (context, index) => 12.0.verticalSpacing,
                itemBuilder: (context, index) =>
                    VisitCard(appointment: visits[index]),
              ),
      ),
    );
  }
}
