import 'dart:async';

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:dialink/src/core/network/api_client.dart';
import 'package:dialink/src/core/network/api_endpoints.dart';
import 'package:dialink/src/core/network/page_response.dart';
import 'package:dialink/src/core/network/result.dart';
import 'package:dialink/src/core/storage/cache.dart';
import 'package:dialink/src/core/utils/time.dart';
import 'package:dialink/src/data/doctors/models/provider_model.dart';
part 'doctor_repository.g.dart';

/// Doctors (called providers by the API), their specialties and free times.
class DoctorRepository {
  const DoctorRepository(this._api);
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
}

@riverpod
DoctorRepository doctorRepo(Ref ref) =>
    DoctorRepository(ref.watch(dioProvider));

/// The list changes rarely, so it is kept for a while.
@riverpod
Future<List<String>> specialties(Ref ref) async {
  ref.cacheFor(const Duration(hours: 1));
  final result = await ref.watch(doctorRepoProvider).getSpecialties();
  return result.fold((specialties) => specialties, (error) => throw error);
}

/// The first 50 matches; [PageResponse.hasMore] says whether there are more.
///
/// A new query is a new provider; the old one is disposed and its request
/// cancelled.
@riverpod
Future<PageResponse<ProviderModel>> searchProviders(
  Ref ref, {
  String? name,
  String? specialty,
}) async {
  final cancelToken = ref.cancelToken();
  final result = await ref
      .watch(doctorRepoProvider)
      .searchProviders(
        name: name,
        specialty: specialty,
        size: 50,
        cancelToken: cancelToken,
      );
  return result.fold((page) => page, (error) => throw error);
}

/// Providers rarely change, and their time zone is needed to show every
/// appointment, so they are kept for a while once loaded.
@riverpod
Future<ProviderModel> provider(Ref ref, String id) async {
  ref.cacheFor(const Duration(minutes: 30));
  final result = await ref.watch(doctorRepoProvider).getProvider(id);
  return result.fold((provider) => provider, (error) => throw error);
}

/// Free slots in the 7 days from [from], a date in the provider's zone,
/// grouped by day in that zone ([timeZone]).
///
/// A week of short slots can run past one page, so every page is read, up to
/// [_maxSlotPages]. Weeks are kept briefly, so paging back and forth does not
/// fetch them again; any booking or cancellation drops them.
@riverpod
Future<List<SlotDay>> availability(
  Ref ref, {
  required String providerId,
  required String timeZone,
  required DateTime from,
}) async {
  ref.cacheFor(const Duration(minutes: 2));
  final repo = ref.watch(doctorRepoProvider);
  final byDay = <DateTime, List<SlotModel>>{};

  for (var page = 0; page < _maxSlotPages; page++) {
    final result = await repo.getAvailability(
      providerId,
      from: from,
      to: from.add(const Duration(days: 6)),
      page: page,
    );
    final response = result.fold((week) => week, (error) => throw error);
    for (final slot in response.items) {
      final day = AppTime.dateOf(AppTime.inZone(slot.startTime, timeZone));
      byDay.putIfAbsent(day, () => []).add(slot);
    }
    if (!response.hasMore) break;
  }
  return [
    for (final MapEntry(key: date, value: slots) in byDay.entries)
      SlotDay(date: date, slots: slots),
  ];
}

const _maxSlotPages = 10;
