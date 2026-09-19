import 'package:dialink/src/config/router/route_names.dart';
import 'package:dialink/src/core/core.dart';
import 'package:dialink/src/features/authentication/models/user_model.dart';
import 'package:dialink/src/features/book-appointment/models/appointment_model.dart';
import 'package:dialink/src/features/book-appointment/presentation/controller/appointment_controller.dart';
import 'package:dialink/src/features/book-appointment/presentation/views/appointment_modal.dart';
import 'package:dialink/src/widgets/custom_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key, required this.user});
  final UserModel user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointments = ref.watch(fetchAppointmentsProvider(userId: user.id));

    ref.listen(
      appointmentControllerProvider,
      (_, state) {
        state.maybeWhen(
          data: (message) {
            if (message != null) {
              AppConstants.instance.showSuccess(message);
              ref.invalidate(fetchAppointmentsProvider(userId: user.id));
            }
          },
          error: (e, st) {
            AppConstants.instance.showError(e.toString());
          },
          orElse: () {},
        );
      },
    );

    return AppScaffold(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(
                  AppConstants.instance.genderPic(user.gender),
                ),
              ),
              12.0.horizontalSpacing,
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: "Welcome,\t\t",
                    style: context.textTheme.titleMedium,
                    children: [
                      TextSpan(
                        text: user.name,
                        style: context.textTheme.titleLarge!.copyWith(
                          color: AppColors.primary,
                          fontFamily: AppConstants.instance.cooperBtFont,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                customBorder: CircleBorder(),
                child: Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Iconsax.logout_14),
                ),
                onTap: () {
                  context.router.pushReplacementNamed(RouteName.login);
                },
              ),
            ],
          ),
          24.0.verticalSpacing,
          Expanded(
            child: appointments.when(
              data: (appointments) {
                return RefreshIndicator(
                  onRefresh: () {
                    return Future.wait([
                      ref.refresh(
                          fetchAppointmentsProvider(userId: user.id).future),
                    ]);
                  },
                  child: ListView.separated(
                    itemCount: appointments?.length ?? 0,
                    itemBuilder: (context, index) => _AppointmentTile(
                      number: index + 1,
                      appointment: appointments![index],
                    ),
                    separatorBuilder: (context, index) => 14.0.verticalSpacing,
                  ),
                );
              },
              error: (error, st) {
                return Center(
                  child: OutlinedButton(
                    onPressed: () => ref
                        .invalidate(fetchAppointmentsProvider(userId: user.id)),
                    child: Text("Refresh"),
                  ),
                );
              },
              loading: () => Center(child: CircularProgressIndicator()),
            ),
          ),
          24.0.verticalSpacing,
          Center(
            child: TextButton(
              onPressed: () => showAdaptiveDialog(
                context: context,
                barrierDismissible: true,
                barrierColor: AppColors.secondary.withAlpha(250),
                builder: (context) => BookAppointmentDate(userId: user.id),
              ),
              child: Text("Book an Appointment"),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppointmentTile extends ConsumerWidget {
  _AppointmentTile({required this.number, required this.appointment});

  final int number;
  final AppointmentModel appointment;

  final ValueNotifier<bool> _isExpanded = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ValueListenableBuilder(
      valueListenable: _isExpanded,
      builder: (context, isExpanded, _) {
        return AnimatedSize(
          curve: Curves.ease,
          duration: Durations.medium4,
          child: GestureDetector(
            onTap: () => _isExpanded.value = !_isExpanded.value,
            child: Container(
              padding: EdgeInsets.all(12),
              constraints: BoxConstraints(
                minWidth: context.deviceSize.width,
              ),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withAlpha(125)),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 2,
                    offset: Offset(2, 2),
                    color: AppColors.textColor.withValues(alpha: .3),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Appointment #$number",
                        style: context.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Icon(switch (isExpanded) {
                        true => Iconsax.arrow_up_2,
                        _ => Iconsax.arrow_down_1,
                      })
                    ],
                  ),
                  if (isExpanded) ...[
                    Divider(color: AppColors.secondary),
                    _buildSubFields(
                      context,
                      fieldName: "Name",
                      value: appointment.patientName,
                    ),
                    _buildSubFields(
                      context,
                      fieldName: "Age",
                      value: "${appointment.age} years old",
                    ),
                    _buildSubFields(
                      context,
                      fieldName: "Gender",
                      value: appointment.gender,
                    ),
                    Divider(color: AppColors.secondary),
                    _buildSubFields(
                      context,
                      fieldName: "Date of birth",
                      value:
                          AppConstants.instance.dobFormatter(appointment.dob),
                    ),
                    if (appointment.allergies.isNotEmpty)
                      _buildSubFields(
                        context,
                        fieldName: "Allergies",
                        value: appointment.allergies,
                      ),
                    if (appointment.nextOfKin.isNotEmpty)
                      _buildSubFields(
                        context,
                        fieldName: "Next of Kin",
                        value: appointment.nextOfKin,
                      ),
                    Divider(color: AppColors.secondary),
                    _buildSubFields(
                      context,
                      fieldName: "Hospital",
                      value: appointment.hospitalName,
                    ),
                    _buildSubFields(
                      context,
                      fieldName: "Test",
                      value: appointment.testName,
                    ),
                    if (appointment.medicalHistory.isNotEmpty)
                      _buildSubFields(
                        context,
                        fieldName: "Medical History",
                        value: appointment.medicalHistory,
                      ),
                    Divider(color: AppColors.secondary),
                    _buildSubFields(
                      context,
                      fieldName: "Available date",
                      value: AppConstants.instance.appointmentDateFormatter(
                          appointment.appointmentDate),
                    ),
                    12.0.verticalSpacing,
                    Row(
                      spacing: 12,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => ref
                              .read(appointmentControllerProvider.notifier)
                              .deleteAppointment(appointment.id),
                          child: Text("Delete"),
                        ),
                        if (!appointment.isConfirmed)
                          ElevatedButton(
                            onPressed: () => ref
                                .read(appointmentControllerProvider.notifier)
                                .confirmAppointment(appointment.id),
                            child: Text("Accept"),
                          ),
                      ],
                    )
                  ]
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubFields(
    BuildContext context, {
    required String fieldName,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6),
      child: Row(
        spacing: 8,
        children: [
          Text(
            fieldName,
            style: context.textTheme.labelLarge
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: context.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
