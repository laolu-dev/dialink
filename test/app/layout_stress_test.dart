import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dialink/src/app/theme/app_themes.dart';
import 'package:dialink/src/app/theme/theme_builder.dart';
import 'package:dialink/src/core/network/page_response.dart';
import 'package:dialink/src/core/network/result.dart';
import 'package:dialink/src/core/storage/preferences.dart';
import 'package:dialink/src/core/utils/time.dart';
import 'package:dialink/src/data/appointments/appointment_repository.dart';
import 'package:dialink/src/data/appointments/models/appointment_model.dart';
import 'package:dialink/src/data/appointments/models/appointment_status.dart';
import 'package:dialink/src/data/doctors/doctor_repository.dart';
import 'package:dialink/src/data/doctors/models/provider_model.dart';
import 'package:dialink/src/data/users/models/patient_profile_model.dart';
import 'package:dialink/src/data/users/models/user_model.dart';
import 'package:dialink/src/data/users/user_repository.dart';
import 'package:dialink/src/features/account/views/change_password_screen.dart';
import 'package:dialink/src/features/account/views/patient_profile_screen.dart';
import 'package:dialink/src/features/appearance/views/appearance_screen.dart';
import 'package:dialink/src/features/authentication/views/forgot_password_screen.dart';
import 'package:dialink/src/features/authentication/views/sign_in_screen.dart';
import 'package:dialink/src/features/authentication/views/sign_up_screen.dart';
import 'package:dialink/src/features/authentication/views/verify_email_screen.dart';
import 'package:dialink/src/features/booking/views/doctor_times_screen.dart';
import 'package:dialink/src/features/onboarding/views/onboarding_screen.dart';
import 'package:dialink/src/shared/controllers/session_controller.dart';
import 'package:dialink/src/app/router/app_router.dart';
import 'package:dialink/src/app/router/routes.dart';
import 'package:dialink/src/app/shell/home_shell.dart';


const _user = UserModel(
  id: 'u1',
  email: 'adaeze.obi-nwankwo@example.test',
  firstName: 'Adaeze',
  lastName: 'Obi-Nwankwo',
  role: 'PATIENT',
  emailVerified: false,
);

const _provider = ProviderModel(
  id: 'p1',
  firstName: 'Oluwaseun',
  lastName: 'Adebayo-Williams',
  specialty: 'Obstetrics and Gynaecology',
  timeZone: 'Africa/Lagos',
  yearsExperience: 12,
);

final _now = DateTime.now().toUtc();

AppointmentModel _appointment(int i) => AppointmentModel(
  id: 'a$i',
  provider: const ProviderSummary(
    id: 'p1',
    firstName: 'Oluwaseun',
    lastName: 'Adebayo-Williams',
    specialty: 'Obstetrics and Gynaecology',
  ),
  startTime: _now.add(Duration(days: i + 1)),
  endTime: _now.add(Duration(days: i + 1, minutes: 30)),
  status: i.isEven ? AppointmentStatus.confirmed : AppointmentStatus.requested,
  reason: 'Follow-up on test results and a longer note about symptoms',
);

class _Session extends Session {
  @override
  Future<UserModel?> build() async => _user;
}

class _Appointments extends AppointmentRepository {
  _Appointments() : super(Dio());

  @override
  FutureResultOf<PageResponse<AppointmentModel>> getAppointments(
    String userId, {
    int page = 0,
    int size = 20,
  }) async => Success(
    PageResponse(
      items: List.generate(6, _appointment),
      page: 0,
      size: 20,
      totalElements: 6,
    ),
  );
}

class _Doctors extends DoctorRepository {
  _Doctors() : super(Dio());

  @override
  FutureResultOf<List<String>> getSpecialties() async => const Success([
    'General practice',
    'Obstetrics and Gynaecology',
    'Dermatology',
  ]);

  @override
  FutureResultOf<PageResponse<ProviderModel>> searchProviders({
    String? name,
    String? specialty,
    int page = 0,
    int size = 20,
    CancelToken? cancelToken,
  }) async => Success(
    PageResponse(
      items: List.filled(5, _provider),
      page: 0,
      size: 50,
      totalElements: 5,
    ),
  );

  @override
  FutureResultOf<ProviderModel> getProvider(String id) async =>
      const Success(_provider);

