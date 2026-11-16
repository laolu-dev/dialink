import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dialink/src/app/theme/app_themes.dart';
import 'package:dialink/src/app/theme/theme_builder.dart';
import 'package:dialink/src/core/network/result.dart';
import 'package:dialink/src/data/users/models/patient_profile_model.dart';
import 'package:dialink/src/data/users/models/user_model.dart';
import 'package:dialink/src/data/users/user_repository.dart';
import 'package:dialink/src/features/account/views/patient_profile_screen.dart';
import 'package:dialink/src/shared/controllers/session_controller.dart';

class _Session extends Session {
  @override
  Future<UserModel?> build() async => const UserModel(
    id: 'u1',
    email: 'a@b.test',
    firstName: 'Ada',
    lastName: 'Obi',
    role: 'PATIENT',
    emailVerified: true,
  );
}

class _Users extends UserRepository {
  _Users() : super(Dio());

  @override
  FutureResultOf<PatientProfileModel?> getPatientProfile(String userId) async =>
      const Success(
        PatientProfileModel(dateOfBirth: '1996-04-12', gender: 'Female'),
      );
}

Future<void> _pump(WidgetTester tester, {double textScale = 1}) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [
        sessionProvider.overrideWith(_Session.new),
        userRepoProvider.overrideWithValue(_Users()),
      ],
      child: MaterialApp(
        theme: buildTheme(AppThemeId.clinical, Brightness.light),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: const PatientProfileScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('date of birth reads as a date and is announced with its label', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _pump(tester);

    expect(find.text('12 April 1996'), findsOneWidget);
    expect(
      tester.getSemantics(find.text('12 April 1996')),
      matchesSemantics(
        label: 'Date of birth\n12 April 1996',
        isButton: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    semantics.dispose();
  });

  testWidgets('gender is announced with its label', (tester) async {
    final semantics = tester.ensureSemantics();
    await _pump(tester);

    final node = tester.getSemantics(find.text('Gender'));
    expect(node.label, contains('Gender'));
    semantics.dispose();
  });

  testWidgets('gender and date of birth stack at large text', (tester) async {
    await _pump(tester, textScale: 2);
    final gender = tester.getTopLeft(find.text('Gender'));
    final dob = tester.getTopLeft(find.text('Date of birth'));
    expect(dob.dy, greaterThan(gender.dy), reason: 'date of birth is below');
    expect(dob.dx, gender.dx, reason: 'same left edge');
  });

  testWidgets('the emergency contact phone and relationship stack too', (
    tester,
  ) async {
    await _pump(tester, textScale: 2);
    final phone = tester.getTopLeft(find.text('Phone'));
    final relationship = tester.getTopLeft(find.text('Relationship'));
    expect(relationship.dy, greaterThan(phone.dy));
    expect(relationship.dx, phone.dx);
  });
}
