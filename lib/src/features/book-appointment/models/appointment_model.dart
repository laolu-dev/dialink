// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:json_annotation/json_annotation.dart';

part 'appointment_model.g.dart';

@JsonSerializable(createToJson: false)
class AppointmentModel {
  const AppointmentModel({
    required this.id,
    required this.patientName,
    required this.age,
    required this.gender,
    required this.dob,
    required this.isConfirmed,
    required this.hospitalName,
    required this.testName,
    required this.nextOfKin,
    required this.allergies,
    required this.medicalHistory,
    required this.appointmentDate,
    required this.version,
  });

  @JsonKey(name: "_id")
  final String id;

  final String patientName;

  final String age;

  final String gender;

  final String dob;

  final bool isConfirmed;

  final String hospitalName;

  final String testName;

  final String nextOfKin;

  final String allergies;

  final String appointmentDate;

  @JsonKey(name: "history")
  final String medicalHistory;

  @JsonKey(name: "__v")
  final int version;

  factory AppointmentModel.fromJson(Map<String, dynamic> json) =>
      _$AppointmentModelFromJson(json);
}
