import 'package:json_annotation/json_annotation.dart';

part 'provider_model.g.dart';

@JsonSerializable(createToJson: false)
class ProviderModel {
  const ProviderModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.specialty,
    required this.timeZone,
    this.yearsExperience,
  });

  final String id;

  final String firstName;

  final String lastName;

  final String specialty;

  final int? yearsExperience;

  /// IANA id, e.g. `Africa/Lagos`. Appointment times are shown in this zone.
  final String timeZone;

  String get name => 'Dr. $firstName $lastName';

  factory ProviderModel.fromJson(Map<String, dynamic> json) =>
      _$ProviderModelFromJson(json);
}

/// A bookable slot. Only slots at least 2 hours ahead and not taken are listed.
@JsonSerializable(createToJson: false)
class SlotModel {
  const SlotModel({required this.startTime, required this.endTime});

  final DateTime startTime;

  final DateTime endTime;

  factory SlotModel.fromJson(Map<String, dynamic> json) =>
      _$SlotModelFromJson(json);
}

/// One calendar day's free slots, in the provider's zone.
class SlotDay {
  const SlotDay({required this.date, required this.slots});

  /// The calendar date, as a UTC midnight.
  final DateTime date;

  final List<SlotModel> slots;
}
