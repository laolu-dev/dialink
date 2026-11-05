import 'package:json_annotation/json_annotation.dart';

part 'response.g.dart';

/// A page of a list endpoint: `{ items, page, size, totalElements }`.
@JsonSerializable(genericArgumentFactories: true, createToJson: false)
class PageResponse<T> {
  const PageResponse({
    required this.items,
    required this.page,
    required this.size,
    required this.totalElements,
  });

  final List<T> items;

  /// Zero-based.
  final int page;

  final int size;

  final int totalElements;

  bool get hasMore => (page + 1) * size < totalElements;

  factory PageResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$PageResponseFromJson<T>(json, fromJsonT);
}
