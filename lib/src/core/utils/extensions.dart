import 'package:flutter/material.dart';

extension BuildContextExtension on BuildContext {
  Size get deviceSize => MediaQuery.sizeOf(this);

  TextTheme get textTheme => Theme.of(this).textTheme;
}

extension SizedBoxExtension on double {
  SizedBox get verticalSpacing => SizedBox(height: this);

  SizedBox get horizontalSpacing => SizedBox(width: this);
}

extension TextStyleWeight on TextStyle {
  /// Sets the weight on the variable font's axis too; see `buildTheme`.
  TextStyle weight(FontWeight weight) => copyWith(
    fontWeight: weight,
    fontVariations: [FontVariation.weight(weight.value.toDouble())],
  );
}
