import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import 'package:dialink/src/app/theme/app_palette.dart';
import 'package:dialink/src/core/utils/extensions.dart';
import 'package:dialink/src/data/appointments/models/appointment_status.dart';

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
