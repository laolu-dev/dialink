import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dialink/src/core/network/api_exception.dart';
import 'package:dialink/src/core/network/page_response.dart';
import 'package:dialink/src/core/network/result.dart';
import 'package:dialink/src/data/appointments/appointment_repository.dart';
import 'package:dialink/src/data/appointments/models/appointment_model.dart';
import 'package:dialink/src/data/appointments/models/appointment_status.dart';
import 'package:dialink/src/shared/controllers/appointments_controller.dart';

AppointmentModel _appointment(String id) => AppointmentModel(
  id: id,
  provider: const ProviderSummary(
    id: 'p',
    firstName: 'Ada',
    lastName: 'Obi',
    specialty: 'GP',
  ),
  startTime: DateTime.utc(2026, 11, 3, 9),
  endTime: DateTime.utc(2026, 11, 3, 10),
  status: AppointmentStatus.confirmed,
);

/// Answers each page request with a [Completer] the test completes.
class _FakeRepository extends AppointmentRepository {
  _FakeRepository() : super(Dio());

  final requests = <int, Completer<PageResponse<AppointmentModel>>>{};

  @override
  FutureResultOf<PageResponse<AppointmentModel>> getAppointments(
    String userId, {
    int page = 0,
    int size = 20,
  }) => guard(() => (requests[page] = Completer()).future);

  void answer(int page, List<String> ids, {int total = 100}) =>
      requests[page]!.complete(
        PageResponse(
          items: ids.map(_appointment).toList(),
          page: page,
          size: 20,
          totalElements: total,
        ),
      );
}

void main() {
  late _FakeRepository repo;
  late ProviderContainer container;
  final provider = appointmentsProvider('u');

  setUp(() {
    repo = _FakeRepository();
    container = ProviderContainer(
      overrides: [appointmentRepoProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
  });

  Future<void> loadFirstPage(List<String> ids) async {
    container.listen(provider, (_, _) {});
    await pumpEventQueue();
    repo.answer(0, ids);
    await container.read(provider.future);
  }

  test('appends the next page and drops duplicates', () async {
    await loadFirstPage(['a', 'b']);

    final loading = container.read(provider.notifier).loadMore();
    await pumpEventQueue();
    repo.answer(1, ['b', 'c']);

    expect(await loading, isTrue);
    expect(container.read(provider).value!.map((a) => a.id), ['a', 'b', 'c']);
  });

  test('a page that arrives after a refresh is dropped', () async {
    await loadFirstPage(['a', 'b']);

    final loading = container.read(provider.notifier).loadMore();
    await pumpEventQueue();

    container.invalidate(provider);
    await pumpEventQueue();
    repo.answer(0, ['x']);
    await container.read(provider.future);

    repo.answer(1, ['stale']);
    await loading;

    expect(container.read(provider).value!.map((a) => a.id), ['x']);
  });

  group('changes are shown without reloading', () {
    Future<void> load(List<AppointmentModel> items, {int total = 3}) async {
      container.listen(provider, (_, _) {});
      await pumpEventQueue();
      repo.requests[0]!.complete(
        PageResponse(items: items, page: 0, size: 20, totalElements: total),
      );
      await container.read(provider.future);
    }

    List<String> ids() =>
        container.read(provider).value!.map((a) => a.id).toList();

    test('a new appointment goes in date order', () async {
      await load([_at('c', 20), _at('a', 10)], total: 2);

      container.read(provider.notifier).upsert(_at('b', 15));

      expect(ids(), ['c', 'b', 'a']);
      expect(repo.requests.keys, [0]);
    });

    test('a changed appointment is replaced in place', () async {
      await load([_at('c', 20), _at('a', 10)], total: 2);

      container
          .read(provider.notifier)
          .upsert(_at('a', 10).copyWith(status: AppointmentStatus.cancelled));

      expect(ids(), ['c', 'a']);
      expect(
        container.read(provider).value!.last.status,
        AppointmentStatus.cancelled,
      );
    });

    test('one past the loaded pages is left for its page', () async {
      await load([_at('c', 20), _at('b', 15)], total: 100);

      container.read(provider.notifier).upsert(_at('a', 1));

      expect(ids(), ['c', 'b']);
    });

    test('a removal is applied when everything is loaded', () async {
      await load([_at('c', 20), _at('a', 10)], total: 2);

      container.read(provider.notifier).remove('c');

      expect(ids(), ['a']);
      expect(repo.requests.keys, [0]);
    });

    test('a removal reloads when more pages remain', () async {
      await load([_at('c', 20), _at('a', 10)], total: 100);
      final first = repo.requests[0];

      container.read(provider.notifier).remove('c');
      await pumpEventQueue();

      expect(repo.requests[0], isNot(same(first)));
    });
  });

  group('appointment changes', controllerTests);

  test('an unknown status does not break parsing', () {
    expect(AppointmentStatus.fromJson('ON_HOLD'), AppointmentStatus.unknown);
    expect(AppointmentStatus.unknown.isActive, isFalse);
  });
}

AppointmentModel _at(String id, int day) => AppointmentModel(
  id: id,
  provider: const ProviderSummary(
    id: 'p',
    firstName: 'Ada',
    lastName: 'Obi',
    specialty: 'GP',
  ),
  startTime: DateTime.utc(2026, 11, day, 9),
  endTime: DateTime.utc(2026, 11, day, 10),
  status: AppointmentStatus.confirmed,
);

/// Cancels when the test says so.
class _SlowCancel extends _FakeRepository {
  final cancelled = Completer<AppointmentModel>();

  @override
  FutureResultOf<AppointmentModel> cancelAppointment(String id) =>
      guard(() => cancelled.future);
}

void controllerTests() {
  test('a change that ends after its screen closed still returns', () async {
    final repo = _SlowCancel();
    final container = ProviderContainer(
      overrides: [appointmentRepoProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);

    final screen = container.listen(appointmentControllerProvider, (_, _) {});
    final change = container
        .read(appointmentControllerProvider.notifier)
        .cancelAppointment('a');
    await pumpEventQueue();

    // The screen closes; the controller is disposed mid-request.
    screen.close();
    await pumpEventQueue();
    expect(container.read(appointmentControllerProvider.exists), isFalse);

    repo.cancelled.complete(_appointment('a'));
    expect(await change, isA<Success<String, ClientException>>());
  });

  test('a second change while one runs is refused', () async {
    final repo = _SlowCancel();
    final container = ProviderContainer(
      overrides: [appointmentRepoProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
    container.listen(appointmentControllerProvider, (_, _) {});
    final notifier = container.read(appointmentControllerProvider.notifier);

    final first = notifier.cancelAppointment('a');
    final second = await notifier.cancelAppointment('a');

    expect(second, isA<Failure<String, ClientException>>());
    repo.cancelled.complete(_appointment('a'));
    expect(await first, isA<Success<String, ClientException>>());
  });
}
