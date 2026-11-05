import 'dart:async';

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:dialink/src/core/network/api_client.dart';
import 'package:dialink/src/core/network/api_endpoints.dart';
import 'package:dialink/src/core/network/result.dart';
import 'package:dialink/src/data/users/models/patient_profile_model.dart';
import 'package:dialink/src/data/users/models/user_model.dart';
part 'user_repository.g.dart';

/// The patient's account and patient profile.
class UserRepository {
  const UserRepository(this._api);
  final Dio _api;

  FutureResultOf<UserModel> getUser(String id) => guard(() async {
    final response = await _api.get(ApiEndpoints.user(id));
    return UserModel.fromJson(response.data);
  });

  /// Partial update of `firstName`, `lastName` and `phone`.
  FutureResultOf<UserModel> updateUser(
    String id,
    Map<String, dynamic> payload,
  ) => guard(() async {
    final response = await _api.patch(ApiEndpoints.user(id), data: payload);
    return UserModel.fromJson(response.data);
  });

  /// Null until the patient saves one.
  FutureResultOf<PatientProfileModel?> getPatientProfile(String userId) =>
      guard(() async {
        try {
          final response = await _api.get(ApiEndpoints.patientProfile(userId));
          return PatientProfileModel.fromJson(response.data);
        } on DioException catch (e) {
          if (e.response?.statusCode == 404) return null;
          rethrow;
        }
      });

  FutureResultOf<PatientProfileModel> savePatientProfile(
    String userId,
    PatientProfileModel profile,
  ) => guard(() async {
    final response = await _api.put(
      ApiEndpoints.patientProfile(userId),
      data: profile.toJson(),
    );
    return PatientProfileModel.fromJson(response.data);
  });
}

@riverpod
UserRepository userRepo(Ref ref) => UserRepository(ref.watch(dioProvider));

@riverpod
Future<PatientProfileModel?> patientProfile(Ref ref, String userId) async {
  final result = await ref.watch(userRepoProvider).getPatientProfile(userId);
  return result.fold((profile) => profile, (error) => throw error);
}
