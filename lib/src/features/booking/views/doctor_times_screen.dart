import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:dialink/src/data/appointments/models/appointment_model.dart';
import 'package:dialink/src/data/doctors/models/provider_model.dart';
import 'package:dialink/src/features/booking/widgets/slot_picker.dart';
import 'package:dialink/src/shared/widgets/app_scaffold.dart';

class DoctorTimesArgs {
  const DoctorTimesArgs({required this.provider, this.reschedule});

  final ProviderModel provider;

  /// When set, picking a slot moves this appointment instead of booking.
  final AppointmentModel? reschedule;
}

/// Picking a time as its own screen, on phones.
class DoctorTimesScreen extends StatelessWidget {
  const DoctorTimesScreen({super.key, required this.args});

  final DoctorTimesArgs args;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: args.reschedule != null ? "Reschedule" : "Book a visit",
      padding: EdgeInsets.zero,
      child: SlotPicker(args: args),
    );
  }
}