  @override
  FutureResultOf<PageResponse<SlotModel>> getAvailability(
    String providerId, {
    required DateTime from,
    required DateTime to,
    int page = 0,
    int size = 100,
  }) async {
    final start = DateTime.utc(from.year, from.month, from.day, 8);
    return Success(
      PageResponse(
        items: [
          for (var d = 0; d < 7; d++)
            for (var s = 0; s < 20; s++)
              SlotModel(
                startTime: start.add(Duration(days: d, minutes: 30 * s)),
                endTime: start.add(Duration(days: d, minutes: 30 * s + 30)),
              ),
        ],
        page: 0,
        size: 200,
        totalElements: 140,
      ),
    );
  }
}

class _Users extends UserRepository {
  _Users() : super(Dio());

  @override
  FutureResultOf<PatientProfileModel?> getPatientProfile(String userId) async =>
      const Success(null);
}

/// A device: its size, text scale and an open keyboard's height.
typedef _Device = ({String name, Size size, double text, double keyboard});

const _devices = <_Device>[
  (name: 'small phone, 200% text', size: Size(320, 568), text: 2, keyboard: 0),
  (
    name: 'small phone, keyboard',
    size: Size(320, 568),
    text: 1.3,
    keyboard: 260,
  ),
  (name: 'Duo outer, 150% text', size: Size(466, 678), text: 1.5, keyboard: 0),
  (name: 'landscape phone', size: Size(740, 360), text: 1, keyboard: 0),
  (name: 'tablet', size: Size(1024, 768), text: 1, keyboard: 0),
];

/// The tabs open through the router, as in the app.
const _tabs = {
  'home tab': Routes.home,
  'find tab': Routes.find,
  'visits tab': Routes.visits,
  'account tab': Routes.account,
};

final _screens = <String, Widget Function()?>{
  for (final tab in _tabs.keys) tab: null,
  'onboarding': () => const OnboardingScreen(),
  'landing': () => const SignInScreen(),
  'signup': () => const SignUpScreen(),
  'forgot password': () => const ForgotPasswordScreen(email: 'a@b.test'),
  'verify email': () => const VerifyEmailScreen(),
  'change password': () => const ChangePasswordScreen(),
  'appearance': () => const AppearanceScreen(),
  'patient profile': () => const PatientProfileScreen(),
  'slots': () =>
      const DoctorTimesScreen(args: DoctorTimesArgs(provider: _provider)),
};

void main() {
  setUpAll(AppTime.init);

  for (final device in _devices) {
    for (final MapEntry(key: name, value: screen) in _screens.entries) {
      testWidgets('$name fits: ${device.name}', (tester) async {
        await tester.binding.setSurfaceSize(device.size);
        addTearDown(() => tester.binding.setSurfaceSize(null));
        tester.view.physicalSize = device.size * 3;
        tester.view.devicePixelRatio = 3;
        tester.view.viewInsets = FakeViewPadding(bottom: device.keyboard * 3);
        addTearDown(tester.view.reset);

        SharedPreferences.setMockInitialValues({
          'dialink.onboardingSeen': name != 'onboarding',
        });
        final preferences = await SharedPreferences.getInstance();

        await tester.pumpWidget(
          ProviderScope(
            retry: (_, _) => null,
            overrides: [
              preferencesProvider.overrideWithValue(preferences),
              sessionProvider.overrideWith(_Session.new),
              appointmentRepoProvider.overrideWithValue(_Appointments()),
              doctorRepoProvider.overrideWithValue(_Doctors()),
              userRepoProvider.overrideWithValue(_Users()),
            ],
            child: Consumer(
              builder: (context, ref, _) {
                final theme = buildTheme(AppThemeId.clinical, Brightness.light);
                Widget scaled(BuildContext context, Widget? child) =>
                    MediaQuery(
                      data: MediaQuery.of(
                        context,
                      ).copyWith(textScaler: TextScaler.linear(device.text)),
                      child: child!,
                    );
                if (screen == null) {
                  return MaterialApp.router(
                    theme: theme,
                    builder: scaled,
                    routerConfig: ref.watch(appRouterProvider),
                  );
                }
                return MaterialApp(theme: theme, builder: scaled, home: screen());
              },
            ),
          ),
        );
        if (_tabs[name] case final location?) {
          await tester.pump();
          ProviderScope.containerOf(
            tester.element(find.byType(MaterialApp)),
          ).read(appRouterProvider).go(location);
        }
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(seconds: 1));
        if (_tabs.containsKey(name)) {
          expect(find.byType(HomeShell), findsOneWidget);
        }
      });
    }
  }
}
