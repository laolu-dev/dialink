import 'package:flutter/cupertino.dart' show CupertinoPageTransition;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dialink/src/app/theme/app_themes.dart';
import 'package:dialink/src/app/theme/theme_builder.dart';

/// Opens a second page on iOS, with animations on or off.
Future<void> _open(WidgetTester tester, {required bool reduced}) async {
  final theme = buildTheme(
    AppThemeId.clinical,
    Brightness.light,
  ).copyWith(platform: TargetPlatform.iOS);
  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
        child: child!,
      ),
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const Scaffold(body: Text('Second')),
            ),
          ),
          child: const Text('Open'),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('pages slide as usual when motion is on', (tester) async {
    await _open(tester, reduced: false);
    expect(find.byType(CupertinoPageTransition), findsWidgets);
  });

  testWidgets('pages crossfade instead when motion is reduced', (tester) async {
    await _open(tester, reduced: true);
    expect(find.byType(CupertinoPageTransition), findsNothing);
    expect(
      find.ancestor(
        of: find.text('Second'),
        matching: find.byType(FadeTransition),
      ),
      findsWidgets,
    );
  });

  testWidgets('a left-edge swipe still goes back with motion reduced', (
    tester,
  ) async {
    await _open(tester, reduced: true);
    await tester.dragFrom(const Offset(5, 300), const Offset(200, 0));
    await tester.pumpAndSettle();
    expect(find.text('Second'), findsNothing);
    expect(find.text('Open'), findsOneWidget);
  });

  testWidgets('a swipe from mid-screen does not go back', (tester) async {
    await _open(tester, reduced: true);
    await tester.dragFrom(const Offset(200, 300), const Offset(150, 0));
    await tester.pumpAndSettle();
    expect(find.text('Second'), findsOneWidget);
  });
}
