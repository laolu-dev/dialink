import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:dialink/src/app/theme/app_palette.dart';
import 'package:dialink/src/app/theme/app_themes.dart';

/// Builds the Material theme for [id] from its palette.
///
/// Pass [palette] to override the theme's own, e.g. glass made solid.
ThemeData buildTheme(
  AppThemeId id,
  Brightness brightness, {
  AppPalette? palette,
}) {
  final p = palette ?? id.palette(brightness);
  final family = id.fontFamily;
  final isDark = brightness == Brightness.dark;

  // Plus Jakarta Sans ships as one variable font: the weight must also be
  // set on its `wght` axis. Atkinson Hyperlegible ignores the variation.
  TextStyle style(double size, FontWeight weight, {Color? color}) => TextStyle(
    fontFamily: family,
    fontSize: size,
    fontWeight: weight,
    fontVariations: [FontVariation.weight(weight.value.toDouble())],
    color: color ?? p.text,
    height: 1.3,
    letterSpacing: 0,
  );

  final textTheme = TextTheme(
    displaySmall: style(32, FontWeight.w700),
    headlineMedium: style(28, FontWeight.w700),
    headlineSmall: style(24, FontWeight.w700),
    titleLarge: style(20, FontWeight.w700),
    titleMedium: style(16, FontWeight.w700),
    titleSmall: style(14, FontWeight.w700),
    bodyLarge: style(16, FontWeight.w400),
    bodyMedium: style(14, FontWeight.w400),
    bodySmall: style(12, FontWeight.w400, color: p.muted),
    labelLarge: style(14, FontWeight.w700),
    labelMedium: style(12, FontWeight.w700),
    labelSmall: style(11, FontWeight.w700),
  );

  final scheme = ColorScheme(
    brightness: brightness,
    primary: p.primary,
    onPrimary: p.onPrimary,
    primaryContainer: p.tint,
    onPrimaryContainer: p.text,
    secondary: p.primary,
    onSecondary: p.onPrimary,
    secondaryContainer: p.tint,
    onSecondaryContainer: p.text,
    error: p.dangerFg,
    onError: isDark ? Colors.black : Colors.white,
    surface: p.surfaceSolid,
    onSurface: p.text,
    onSurfaceVariant: p.muted,
    surfaceContainerHighest: p.tint,
    outline: p.border,
    outlineVariant: p.border,
  );

  final side = BorderSide(color: p.border, width: p.borderWidth);
  const stadium = StadiumBorder();
  const buttonSize = Size(64, 52);
  final buttonText = style(16, FontWeight.w700);

  OutlineInputBorder field(Color color, double width) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide(color: color, width: width),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    fontFamily: family,
    textTheme: textTheme,
    scaffoldBackgroundColor: p.background,
    canvasColor: p.background,
    dividerColor: p.border,
    extensions: [p],
    pageTransitionsTheme: id.reduceMotion
        ? const PageTransitionsTheme(
            builders: {
              TargetPlatform.android: _NoTransitionsBuilder(),
              TargetPlatform.iOS: _NoTransitionsBuilder(),
            },
          )
        : const PageTransitionsTheme(),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: p.text,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: textTheme.titleMedium,
      // The bar is see-through, so it can't judge the contrast itself.
      systemOverlayStyle: isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
    ),
    iconTheme: IconThemeData(color: p.text),
    dividerTheme: DividerThemeData(color: p.border, thickness: p.borderWidth),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: p.primary),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: p.surface,
      hintStyle: textTheme.bodyLarge!.copyWith(color: p.muted),
      prefixIconColor: p.muted,
      suffixIconColor: p.muted,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: field(p.border, p.borderWidth),
      focusedBorder: field(p.primary, 2),
      errorBorder: field(p.dangerFg, p.borderWidth),
      focusedErrorBorder: field(p.dangerFg, 2),
      errorStyle: textTheme.bodySmall!.copyWith(color: p.dangerFg),
      errorMaxLines: 3,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: p.primary,
        foregroundColor: p.onPrimary,
        disabledBackgroundColor: p.primary.withValues(alpha: .4),
        disabledForegroundColor: p.onPrimary,
        minimumSize: buttonSize,
        shape: stadium,
        textStyle: buttonText,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: p.surface,
        foregroundColor: p.text,
        side: side,
        minimumSize: buttonSize,
        shape: stadium,
        textStyle: buttonText,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: p.primary,
        minimumSize: const Size(48, 44),
        textStyle: textTheme.labelLarge,
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        backgroundColor: p.surface,
        foregroundColor: p.text,
        selectedBackgroundColor: p.primary,
        selectedForegroundColor: p.onPrimary,
        side: side,
        textStyle: textTheme.labelLarge,
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: p.surfaceSolid,
      titleTextStyle: textTheme.titleLarge,
      contentTextStyle: textTheme.bodyLarge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: p.borderWidth > 1 ? side : BorderSide.none,
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(backgroundColor: p.surfaceSolid),
    datePickerTheme: DatePickerThemeData(backgroundColor: p.surfaceSolid),
    menuTheme: MenuThemeData(
      style: MenuStyle(backgroundColor: WidgetStatePropertyAll(p.surfaceSolid)),
    ),
  );
}

class _NoTransitionsBuilder extends PageTransitionsBuilder {
  const _NoTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => child;
}
