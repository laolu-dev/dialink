import 'package:json_annotation/json_annotation.dart';

part 'patient_profile_model.g.dart';

/// Health details, encrypted at rest on the server. Saving replaces the whole
/// profile: omitted fields are cleared.
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class PatientProfileModel {
  const PatientProfileModel({
    this.dateOfBirth,
    this.gender,
    this.address,
    this.emergencyContact,
  });

  /// A calendar date, `yyyy-MM-dd`.
  final String? dateOfBirth;

  final String? gender;

  final String? address;

  final EmergencyContact? emergencyContact;

  factory PatientProfileModel.fromJson(Map<String, dynamic> json) =>
      _$PatientProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$PatientProfileModelToJson(this);
}

@JsonSerializable(includeIfNull: false)
class EmergencyContact {
  const EmergencyContact({
    required this.name,
    required this.phone,
    this.relationship,
  });

  final String name;

  /// E.164.
  final String phone;

  final String? relationship;

  factory EmergencyContact.fromJson(Map<String, dynamic> json) =>
      _$EmergencyContactFromJson(json);

  Map<String, dynamic> toJson() => _$EmergencyContactToJson(this);
}
