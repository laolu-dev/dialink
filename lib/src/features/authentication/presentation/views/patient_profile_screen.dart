import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import 'package:dialink/src/core/core.dart';
import 'package:dialink/src/widgets/common.dart';
import 'package:dialink/src/widgets/skeleton.dart';
import 'package:dialink/src/widgets/custom_dropdown.dart';
import 'package:dialink/src/widgets/custom_scaffold.dart';
import 'package:dialink/src/widgets/custom_textfield.dart';

import 'package:dialink/src/features/authentication/models/patient_profile_model.dart';
import 'package:dialink/src/features/authentication/models/user_model.dart';
import 'package:dialink/src/features/authentication/presentation/controller/authentication_controller.dart';
import 'package:dialink/src/features/authentication/presentation/controller/session_controller.dart';

/// The patient's details and emergency contact.
class PatientProfileScreen extends ConsumerWidget {
  const PatientProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionProvider).value;
    if (user == null) return const SizedBox.shrink();

    final profile = ref.watch(patientProfileProvider(user.id));

    return AppScaffold(
      title: "Your details",
      padding: EdgeInsets.zero,
      child: profile.when(
        data: (profile) => _AccountForm(user: user, profile: profile),
        error: (error, st) => MessageState.error(
          error,
          onRetry: () => ref.invalidate(patientProfileProvider(user.id)),
        ),
        loading: () => const _FormSkeleton(),
      ),
    );
  }
}

class _AccountForm extends ConsumerStatefulWidget {
  const _AccountForm({required this.user, required this.profile});

  final UserModel user;
  final PatientProfileModel? profile;

  @override
  ConsumerState<_AccountForm> createState() => _AccountFormState();
}

class _AccountFormState extends ConsumerState<_AccountForm> {
  late final firstname = TextEditingController(text: widget.user.firstName);
  late final lastname = TextEditingController(text: widget.user.lastName);
  late final phoneNo = TextEditingController(text: widget.user.phone);
  late final gender = TextEditingController(text: widget.profile?.gender);
  late final address = TextEditingController(text: widget.profile?.address);
  late final contactName = TextEditingController(
    text: widget.profile?.emergencyContact?.name,
  );
  late final contactPhone = TextEditingController(
    text: widget.profile?.emergencyContact?.phone,
  );
  late final contactRelationship = TextEditingController(
    text: widget.profile?.emergencyContact?.relationship,
  );

  late final ValueNotifier<DateTime?> dob = ValueNotifier(
    DateTime.tryParse(widget.profile?.dateOfBirth ?? ''),
  );

  final GlobalKey<FormState> _form = GlobalKey<FormState>();

