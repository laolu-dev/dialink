import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dialink/src/app/theme/app_themes.dart';
import 'package:dialink/src/app/theme/theme_builder.dart';
import 'package:dialink/src/core/network/page_response.dart';
import 'package:dialink/src/core/network/result.dart';
import 'package:dialink/src/data/doctors/doctor_repository.dart';
import 'package:dialink/src/data/doctors/models/provider_model.dart';
import 'package:dialink/src/features/booking/views/find_doctor_screen.dart';

ProviderModel _doctor(String first, String last, String specialty) =>
    ProviderModel(
      id: '$first$last',
      firstName: first,
      lastName: last,
      specialty: specialty,
      timeZone: 'Africa/Lagos',
    );

final _doctors = [
  _doctor('Tolu', 'Ade', 'General practice'),
  _doctor('Kemi', 'Bello', 'Dermatology'),
  _doctor('Chidi', 'Eze', 'Dermatology'),
];

/// Filters like the API: both optional, case-insensitive, match anywhere.
class _Doctors extends DoctorRepository {
  _Doctors() : super(Dio());

  final searches = <({String? name, String? specialty})>[];

  @override
  FutureResultOf<List<String>> getSpecialties() async =>
      const Success(['General practice', 'Dermatology', 'Paediatrics']);

  @override
  FutureResultOf<PageResponse<ProviderModel>> searchProviders({
    String? name,
    String? specialty,
    int page = 0,
    int size = 20,
    CancelToken? cancelToken,
  }) async {
    searches.add((name: name, specialty: specialty));
    bool has(String value, String? part) =>
        part == null ||
        part.isEmpty ||
        value.toLowerCase().contains(part.toLowerCase());
    final items = [
      for (final d in _doctors)
        if (has(d.name, name) && has(d.specialty, specialty)) d,
    ];
    return Success(
      PageResponse(
        items: items,
        page: 0,
        size: size,
        totalElements: items.length,
      ),
    );
  }
}

Future<_Doctors> _pump(WidgetTester tester) async {
  final doctors = _Doctors();
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [doctorRepoProvider.overrideWithValue(doctors)],
      child: MaterialApp(
        theme: buildTheme(AppThemeId.clinical, Brightness.light),
        home: const Scaffold(body: FindDoctorScreen()),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return doctors;
}

void main() {
  testWidgets('a specialty chip filters the list; tapping it again clears', (
    tester,
  ) async {
    await _pump(tester);
    expect(find.text('Dr. Tolu Ade'), findsOneWidget);

    final row = find.byWidgetPredicate(
      (w) => w is SingleChildScrollView && w.scrollDirection == Axis.horizontal,
    );
    final chip = find.descendant(of: row, matching: find.text('Dermatology'));
    // Swipe the row along, as a patient would, to reach the chip.
    await tester.drag(row, const Offset(-200, 0));
    await tester.pumpAndSettle();
    await tester.tap(chip);
    await tester.pumpAndSettle();
    expect(find.text('Dr. Tolu Ade'), findsNothing);
    expect(find.text('Dr. Kemi Bello'), findsOneWidget);

    // The chosen chip moves to the front, so it's still in view.
    await tester.tap(chip);
    await tester.pumpAndSettle();
    expect(find.text('Dr. Tolu Ade'), findsOneWidget);
  });

  testWidgets('typing a specialty as a name offers that specialty', (
    tester,
  ) async {
    await _pump(tester);
    await tester.enterText(find.byType(TextField), 'derma');
    await tester.pump(const Duration(milliseconds: 450));
    await tester.pumpAndSettle();

    expect(find.text('No doctors named "derma"'), findsOneWidget);
    await tester.tap(find.text('Show Dermatology doctors'));
    await tester.pumpAndSettle();

    expect(find.text('Dr. Kemi Bello'), findsOneWidget);
    expect(find.text('Dr. Chidi Eze'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '',
    );
  });

  testWidgets('the filter opens as a bottom sheet and applies its choice', (
    tester,
  ) async {
    await _pump(tester);
    await tester.tap(find.bySemanticsLabel('Filters'));
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsOneWidget);
    await tester.tap(find.widgetWithText(RadioListTile<String>, 'Dermatology'));
    await tester.tap(find.text('Show doctors'));
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsNothing);
    expect(find.text('Dr. Tolu Ade'), findsNothing);
    expect(find.text('Dr. Kemi Bello'), findsOneWidget);
    expect(find.bySemanticsLabel('Filters, 1 on'), findsOneWidget);
  });
}
