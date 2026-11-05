import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dialink/src/app/router/app_router.dart';
import 'package:dialink/src/app/router/routes.dart';
import 'package:dialink/src/app/theme/app_themes.dart';
import 'package:dialink/src/app/theme/theme_builder.dart';
import 'package:dialink/src/core/network/page_response.dart';
import 'package:dialink/src/core/network/result.dart';
import 'package:dialink/src/core/storage/preferences.dart';
import 'package:dialink/src/data/appointments/appointment_repository.dart';
import 'package:dialink/src/data/appointments/models/appointment_model.dart';
import 'package:dialink/src/data/users/models/user_model.dart';
import 'package:dialink/src/shared/controllers/session_controller.dart';

const _user = UserModel(
  id: 'u1',
  email: 'a@b.test',
  firstName: 'Ada',
  lastName: 'Obi',
  role: 'PATIENT',
  emailVerified: true,
);

/// A session the test restores, signs in and signs out by hand.
class _Session extends Session {
  _Session(this._restore);
  final Future<UserModel?> _restore;

  @override
  Future<UserModel?> build() => _restore;

  void signIn() => state = const AsyncData(_user);

  @override
  Future<void> logout() async => state = const AsyncData(null);
}

/// No visits, so Home has nothing to load from the network.
class _NoAppointments extends AppointmentRepository {
  _NoAppointments() : super(Dio());

  @override
  FutureResultOf<PageResponse<AppointmentModel>> getAppointments(
    String userId, {
    int page = 0,
    int size = 20,
  }) async => const Success(
    PageResponse(items: [], page: 0, size: 20, totalElements: 0),
  );
}

void main() {
  late GoRouter router;
  late ProviderContainer container;

  Future<void> pump(
    WidgetTester tester, {
    required Future<UserModel?> restore,
    bool onboardingSeen = true,
  }) async {
    SharedPreferences.setMockInitialValues({
      'dialink.onboardingSeen': onboardingSeen,
    });
    final preferences = await SharedPreferences.getInstance();
    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        preferencesProvider.overrideWithValue(preferences),
        sessionProvider.overrideWith(() => _Session(restore)),
        appointmentRepoProvider.overrideWithValue(_NoAppointments()),
      ],
    );
    addTearDown(container.dispose);
    router = container.read(appRouterProvider);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          theme: buildTheme(AppThemeId.clinical, Brightness.light),
          routerConfig: router,
        ),
      ),
    );
    await tester.pump();
  }

  String location() => router.routerDelegate.currentConfiguration.uri.path;

  testWidgets('shows the splash while the session restores', (tester) async {
    final restore = Completer<UserModel?>();
    await pump(tester, restore: restore.future);
    expect(location(), Routes.splash);

    restore.complete(_user);
    await tester.pump(const Duration(milliseconds: 500));
    expect(location(), Routes.home);
  });

  testWidgets('a first launch shows onboarding before sign-in', (tester) async {
    await pump(tester, restore: Future.value(null), onboardingSeen: false);
    await tester.pump();
    expect(location(), Routes.welcome);
  });

  testWidgets('signed out goes to sign-in, and stays on public screens', (
    tester,
  ) async {
    await pump(tester, restore: Future.value(null));
    await tester.pump();
    expect(location(), Routes.signIn);

    router.go(Routes.signUp);
    await tester.pump();
    expect(location(), Routes.signUp);

    router.go(Routes.visits);
    await tester.pump();
    expect(location(), Routes.signIn);
  });

  testWidgets('signing in opens home; signing out returns to sign-in', (
    tester,
  ) async {
    await pump(tester, restore: Future.value(null));
    await tester.pump();

    (container.read(sessionProvider.notifier) as _Session).signIn();
    await tester.pump(const Duration(milliseconds: 500));
    expect(location(), Routes.home);

    router.go(Routes.signIn);
    await tester.pump(const Duration(milliseconds: 500));
    expect(location(), Routes.home, reason: 'signed in, sign-in sends home');

    await container.read(sessionProvider.notifier).logout();
    await tester.pump(const Duration(milliseconds: 500));
    expect(location(), Routes.signIn);
  });
}
