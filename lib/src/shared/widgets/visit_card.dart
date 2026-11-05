import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import 'package:dialink/src/app/router/routes.dart';
import 'package:dialink/src/app/theme/app_palette.dart';
import 'package:dialink/src/core/network/result.dart';
import 'package:dialink/src/core/utils/extensions.dart';
import 'package:dialink/src/core/utils/time.dart';
import 'package:dialink/src/data/appointments/models/appointment_model.dart';
import 'package:dialink/src/data/appointments/models/appointment_status.dart';
import 'package:dialink/src/data/doctors/doctor_repository.dart';
import 'package:dialink/src/shared/controllers/appointments_controller.dart';
import 'package:dialink/src/shared/utils/toasts.dart';
import 'package:dialink/src/shared/widgets/app_surface.dart';
import 'package:dialink/src/shared/widgets/dialogs.dart';
import 'package:dialink/src/shared/widgets/initials_avatar.dart';
import 'package:dialink/src/shared/widgets/status_chip.dart';
import 'package:go_router/go_router.dart';

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
                          : () => context.push(
                              Routes.doctor(provider.value!.id),
                              extra: DoctorTimesArgs(
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
        Toasts.success(value);
      case Failure(:final value):
        Toasts.error(value.message);
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