  @override
  void dispose() {
    for (final c in [
      firstname,
      lastname,
      phoneNo,
      gender,
      address,
      contactName,
      contactPhone,
      contactRelationship,
    ]) {
      c.dispose();
    }
    dob.dispose();
    AppConstants.instance.closeKeyboard();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(authenticationControllerProvider);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(context, "About you"),
            Text(
              widget.user.email,
              style: context.textTheme.bodyMedium!.copyWith(
                color: context.palette.muted,
              ),
            ),
            12.0.verticalSpacing,
            CustomTextfield(
              label: "First name",
              hint: "e.g. Amara",
              controller: firstname,
              inputType: TextInputType.name,
              autofillHints: const [AutofillHints.givenName],
              validator: (value) => AppConstants.nameValidator(value!),
            ),
            CustomTextfield(
              label: "Last name",
              hint: "e.g. Okafor",
              controller: lastname,
              inputType: TextInputType.name,
              autofillHints: const [AutofillHints.familyName],
              validator: (value) => AppConstants.nameValidator(value!),
            ),
            CustomTextfield(
              label: "Phone number",
              hint: "+2348012345678",
              controller: phoneNo,
              inputType: TextInputType.phone,
              validator: (value) =>
                  AppConstants.phoneNumberValidator(value!, optional: true),
            ),
            Row(
              spacing: 12,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CustomDropdown(
                    label: "Gender",
                    hint: "Select",
                    controller: gender,
                    options: Gender.values
                        .map((value) => value.gender)
                        .toList(),
                  ),
                ),
                Expanded(child: _buildDob()),
              ],
            ),
            CustomTextfield(
              label: "Address",
              hint: "Home address",
              controller: address,
              maxLines: 2,
              maxLength: 500,
            ),
            _sectionTitle(context, "Emergency contact"),
            CustomTextfield(
              label: "Name",
              hint: "Full name",
              controller: contactName,
              validator: (_) => _contactValidator(),
            ),
            Row(
              spacing: 12,
              children: [
                Flexible(
                  flex: 3,
                  child: CustomTextfield(
                    label: "Phone",
                    hint: "+2348012345678",
                    controller: contactPhone,
                    inputType: TextInputType.phone,
                    validator: (value) => contactName.text.trim().isEmpty
                        ? null
                        : AppConstants.phoneNumberValidator(value!),
                  ),
                ),
                Flexible(
                  flex: 2,
                  child: CustomTextfield(
                    label: "Relationship",
                    hint: "e.g. brother",
                    controller: contactRelationship,
                  ),
                ),
              ],
            ),
            8.0.verticalSpacing,
            PrimaryButton(
              label: "Save",
              loading: controller.isLoading,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.only(top: 16, bottom: 8),
      child: Semantics(
        header: true,
        child: Text(title, style: context.textTheme.titleLarge),
      ),
    );
  }

  Widget _buildDob() {
    return Column(
      spacing: 4,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Date of birth", style: context.textTheme.labelLarge),
        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () async {
            final now = DateTime.now();
            final date = await showDatePicker(
              context: context,
              initialDate: dob.value ?? DateTime(now.year - 30),
              firstDate: DateTime(1900),
              lastDate: now.subtract(const Duration(days: 1)),
            );

            if (date != null) {
              dob.value = date;
            }
          },
          child: InputDecorator(
            decoration: InputDecoration(
              suffixIcon: Icon(Iconsax.calendar_1, size: 20),
            ),
            child: ValueListenableBuilder(
              valueListenable: dob,
              builder: (context, date, _) => Text(
                date == null ? "Select" : AppTime.apiDate(date),
                style: context.textTheme.bodyLarge,
              ),
            ),
          ),
        ),
        14.0.verticalSpacing,
      ],
    );
  }

  /// The contact is optional, but needs both a name and a phone if given.
  String? _contactValidator() {
    final hasName = contactName.text.trim().isNotEmpty;
    final hasPhone = contactPhone.text.trim().isNotEmpty;
    if (!hasName && hasPhone) return 'Enter their name';
    return null;
  }

  String? _orNull(TextEditingController c) =>
      c.text.trim().isEmpty ? null : c.text.trim();

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    AppConstants.instance.closeKeyboard();

    final account = {
      "firstName": firstname.text.trim(),
      "lastName": lastname.text.trim(),
      if (phoneNo.text.trim().isNotEmpty) "phone": phoneNo.text.trim(),
    };

    final profile = PatientProfileModel(
      dateOfBirth: dob.value == null ? null : AppTime.apiDate(dob.value!),
      gender: _orNull(gender),
      address: _orNull(address),
      emergencyContact: _orNull(contactName) == null
          ? null
          : EmergencyContact(
              name: contactName.text.trim(),
              phone: contactPhone.text.trim(),
              relationship: _orNull(contactRelationship),
            ),
    );

    final result = await ref
        .read(authenticationControllerProvider.notifier)
        .updateAccount(widget.user.id, account: account, profile: profile);
    switch (result) {
      case Success():
        AppConstants.instance.showSuccess("Your details are saved.");
      case Failure(:final value):
        AppConstants.instance.showError(value.message);
    }
  }
}

/// The shape of the form while the details load.
class _FormSkeleton extends StatelessWidget {
  const _FormSkeleton();

  @override
  Widget build(BuildContext context) {
    // Scrolls, so it never overflows above a keyboard or in landscape.
    return Shimmer(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              const SkeletonBox(width: 120, height: 22),
              const SkeletonBox(width: 200),
              for (var i = 0; i < 4; i++) ...const [
                SizedBox(height: 6),
                SkeletonBox(width: 90),
                SkeletonBox(height: 52, radius: 14),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
