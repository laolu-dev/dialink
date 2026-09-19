import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable(createToJson: false)
class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.token,
    required this.gender,
  });

  final String id;

  final String name;

  final String token;

  final String gender;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
