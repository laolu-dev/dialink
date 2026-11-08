import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:dialink/src/app/router/routes.dart';
import 'package:dialink/src/app/theme/app_themes.dart';
import 'package:dialink/src/app/theme/theme_builder.dart';
import 'package:dialink/src/core/network/api_exception.dart';
import 'package:dialink/src/core/network/page_response.dart';
import 'package:dialink/src/core/network/result.dart';
import 'package:dialink/src/core/utils/time.dart';
import 'package:dialink/src/data/appointments/appointment_repository.dart';
import 'package:dialink/src/data/appointments/models/appointment_model.dart';
import 'package:dialink/src/data/doctors/doctor_repository.dart';
import 'package:dialink/src/data/doctors/models/provider_model.dart';
import 'package:dialink/src/data/users/models/user_model.dart';
import 'package:dialink/src/data/appointments/models/appointment_status.dart';
import 'package:dialink/src/features/booking/views/booked_screen.dart';
import 'package:dialink/src/features/booking/views/doctor_times_screen.dart';
import 'package:dialink/src/shared/controllers/visits_view_controller.dart';
import 'package:dialink/src/shared/controllers/session_controller.dart';

const _user = UserModel(
  id: 'u1',
  email: 'a@b.test',
  firstName: 'Ada',
  lastName: 'Obi',
  role: 'PATIENT',
  emailVerified: true,
);

const _provider = ProviderModel(
  id: 'p1',
  firstName: 'Tolu',
  lastName: 'Ade',
  specialty: 'General practice',
  timeZone: 'Africa/Lagos',
  yearsExperience: 5,
);

class _Session extends Session {
  @override
  Future<UserModel?> build() async => _user;
}

/// Free times every day this week, from 09:00 Lagos time; counts fetches.
class _Doctors extends DoctorRepository {
  _Doctors() : super(Dio());

  int fetches = 0;

  @override
  FutureResultOf<PageResponse<SlotModel>> getAvailability(
    String providerId, {
    required DateTime from,
    required DateTime to,
    int page = 0,
    int size = 100,
  }) async {
    fetches++;
    final start = DateTime.utc(from.year, from.month, from.day, 8);
    return Success(
      PageResponse(
        items: [
          for (var d = 0; d < 7; d++)
            for (var s = 0; s < 4; s++)
              SlotModel(
                startTime: start.add(Duration(days: d, hours: s)),
                endTime: start.add(Duration(days: d, hours: s, minutes: 30)),
              ),
        ],
        page: 0,
        size: 100,
        totalElements: 28,
      ),
    );
  }
}

/// Every booking fails because someone else just took the time.
class _TakenAppointments extends AppointmentRepository {
  _TakenAppointments() : super(Dio());

  int attempts = 0;

  @override
  FutureResultOf<AppointmentModel> createAppointment({
    required String providerId,
    required String startTime,
    required String idempotencyKey,
    String? reason,
  }) async {
    attempts++;
    return const Failure(
      ClientException(
        message: "That time was just booked by someone else.",
        type: 'slot-unavailable',
        status: 409,
      ),
    );
  }
}

/// Every booking goes through.
class _OpenAppointments extends AppointmentRepository {
  _OpenAppointments() : super(Dio());

  @override
  FutureResultOf<AppointmentModel> createAppointment({
    required String providerId,
    required String startTime,
    required String idempotencyKey,
    String? reason,
  }) async {
    final start = DateTime.parse(startTime).toUtc();
    return Success(
      AppointmentModel(
        id: 'a1',
        provider: const ProviderSummary(
          id: 'p1',
          firstName: 'Tolu',
          lastName: 'Ade',
          specialty: 'General practice',
        ),
        startTime: start,
        endTime: start.add(const Duration(minutes: 30)),
        status: AppointmentStatus.requested,
        reason: reason,
      ),
    );
  }
}

