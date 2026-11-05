import 'package:json_annotation/json_annotation.dart';

import 'package:dialink/src/core/utils/enums.dart';

part 'appointment_model.g.dart';

@JsonSerializable(createToJson: false)
class AppointmentModel {
  const AppointmentModel({
    required this.id,
    required this.provider,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.reason,
    this.rescheduledFrom,
  });

  final String id;

  final ProviderSummary provider;

  final DateTime startTime;

  final DateTime endTime;

  @JsonKey(fromJson: AppointmentStatus.fromJson)
  final AppointmentStatus status;

  final String? reason;

  /// The appointment this one replaced, if it was rescheduled.
  final String? rescheduledFrom;

  bool get hasStarted => !startTime.isAfter(DateTime.now());

  bool get canCancel => status.isActive;

  bool get canReschedule => status.isActive && !hasStarted;

  bool get canDelete => status == AppointmentStatus.requested;

  AppointmentModel copyWith({AppointmentStatus? status}) => AppointmentModel(
    id: id,
    provider: provider,
    startTime: startTime,
    endTime: endTime,
    status: status ?? this.status,
    reason: reason,
    rescheduledFrom: rescheduledFrom,
  );

  factory AppointmentModel.fromJson(Map<String, dynamic> json) =>
      _$AppointmentModelFromJson(json);
}

/// `id` is the provider profile id, as in `/providers/{id}`.
@JsonSerializable(createToJson: false)
class ProviderSummary {
  const ProviderSummary({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.specialty,
  });

  final String id;

  final String firstName;

  final String lastName;

  final String specialty;

  String get name => 'Dr. $firstName $lastName';

  factory ProviderSummary.fromJson(Map<String, dynamic> json) =>
      _$ProviderSummaryFromJson(json);
}
