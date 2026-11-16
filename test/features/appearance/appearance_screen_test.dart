import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dialink/src/app/theme/app_themes.dart';
import 'package:dialink/src/app/theme/theme_builder.dart';
import 'package:dialink/src/core/storage/preferences.dart';
import 'package:dialink/src/features/appearance/views/appearance_screen.dart';

Future<void> _pump(WidgetTester tester, double textScale) async {
  SharedPreferences.setMockInitialValues({});
  final preferences = await SharedPreferences.getInstance();
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [preferencesProvider.overrideWithValue(preferences)],
      child: MaterialApp(
        theme: buildTheme(AppThemeId.clinical, Brightness.light),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: const AppearanceScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('mode options sit side by side at normal text', (tester) async {
    await _pump(tester, 1);
    final system = tester.getTopLeft(find.text('System'));
    final dark = tester.getTopLeft(find.text('Dark'));
    expect(dark.dy, system.dy);
  });

  testWidgets('mode options stack at large text', (tester) async {
    await _pump(tester, 2);
    final system = tester.getTopLeft(find.text('System'));
    final dark = tester.getTopLeft(find.text('Dark'));
    expect(dark.dy, greaterThan(system.dy));
    // "System" stays on one line.
    final height = tester.getSize(find.text('System')).height;
    final lineHeight = tester.getSize(find.text('Dark')).height;
    expect(height, lineHeight);
  });
}
