import 'package:dialink/src/core/api/exception.dart';
import 'package:dialink/src/core/core.dart';

import 'package:dialink/src/features/book-appointment/models/appointment_model.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'appointment_repository.g.dart';

class AppointmentRepository {
  const AppointmentRepository(this._api);
  final Dio _api;

  FutureResultOf<List<AppointmentModel>> getAppointments(String userId) async {
    try {
      final response = await _api.get(
        ApiEndpoints.getAppointments,
        data: {"userId": userId},
      );

      final result = ApiResponse<List<AppointmentModel>>.fromJson(
        response.data,
        (json) => json is List<dynamic>
            ? json
                .map<AppointmentModel>(
                    (i) => AppointmentModel.fromJson(i as Map<String, dynamic>))
                .toList()
            : List.empty(),
      );

      return Success(result);
    } catch (e) {
      final exception = ClientException.handleException(e);
      return Failure(exception);
    }
  }

  FutureResultOf<void> createAppointment(Map<String, dynamic> payload) async {
    try {
      final response =
          await _api.post(ApiEndpoints.createAppointment, data: payload);

      final result = ApiResponse<void>.fromJson(response.data, (json) {});
      return Success(result);
    } catch (e) {
      final exception = ClientException.handleException(e);
      return Failure(exception);
    }
  }

  FutureResultOf<void> confirmAppointment(String id, bool status) async {
    try {
      final response = await _api.post(
        ApiEndpoints.confirmAppointment,
        data: {"appointmentId": id, "status": status},
      );

      final result = ApiResponse<void>.fromJson(response.data, (json) {});
      return Success(result);
    } catch (e) {
      final exception = ClientException.handleException(e);
      return Failure(exception);
    }
  }

  FutureResultOf<void> deleteAppointment(String id) async {
    try {
      final response = await _api.delete(ApiEndpoints.deleteAppointment(id));

      final result = ApiResponse<void>.fromJson(response.data, (json) {});
      return Success(result);
    } catch (e) {
      final exception = ClientException.handleException(e);
      return Failure(exception);
    }
  }
}

@riverpod
AppointmentRepository appointmentRepo(Ref ref) {
  final dio = ref.watch(dioProvider);
  return AppointmentRepository(dio);
}
