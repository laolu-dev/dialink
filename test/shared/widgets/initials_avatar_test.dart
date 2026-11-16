import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dialink/src/app/theme/app_themes.dart';
import 'package:dialink/src/app/theme/theme_builder.dart';
import 'package:dialink/src/shared/widgets/initials_avatar.dart';

Future<void> _pump(WidgetTester tester, double textScale) => tester.pumpWidget(
  MaterialApp(
    theme: buildTheme(AppThemeId.easyRead, Brightness.light),
    home: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
      child: const Center(child: InitialsAvatar(name: 'Dr. Oluwaseun Adebayo')),
    ),
  ),
);

void main() {
  for (final scale in [1.0, 2.0, 3.0]) {
    testWidgets('both initials fit at ${scale}x text', (tester) async {
      await _pump(tester, scale);
      final circle = tester.getSize(find.byType(Container));
      final text = tester.getSize(find.text('OA'));
      expect(text.width, lessThan(circle.width));
      expect(text.height, lessThan(circle.height));
      // Grows with the text, up to one and a half times.
      expect(circle.width, closeTo(44 * scale.clamp(1, 1.5), 0.01));
    });
  }
}
