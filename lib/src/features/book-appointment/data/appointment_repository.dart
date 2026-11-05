import 'package:dialink/src/core/core.dart';

import 'package:dialink/src/features/book-appointment/models/appointment_model.dart';
import 'package:dialink/src/features/book-appointment/models/provider_model.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'appointment_repository.g.dart';

class AppointmentRepository {
  const AppointmentRepository(this._api);
  final Dio _api;

  /// Both filters are optional, case-insensitive and match anywhere.
  FutureResultOf<PageResponse<ProviderModel>> searchProviders({
    String? name,
    String? specialty,
    int page = 0,
    int size = 20,
    CancelToken? cancelToken,
  }) => guard(() async {
    final response = await _api.get(
      ApiEndpoints.providers,
      queryParameters: {
        if (name != null && name.isNotEmpty) "name": name,
        "specialty": ?specialty,
        "page": page,
        "size": size,
      },
      cancelToken: cancelToken,
    );
    return PageResponse.fromJson(
      response.data,
      (json) => ProviderModel.fromJson(json as Map<String, dynamic>),
    );
  });

  FutureResultOf<List<String>> getSpecialties() => guard(() async {
    final response = await _api.get<List<dynamic>>(ApiEndpoints.specialties);
    return response.data!.cast<String>();
  });

  FutureResultOf<ProviderModel> getProvider(String id) => guard(() async {
    final response = await _api.get(ApiEndpoints.provider(id));
    return ProviderModel.fromJson(response.data);
  });

  /// Free slots between two dates in the provider's zone, at most 31 days apart.
  FutureResultOf<PageResponse<SlotModel>> getAvailability(
    String providerId, {
    required DateTime from,
    required DateTime to,
    int page = 0,
    int size = 100,
  }) => guard(() async {
    final response = await _api.get(
      ApiEndpoints.availability(providerId),
      queryParameters: {
        "from": AppTime.apiDate(from),
        "to": AppTime.apiDate(to),
        "page": page,
        "size": size,
      },
    );
    return PageResponse.fromJson(
      response.data,
      (json) => SlotModel.fromJson(json as Map<String, dynamic>),
    );
  });

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
