import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:dialink/src/features/booking/widgets/slot_picker.dart';
import 'package:dialink/src/shared/widgets/app_scaffold.dart';
import 'package:dialink/src/data/doctors/doctor_repository.dart';
import 'package:dialink/src/shared/widgets/message_state.dart';
import 'package:dialink/src/shared/widgets/skeleton.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dialink/src/app/router/routes.dart';

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

/// A doctor's free times opened by link, before the doctor is loaded.
class DoctorTimesLoader extends ConsumerWidget {
  const DoctorTimesLoader({super.key, required this.doctorId});

  final String doctorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (ref.watch(providerProvider(doctorId))) {
      AsyncData(:final value) => DoctorTimesScreen(
        args: DoctorTimesArgs(provider: value),
      ),
      AsyncError(:final error) => AppScaffold(
        title: "Book a visit",
        child: MessageState.error(
          error,
          onRetry: () => ref.invalidate(providerProvider(doctorId)),
        ),
      ),
      _ => const AppScaffold(
        title: "Book a visit",
        child: SkeletonList(count: 3, lines: 2),
      ),
    };
  }
}