void main() {
  setUpAll(AppTime.init);

  testWidgets('a sent booking shows what happens next, then opens upcoming', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        sessionProvider.overrideWith(_Session.new),
        doctorRepoProvider.overrideWithValue(_Doctors()),
        appointmentRepoProvider.overrideWithValue(_OpenAppointments()),
      ],
    );
    addTearDown(container.dispose);
    // The patient last looked at past visits.
    container.read(visitsShowPastProvider.notifier).show(past: true);

    final router = GoRouter(
      initialLocation: '/find',
      routes: [
        GoRoute(path: '/find', builder: (_, _) => const Text('Find')),
        GoRoute(
          path: '/doctors',
          builder: (_, _) => const DoctorTimesScreen(
            args: DoctorTimesArgs(provider: _provider),
          ),
        ),
        GoRoute(
          path: Routes.booked,
          builder: (_, state) => BookedScreen(args: state.extra! as BookedArgs),
        ),
        GoRoute(path: Routes.visits, builder: (_, _) => const Text('Visits')),
        GoRoute(path: Routes.home, builder: (_, _) => const Text('Home')),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          theme: buildTheme(AppThemeId.clinical, Brightness.light),
          routerConfig: router,
        ),
      ),
    );
    router.push('/doctors');
    await tester.pumpAndSettle();

    await tester.tap(find.text('09:00').first);
    await tester.pump();
    await tester.tap(find.textContaining(RegExp(r'^Book \w{3} ')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Recurring headaches');
    await tester.tap(find.text('Confirm booking'));
    await tester.pumpAndSettle();

    expect(find.text('Request sent'), findsOneWidget);
    expect(
      find.text('Waiting for Dr. Tolu Ade to confirm the time.'),
      findsOneWidget,
    );
    expect(find.text('Recurring headaches'), findsOneWidget);
    expect(find.text('What happens next'), findsOneWidget);

    // Back skips the booking screen: that time is taken now.
    router.pop();
    await tester.pumpAndSettle();
    expect(find.text('Find'), findsOneWidget);

    // From the confirmation, "See your visits" opens the upcoming list.
    router.push(
      Routes.booked,
      extra: const BookedArgs(provider: _provider, when: 'Mon 9 Nov, 09:00'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('See your visits'));
    await tester.pumpAndSettle();
    expect(find.text('Visits'), findsOneWidget);
    expect(container.read(visitsShowPastProvider), isFalse);

    // Let cached availability expire before the container goes.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(minutes: 5));
  });

  testWidgets(
    'a taken time closes the review sheet and explains it beside fresh times',
    (tester) async {
      final doctors = _Doctors();
      final appointments = _TakenAppointments();
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          retry: (_, _) => null,
          overrides: [
            sessionProvider.overrideWith(_Session.new),
            doctorRepoProvider.overrideWithValue(doctors),
            appointmentRepoProvider.overrideWithValue(appointments),
          ],
          child: MaterialApp(
            theme: buildTheme(AppThemeId.clinical, Brightness.light),
            home: const DoctorTimesScreen(
              args: DoctorTimesArgs(provider: _provider),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      final fetchesBefore = doctors.fetches;

      // Pick the first time, review, confirm.
      await tester.tap(find.text('09:00').first);
      await tester.pump();
      await tester.tap(find.textContaining(RegExp(r'^Book \w{3} ')));
      await tester.pumpAndSettle();
      expect(find.text('Book this visit?'), findsOneWidget);

      await tester.tap(find.text('Confirm booking'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(appointments.attempts, 1);
      expect(
        find.text('Book this visit?'),
        findsNothing,
        reason: 'sheet closed',
      );
      expect(find.text('Pick another time'), findsOneWidget);
      expect(
        find.text('That time was just booked by someone else.'),
        findsOneWidget,
      );
      expect(find.text('Pick a time'), findsOneWidget, reason: 'cleared');
      expect(doctors.fetches, greaterThan(fetchesBefore), reason: 'refetched');

      // Picking again clears the explanation.
      await tester.tap(find.text('10:00').first);
      await tester.pump();
      expect(find.text('Pick another time'), findsNothing);
    },
  );
}
