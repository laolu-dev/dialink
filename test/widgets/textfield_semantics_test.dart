import 'package:dialink/src/config/config.dart';
import 'package:dialink/src/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget field) => tester.pumpWidget(
    MaterialApp(
      theme: buildTheme(AppThemeId.clinical, Brightness.light),
      home: Scaffold(body: field),
    ),
  );

  testWidgets('a screen reader hears the label on the field', (tester) async {
    final semantics = tester.ensureSemantics();
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await pump(
      tester,
      CustomTextfield(
        label: "Email",
        hint: "you@example.com",
        controller: controller,
      ),
    );

    final field = tester.getSemantics(find.byType(EditableText));
    expect(field.label, contains("Email"));
    expect(field.flagsCollection.isTextField, isTrue);
    // Said once, on the field, not again as loose text above it.
    expect(find.bySemanticsLabel(RegExp("Email")), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('and on a password field', (tester) async {
    final semantics = tester.ensureSemantics();
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await pump(
      tester,
      CustomPasswordTextfield(label: "Password", controller: controller),
    );

    expect(find.bySemanticsLabel(RegExp("Password")), findsOneWidget);
    expect(
      tester.getSemantics(find.byType(EditableText)).label,
      contains("Password"),
    );
    semantics.dispose();
  });
}
