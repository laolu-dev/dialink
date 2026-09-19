import 'package:json_annotation/json_annotation.dart';

part 'response.g.dart';

@JsonSerializable(
  genericArgumentFactories: true,
  createToJson: false,
)
class ApiResponse<T> {
  ApiResponse({
    required this.status,
    required this.message,
    this.data,
  });

  final String status;

  final String message;

  final T? data;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$ApiResponseFromJson<T>(json, fromJsonT);
}
