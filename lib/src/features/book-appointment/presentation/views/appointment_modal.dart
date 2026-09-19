import 'package:dialink/src/core/core.dart';
import 'package:dialink/src/core/utils/enums.dart';
import 'package:dialink/src/features/book-appointment/presentation/controller/appointment_controller.dart';
import 'package:dialink/src/widgets/custom_textfield.dart';
import 'package:dialink/src/widgets/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class BookAppointmentDate extends ConsumerStatefulWidget {
  const BookAppointmentDate({super.key, required this.userId});
  final String userId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BookAppointmentDateState();
}

class _BookAppointmentDateState extends ConsumerState<BookAppointmentDate> {
  final TextEditingController name = TextEditingController();
  final TextEditingController age = TextEditingController();
  final TextEditingController gender = TextEditingController();
  final TextEditingController hospital = TextEditingController();
  final TextEditingController testType = TextEditingController();
  final TextEditingController nextOfKin = TextEditingController();
  final TextEditingController allergies = TextEditingController();
  final TextEditingController history = TextEditingController();

  final GlobalKey<FormState> _form = GlobalKey<FormState>();

  final ValueNotifier<DateTime> dob = ValueNotifier<DateTime>(DateTime.now());

  @override
  void dispose() {
    name.dispose();
    age.dispose();
    gender.dispose();
    hospital.dispose();
    testType.dispose();
    nextOfKin.dispose();
    allergies.dispose();
    history.dispose();
    _form.currentState?.dispose();
    AppConstants.instance.closeKeyboard();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Form(
          key: _form,
          child: Card(
            color: AppColors.background,
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 24),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () => context.router.pop(),
                      child: Icon(Iconsax.close_circle),
                    ),
                  ),
                  Center(
                    child: Text(
                      "Create Appointment",
                      style: context.textTheme.headlineLarge!.copyWith(
                        fontFamily: AppConstants.instance.cooperBtFont,
                      ),
                    ),
                  ),
                  Text(
                    "Fill this form to create a booking.",
                    textAlign: TextAlign.center,
                    style: context.textTheme.titleMedium,
                  ),
                  24.0.verticalSpacing,
                  Row(
                    spacing: 8,
                    children: [
                      Expanded(
                        flex: 4,
                        child: CustomTextfield(
                          label: "Name",
                          hint: "Full name",
                          controller: name,
                        ),
                      ),
                      Flexible(
                        child: CustomTextfield(
                          label: "Age",
                          hint: "Age",
                          controller: age,
                          inputType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: CustomDropdown(
                          label: "Gender",
                          hint: "Select Gender",
                          controller: gender,
                          options: Gender.values
                              .map((value) => value.gender)
                              .toList(),
                        ),
                      ),
                      Expanded(child: _buildDob()),
                    ],
                  ),
                  Row(
                    spacing: 8,
                    children: [
                      Expanded(
                        flex: 2,
                        child: CustomTextfield(
                          label: "Hospital name",
                          hint: "Name of hospital",
                          controller: hospital,
                        ),
                      ),
                      Flexible(
                        child: CustomDropdown(
                          label: "Test required",
                          hint: "Test",
                          controller: testType,
                          options: DiagnosisType.values
                              .map((value) => value.diagnosis)
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                  CustomTextfield(
                    label: "Next of Kin",
                    hint: "Next of kin's name",
                    controller: nextOfKin,
                  ),
                  CustomTextfield(
                    label: "Allergies:",
                    hint: "Any known allergies",
                    maxLines: 2,
                    maxLength: 200,
                    controller: allergies,
                  ),
                  CustomTextfield(
                    label: "Provisional diagnosis and history",
                    hint: "A brief history of why you want to see the doctor.",
                    maxLines: 5,
                    maxLength: 750,
                    controller: history,
                  ),
                  16.0.verticalSpacing,
                  TextButton(
                    onPressed: _createAppointment,
                    child: Text("Get Date"),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDob() {
    return Column(
      spacing: 4,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Date of Birth", style: context.textTheme.labelLarge),
        InkWell(
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              firstDate: DateTime(2000),
              lastDate: DateTime(2030),
            );

            if (date != null) {
              dob.value = date;
            }
          },
          child: Container(
            padding: EdgeInsets.fromLTRB(18, 12, 18, 12),
            decoration: BoxDecoration(
              border: Border.all(
                width: 0.5,
                color: AppColors.secondary.withValues(alpha: .6),
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: ValueListenableBuilder(
              valueListenable: dob,
              builder: (context, date, _) => Text(
                DateFormat.yMd().format(date),
              ),
            ),
          ),
        ),
        12.0.verticalSpacing
      ],
    );
  }

  void _createAppointment() {
    Map<String, dynamic> payload = {
      "userId": widget.userId,
      "name": name.text,
      "age": age.text,
      "gender": gender.text,
      "dob": dob.value.toIso8601String(),
      "hospitalName": hospital.text,
      "nameOfTest": testType.text,
      "medicalHistory": history.text,
      "allergies": allergies.text.isEmpty ? "No allergen" : allergies.text
    };
    if (nextOfKin.text.isNotEmpty) {
      payload.addAll({"nextOfKin": nextOfKin.text});
    }
    ref.read(appointmentControllerProvider.notifier).createAppointment(payload);
    context.router.pop();
  }
}
