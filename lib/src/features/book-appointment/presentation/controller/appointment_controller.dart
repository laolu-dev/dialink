import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:dialink/src/features/book-appointment/data/appointment_repository.dart';
import 'package:dialink/src/features/book-appointment/models/appointment_model.dart';

part 'appointment_controller.g.dart';

@riverpod
class AppointmentController extends _$AppointmentController {
  late final AppointmentRepository _repository;

  @override
  FutureOr<String?> build() {
    _repository = ref.watch(appointmentRepoProvider);
    return null;
  }

  void createAppointment(Map<String, dynamic> payload) async {
    state = AsyncLoading();

    final response = await _repository.createAppointment(payload);
    response.fold(
      (success) => state = AsyncData(success.message),
      (exception) => state = AsyncError(exception.message, StackTrace.current),
    );
  }

  void confirmAppointment(String id) async {
    state = AsyncLoading();

    final response = await _repository.confirmAppointment(id, true);
    response.fold(
      (success) => state = AsyncData(success.message),
      (exception) => state = AsyncError(exception.message, StackTrace.current),
    );
  }

  void deleteAppointment(String id) async {
    state = AsyncLoading();

    final response = await _repository.deleteAppointment(id);
    response.fold(
      (success) => state = AsyncData(success.message),
      (exception) => state = AsyncError(exception.message, StackTrace.current),
    );
  }
}

@riverpod
Future<List<AppointmentModel>?> fetchAppointments(
  Ref ref, {
  required String userId,
}) async {
  final result =
      await ref.watch(appointmentRepoProvider).getAppointments(userId);

  return result.fold(
    (response) => response.data,
    (error) => throw error,
  );
}
