import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import 'package:dialink/src/config/router/route_names.dart';
import 'package:dialink/src/core/core.dart';
import 'package:dialink/src/features/authentication/presentation/controller/session_controller.dart';
import 'package:dialink/src/features/book-appointment/models/appointment_model.dart';
import 'package:dialink/src/features/book-appointment/presentation/controller/appointment_controller.dart';
import 'package:dialink/src/features/book-appointment/presentation/views/provider_slots_screen.dart';
import 'package:dialink/src/features/shell/home_shell.dart';
import 'package:dialink/src/widgets/common.dart';
import 'package:dialink/src/widgets/skeleton.dart';
import 'package:dialink/src/widgets/surface.dart';

/// The Visits tab: upcoming and past appointments.
class VisitsScreen extends ConsumerStatefulWidget {
  const VisitsScreen({super.key});

  @override
  ConsumerState<VisitsScreen> createState() => _VisitsScreenState();
}

class _VisitsScreenState extends ConsumerState<VisitsScreen> {
  bool _showPast = false;

  /// Requested and confirmed visits that haven't ended are upcoming.
  static bool _isUpcoming(AppointmentModel a) =>
      a.status.isActive && a.endTime.isAfter(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(sessionProvider).value;
    if (user == null) return const SizedBox.shrink();

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
                  selected: {_showPast},
                  onSelectionChanged: (value) =>
                      setState(() => _showPast = value.first),
                ),
                12.0.verticalSpacing,
                Expanded(
                  child: switch (appointments) {
                    AsyncData(:final value) => _buildList(
                      value.where((a) => _isUpcoming(a) != _showPast).toList(),
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
    // Newest first for the past; soonest first for what's coming.
    if (!_showPast) {
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
                    title: _showPast ? "No past visits" : "No upcoming visits",
                    message: _showPast
                        ? "Visits you've had will show here."
                        : "Book a visit and it will show here.",
                    actionLabel: _showPast ? null : "Find a doctor",
                    onAction: () => ref
                        .read(selectedTabProvider.notifier)
                        .select(ShellTab.find),
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

/// One appointment, with the actions it still allows.
class VisitCard extends ConsumerWidget {
  const VisitCard({super.key, required this.appointment});

  final AppointmentModel appointment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final provider = ref.watch(providerProvider(appointment.provider.id));
    // Times are shown in the provider's zone once it is known.
    final timeZone = provider.value?.timeZone;
    final busy = ref.watch(appointmentControllerProvider).isLoading;

    final canMove = appointment.canReschedule && provider.hasValue;
    final hasActions =
        appointment.canDelete || appointment.canCancel || canMove;

    return AppSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 12,
            children: [
              InitialsAvatar(name: appointment.provider.name),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.provider.name,
                      style: context.textTheme.titleMedium,
                    ),
                    Text(
                      appointment.provider.specialty,
                      style: context.textTheme.bodyMedium!.copyWith(
                        color: p.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          12.0.verticalSpacing,
          Wrap(
            spacing: 16,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _Detail(
                icon: Iconsax.calendar_1,
                text: AppTime.dateTime(appointment.startTime, timeZone),
              ),
              StatusChip(status: appointment.status),
            ],
          ),
          if (appointment.reason?.isNotEmpty ?? false) ...[
            8.0.verticalSpacing,
            _Detail(icon: Iconsax.note_1, text: appointment.reason!),
          ],
          if (appointment.status == AppointmentStatus.requested) ...[
            8.0.verticalSpacing,
            Text(
              "Waiting for the doctor to confirm.",
              style: context.textTheme.bodySmall,
            ),
          ],
          if (hasActions) ...[
            14.0.verticalSpacing,
            Row(
              spacing: 10,
              children: [
                if (canMove)
                  Expanded(
                    child: FilledButton.tonal(
                      style: FilledButton.styleFrom(
                        backgroundColor: p.tint,
                        foregroundColor: p.text,
                        minimumSize: const Size(0, 48),
                      ),
                      onPressed: busy
                          ? null
                          : () => context.router.pushNamed(
                              RouteName.providerSlots,
                              arguments: ProviderSlotsArgs(
                                provider: provider.value!,
                                reschedule: appointment,
                              ),
                            ),
                      child: const Text("Reschedule"),
                    ),
                  ),
                if (appointment.canDelete || appointment.canCancel)
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                      ),
                      onPressed: busy ? null : () => _remove(context, ref),
                      child: Text(appointment.canDelete ? "Delete" : "Cancel"),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// A request that isn't confirmed yet is deleted; a confirmed one cancelled.
  Future<void> _remove(BuildContext context, WidgetRef ref) async {
    final delete = appointment.canDelete;
    final confirmed = await confirmAction(
      context,
      title: delete ? "Delete this request?" : "Cancel this appointment?",
      message: "${appointment.provider.name} will be told.",
      confirmLabel: delete ? "Delete" : "Cancel appointment",
    );
    if (!confirmed) return;

    final notifier = ref.read(appointmentControllerProvider.notifier);
    final result = delete
        ? await notifier.deleteAppointment(appointment.id)
        : await notifier.cancelAppointment(appointment.id);
    switch (result) {
      case Success(:final value):
        AppConstants.instance.showSuccess(value);
      case Failure(:final value):
        AppConstants.instance.showError(value.message);
    }
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        Icon(icon, size: 16, color: context.palette.muted),
        Flexible(child: Text(text, style: context.textTheme.bodyMedium)),
      ],
    );
  }
}
