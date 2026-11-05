import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:dialink/src/core/network/api_client.dart';
import 'package:dialink/src/core/network/api_endpoints.dart';
import 'package:dialink/src/core/network/page_response.dart';
import 'package:dialink/src/core/network/result.dart';
import 'package:dialink/src/data/appointments/models/appointment_model.dart';
part 'appointment_repository.g.dart';

class AppointmentRepository {
  const AppointmentRepository(this._api);
  final Dio _api;

  /// Newest start first.
  FutureResultOf<PageResponse<AppointmentModel>> getAppointments(
    String userId, {
    int page = 0,
    int size = 20,
  }) => guard(() async {
    final response = await _api.get(
      ApiEndpoints.userAppointments(userId),
      queryParameters: {"page": page, "size": size},
    );
    return PageResponse.fromJson(
      response.data,
      (json) => AppointmentModel.fromJson(json as Map<String, dynamic>),
    );
  });

  /// Books a slot. [idempotencyKey] must be the same on every retry of one
  /// attempt, so a retry returns the same appointment instead of booking twice.
  FutureResultOf<AppointmentModel> createAppointment({
    required String providerId,
    required String startTime,
    required String idempotencyKey,
    String? reason,
  }) => guard(() async {
    final response = await _api.post(
      ApiEndpoints.appointments,
      data: {
        "providerId": providerId,
        "startTime": startTime,
        if (reason != null && reason.trim().isNotEmpty) "reason": reason,
      },
      options: Options(headers: {"Idempotency-Key": idempotencyKey}),
    );
    return AppointmentModel.fromJson(response.data);
  });

  FutureResultOf<AppointmentModel> cancelAppointment(String id) =>
      guard(() async {
        final response = await _api.patch(ApiEndpoints.cancelAppointment(id));
        return AppointmentModel.fromJson(response.data);
      });

  /// Returns the new appointment; the old one is cancelled.
  FutureResultOf<AppointmentModel> rescheduleAppointment(
    String id,
    String startTime,
  ) => guard(() async {
    final response = await _api.patch(
      ApiEndpoints.rescheduleAppointment(id),
      data: {"startTime": startTime},
    );
    return AppointmentModel.fromJson(response.data);
  });

  /// Only while the appointment is still `REQUESTED`.
  FutureResultOf<void> deleteAppointment(String id) => guard(() async {
    await _api.delete(ApiEndpoints.appointment(id));
  });
}

@riverpod
AppointmentRepository appointmentRepo(Ref ref) {
  final dio = ref.watch(dioProvider);
  return AppointmentRepository(dio);
}
