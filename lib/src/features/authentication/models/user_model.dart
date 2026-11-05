import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.emailVerified,
    this.phone,
  });

  final String id;

  final String email;

  final String firstName;

  final String lastName;

  final String? phone;

  /// `PATIENT`, `PROVIDER` or `ADMIN`.
  final String role;

  /// Patients must confirm their address before booking.
  final bool emailVerified;

  String get name => '$firstName $lastName';

  UserModel copyWith({bool? emailVerified}) => UserModel(
    id: id,
    email: email,
    firstName: firstName,
    lastName: lastName,
    role: role,
    emailVerified: emailVerified ?? this.emailVerified,
    phone: phone,
  );

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
