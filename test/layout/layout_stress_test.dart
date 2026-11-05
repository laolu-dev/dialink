import 'package:dialink/src/config/config.dart';
import 'package:dialink/src/core/core.dart';
import 'package:dialink/src/features/authentication/data/auth_repository.dart';
import 'package:dialink/src/features/authentication/models/patient_profile_model.dart';
import 'package:dialink/src/features/authentication/models/user_model.dart';
import 'package:dialink/src/features/authentication/presentation/controller/session_controller.dart';
import 'package:dialink/src/features/authentication/presentation/views/appearance_screen.dart';
import 'package:dialink/src/features/authentication/presentation/views/change_password_screen.dart';
import 'package:dialink/src/features/authentication/presentation/views/forgot_password_screen.dart';
import 'package:dialink/src/features/authentication/presentation/views/patient_profile_screen.dart';
import 'package:dialink/src/features/authentication/presentation/views/signup_screen.dart';
import 'package:dialink/src/features/authentication/presentation/views/verify_email_screen.dart';
import 'package:dialink/src/features/book-appointment/data/appointment_repository.dart';
import 'package:dialink/src/features/book-appointment/models/appointment_model.dart';
import 'package:dialink/src/features/book-appointment/models/provider_model.dart';
import 'package:dialink/src/features/book-appointment/presentation/views/provider_slots_screen.dart';
import 'package:dialink/src/features/landing/landing_screen.dart';
import 'package:dialink/src/features/onboarding/onboarding_screen.dart';
import 'package:dialink/src/features/shell/home_shell.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class _Tab extends SelectedTab {
  _Tab(this.tab);
  final ShellTab tab;

  @override
  ShellTab build() => tab;
}

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

class _Auth extends AuthenticationRepository {
  _Auth() : super(Dio(), TokenStore());

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

final _screens = <String, Widget Function()>{
  'onboarding': () => const OnboardingScreen(),
  'landing': () => const LandingScreen(),
  'signup': () => const SignupScreen(),
  'forgot password': () => const ForgotPasswordScreen(email: 'a@b.test'),
  'verify email': () => const VerifyEmailScreen(),
  'change password': () => const ChangePasswordScreen(),
  'appearance': () => const AppearanceScreen(),
  'patient profile': () => const PatientProfileScreen(),
  'home tab': () => const HomeShell(),
  'find tab': () => const HomeShell(),
  'visits tab': () => const HomeShell(),
  'account tab': () => const HomeShell(),
  'slots': () =>
      const ProviderSlotsScreen(args: ProviderSlotsArgs(provider: _provider)),
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
              authRepoProvider.overrideWithValue(_Auth()),
              if (name.endsWith(' tab'))
                selectedTabProvider.overrideWith(
                  () => _Tab(ShellTab.values.byName(name.split(' ').first)),
                ),
            ],
            child: MaterialApp(
              theme: buildTheme(AppThemeId.clinical, Brightness.light),
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(device.text)),
                child: child!,
              ),
              home: screen(),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(seconds: 1));
      });
    }
  }
}
