import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dialink/src/app/theme/app_themes.dart';
import 'package:dialink/src/app/theme/theme_builder.dart';
import 'package:dialink/src/core/storage/preferences.dart';
import 'package:dialink/src/shared/views/splash_screen.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget splash, {String? theme}) async {
    SharedPreferences.setMockInitialValues({'dialink.theme': ?theme});
    final preferences = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [preferencesProvider.overrideWithValue(preferences)],
        child: MaterialApp(
          theme: buildTheme(AppThemeId.clinical, Brightness.light),
          home: splash,
        ),
      ),
    );
  }

  testWidgets('shows the theme icon, then says it is signing in', (
    tester,
  ) async {
    await pump(tester, const SplashScreen(), theme: 'sunset');

    final icon = tester.widget<Image>(find.byType(Image));
    expect((icon.image as AssetImage).assetName, AppThemeId.sunset.iconAsset);
    expect(find.text("Dialink"), findsOneWidget);

    // Hidden at first, shown once the wait is noticeable.
    final status = find.ancestor(
      of: find.text("Signing you in…"),
      matching: find.byType(AnimatedOpacity),
    );
    expect(tester.widget<AnimatedOpacity>(status).opacity, 0);
    await tester.pump(const Duration(seconds: 2));
    expect(tester.widget<AnimatedOpacity>(status).opacity, 1);
  });

  testWidgets('offers a retry when the session could not be restored', (
    tester,
  ) async {
    var retried = false;
    await pump(
      tester,
      SplashScreen(error: "No connection", onRetry: () => retried = true),
    );

    expect(find.text("No connection"), findsOneWidget);
    await tester.tap(find.text("Try again"));
    expect(retried, isTrue);
  });
}
