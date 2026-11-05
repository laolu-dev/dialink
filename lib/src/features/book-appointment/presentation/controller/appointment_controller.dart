import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import 'package:dialink/src/core/core.dart';
import 'package:dialink/src/features/authentication/presentation/controller/session_controller.dart';
import 'package:dialink/src/features/book-appointment/data/appointment_repository.dart';
import 'package:dialink/src/features/book-appointment/models/appointment_model.dart';
import 'package:dialink/src/features/book-appointment/models/provider_model.dart';

part 'appointment_controller.g.dart';

typedef AppointmentResult = Result<String, ClientException>;

/// Changes to appointments. The state tracks the one in progress, for spinners.
///
/// Each change returns its outcome, a success message or the
/// [ClientException], to the screen that started it, which shows the feedback
/// and can branch on the problem type, e.g. refresh the slots after
/// `slot-unavailable`.
@riverpod
class AppointmentController extends _$AppointmentController {
  /// One key per booking attempt, reused if the same attempt is retried.
  String? _idempotencyKey;
  String? _attempt;

  static const _busy = Failure<String, ClientException>(
    ClientException(message: 'Please wait for the current change to finish.'),
  );

  @override
  FutureOr<String?> build() => null;

  Future<AppointmentResult> createAppointment({
    required ProviderModel provider,
    required SlotModel slot,
    String? reason,
  }) {
    final attempt =
        '${provider.id}|${slot.startTime.toIso8601String()}|$reason';
    if (attempt != _attempt) {
      _attempt = attempt;
      _idempotencyKey = const Uuid().v4();
    }
    final key = _idempotencyKey!;

    return _run(
      (repo) => repo.createAppointment(
        providerId: provider.id,
        startTime: AppTime.withOffset(slot.startTime, provider.timeZone),
        idempotencyKey: key,
        reason: reason,
      ),
      'Appointment requested. The provider will confirm it.',
      update: (list, created) {
        _attempt = null;
        list?.upsert(created);
      },
      slotsChanged: true,
    );
  }

  Future<AppointmentResult> rescheduleAppointment({
    required AppointmentModel appointment,
    required ProviderModel provider,
    required SlotModel slot,
  }) => _run(
    (repo) => repo.rescheduleAppointment(
      appointment.id,
      AppTime.withOffset(slot.startTime, provider.timeZone),
    ),
    'Appointment moved. The provider will confirm the new time.',
    // The server cancels the old one and returns its replacement.
    update: (list, moved) => list
      ?..upsert(appointment.copyWith(status: AppointmentStatus.cancelled))
      ..upsert(moved),
    slotsChanged: true,
  );

  Future<AppointmentResult> cancelAppointment(String id) => _run(
    (repo) => repo.cancelAppointment(id),
    'Appointment cancelled.',
    update: (list, cancelled) => list?.upsert(cancelled),
    slotsChanged: true,
  );

  Future<AppointmentResult> deleteAppointment(String id) => _run(
    (repo) => repo.deleteAppointment(id),
    'Appointment deleted.',
    update: (list, _) => list?.remove(id),
    slotsChanged: true,
  );

  /// One change at a time: a second tap while one is running is refused.
  ///
  /// On success [update] shows the change in the loaded list, which is null
  /// when no screen shows it. Booked or freed times make cached [availability]
  /// stale, so it is dropped when [slotsChanged].
  Future<AppointmentResult> _run<T>(
    FutureResultOf<T> Function(AppointmentRepository repo) change,
    String message, {
    required void Function(Appointments? list, T value) update,
    bool slotsChanged = false,
  }) async {
    if (state.isLoading) return _busy;

    final repo = ref.read(appointmentRepoProvider);
    final userId = ref.read(sessionProvider).value?.id;
    final listProvider = userId == null ? null : appointmentsProvider(userId);
    // Read now: the screen that started the change may be gone when it ends.
    final list = listProvider != null && ref.exists(listProvider)
        ? ref.read(listProvider.notifier)
        : null;
    final container = ref.container;
    state = const AsyncLoading();

    final response = await change(repo);
    if (response case Success(:final value)) {
      update(list, value);
      if (slotsChanged) container.invalidate(availabilityProvider);
    }
    final AppointmentResult result = switch (response) {
      Success() => Success(message),
      Failure(:final value) => Failure(value),
    };

    if (ref.mounted) {
      state = switch (result) {
        Success(:final value) => AsyncData(value),
        Failure(:final value) => AsyncError(value, StackTrace.current),
      };
    }
    return result;
  }
}

