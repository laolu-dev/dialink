import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dialink/src/app/theme/app_themes.dart';
import 'package:dialink/src/app/theme/theme_builder.dart';
import 'package:dialink/src/core/storage/preferences.dart';
import 'package:dialink/src/features/onboarding/controllers/onboarding_controller.dart';
import 'package:dialink/src/features/onboarding/views/onboarding_screen.dart';
import 'package:dialink/src/features/onboarding/widgets/onboarding_illustrations.dart';

void main() {
  for (final theme in AppThemeId.values) {
    for (final brightness in Brightness.values) {
      test(
        '${theme.name} ${brightness.name} illustrations are valid SVG',
        () async {
          for (final svg in OnboardingIllustrations.all(
            theme.palette(brightness),
          )) {
            final loader = SvgStringLoader(svg);
            await expectLater(loader.loadBytes(null), completes);
          }
        },
      );
    }
  }

  testWidgets('steps through the pages and remembers it was seen', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [preferencesProvider.overrideWithValue(preferences)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: buildTheme(AppThemeId.clinical, Brightness.light),
          home: const OnboardingScreen(),
        ),
      ),
    );

    expect(find.text("Find the right doctor"), findsOneWidget);
    await tester.tap(find.text("Next"));
    await tester.pumpAndSettle();
    expect(find.text("Book in a few taps"), findsOneWidget);
    await tester.tap(find.text("Next"));
    await tester.pumpAndSettle();
    expect(find.text("Stay on top of your visits"), findsOneWidget);

    expect(container.read(onboardingSeenProvider), isFalse);
    await tester.tap(find.text("Get started"));
    expect(container.read(onboardingSeenProvider), isTrue);
    expect(preferences.getBool('dialink.onboardingSeen'), isTrue);
  });
}