/// The patient's appointments, newest start first, a page at a time.
@riverpod
class Appointments extends _$Appointments {
  static const _pageSize = 20;

  int _page = 0;
  bool _hasMore = false;
  bool _loadingMore = false;

  /// Bumped on every rebuild, so a page that arrives after a refresh is
  /// dropped instead of being appended to the fresh list.
  int _generation = 0;

  bool get hasMore => _hasMore;

  @override
  Future<List<AppointmentModel>> build(String userId) async {
    final generation = ++_generation;
    _page = 0;
    _loadingMore = false;

    final first = await _fetch(0);
    if (generation == _generation) _hasMore = first.hasMore;
    return first.items;
  }

  /// Loads the next page. Returns false if it failed; what is shown is kept.
  Future<bool> loadMore() async {
    final current = state.value;
    if (current == null || !_hasMore || _loadingMore) return true;

    final generation = _generation;
    _loadingMore = true;
    try {
      final next = await _fetch(_page + 1);
      if (generation != _generation || !ref.mounted) return true;

      _page++;
      _hasMore = next.hasMore;
      // Pages are offsets into a list that can change between requests, so
      // an appointment can appear twice; keep one, in its latest form.
      final byId = {
        for (final appointment in [...current, ...next.items])
          appointment.id: appointment,
      };
      state = AsyncData(byId.values.toList());
      return true;
    } catch (_) {
      return false;
    } finally {
      if (generation == _generation) _loadingMore = false;
    }
  }

  /// Shows an appointment the server returned after a change, in its place,
  /// without downloading the list again.
  void upsert(AppointmentModel appointment) {
    final current = state.value;
    if (current == null || !ref.mounted) return;

    final rest = [
      for (final a in current)
        if (a.id != appointment.id) a,
    ];
    // Past the pages loaded so far: it comes with its own page.
    final beyondLoaded =
        _hasMore && rest.isNotEmpty && _newestFirst(appointment, rest.last) > 0;
    state = AsyncData(
      beyondLoaded ? rest : ([...rest, appointment]..sort(_newestFirst)),
    );
  }

  void remove(String id) {
    final current = state.value;
    if (current == null || !ref.mounted) return;

    // Every later page now starts one appointment earlier, so the next one
    // would skip an appointment. Reload instead.
    if (_hasMore) return ref.invalidateSelf();
    state = AsyncData([
      for (final a in current)
        if (a.id != id) a,
    ]);
  }

  /// The server's order: newest start first, then by id.
  static int _newestFirst(AppointmentModel a, AppointmentModel b) {
    final byStart = b.startTime.compareTo(a.startTime);
    return byStart != 0 ? byStart : a.id.compareTo(b.id);
  }

  Future<PageResponse<AppointmentModel>> _fetch(int page) async {
    final result = await ref
        .read(appointmentRepoProvider)
        .getAppointments(userId, page: page, size: _pageSize);
    return result.fold((response) => response, (error) => throw error);
  }
}

/// The list changes rarely, so it is kept for a while.
@riverpod
Future<List<String>> specialties(Ref ref) async {
  ref.cacheFor(const Duration(hours: 1));
  final result = await ref.watch(appointmentRepoProvider).getSpecialties();
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
      .watch(appointmentRepoProvider)
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
  final result = await ref.watch(appointmentRepoProvider).getProvider(id);
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
  final repo = ref.watch(appointmentRepoProvider);
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
