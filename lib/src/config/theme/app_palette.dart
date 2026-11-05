import 'package:flutter/material.dart';

/// The design tokens of one theme in one brightness.
///
/// Widgets read it with `context.palette`. Status colours come in pairs, a
/// tint for the background and a darker shade for the text and icon on it.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.background,
    required this.surface,
    required this.surfaceSolid,
    required this.text,
    required this.muted,
    required this.primary,
    required this.onPrimary,
    required this.tint,
    required this.border,
    this.successBg = const Color(0xFFE3F4E8),
    this.successFg = const Color(0xFF1B6B3A),
    this.warningBg = const Color(0xFFFFF2D9),
    this.warningFg = const Color(0xFF7A4B00),
    this.dangerBg = const Color(0xFFFDE6E4),
    this.dangerFg = const Color(0xFFA1281D),
    this.neutralBg = const Color(0xFFECEFF0),
    this.neutralFg = const Color(0xFF3D4A4E),
    this.accent = const Color(0xFFF08A6B),
    this.glows = const [],
    this.borderWidth = 1,
    this.outlinedStatus = false,
  });

  /// Dark-mode status colours, shared by the standard themes.
  const AppPalette.dark({
    required this.background,
    required this.surface,
    required this.surfaceSolid,
    required this.text,
    required this.muted,
    required this.primary,
    required this.onPrimary,
    required this.tint,
    required this.border,
    this.successBg = const Color(0xFF173A25),
    this.successFg = const Color(0xFF9FE0B4),
    this.warningBg = const Color(0xFF3D2E10),
    this.warningFg = const Color(0xFFFFD58A),
    this.dangerBg = const Color(0xFF46201C),
    this.dangerFg = const Color(0xFFFFB3AA),
    this.neutralBg = const Color(0xFF263033),
    this.neutralFg = const Color(0xFFC9D3D6),
    this.accent = const Color(0xFFF08A6B),
    this.glows = const [],
    this.borderWidth = 1,
    this.outlinedStatus = false,
  });

  final Color background;

  /// Cards, fields and bars. Translucent in the glass theme.
  final Color surface;

  /// Dialogs and sheets, which are never see-through.
  final Color surfaceSolid;
  final Color text;
  final Color muted;
  final Color primary;
  final Color onPrimary;

  /// A light wash of the primary colour, for selection and avatars.
  final Color tint;
  final Color border;

  final Color successBg;
  final Color successFg;
  final Color warningBg;
  final Color warningFg;
  final Color dangerBg;
  final Color dangerFg;
  final Color neutralBg;
  final Color neutralFg;

  /// A second colour for illustrations and the icon's dot.
  final Color accent;

  /// Soft colour fields behind the glass; empty for the solid themes.
  final List<Color> glows;
  final double borderWidth;

  /// Status chips get an outline, for themes that don't rely on tints.
  final bool outlinedStatus;

  bool get isGlass => glows.isNotEmpty;

  /// The same palette without glass, for when the system asks for less
  /// transparency.
  AppPalette get solid =>
      isGlass ? copyWith(surface: surfaceSolid, glows: const []) : this;

  @override
  AppPalette copyWith({
    Color? background,
    Color? surface,
    Color? surfaceSolid,
    Color? text,
    Color? muted,
    Color? primary,
    Color? onPrimary,
    Color? tint,
    Color? border,
    List<Color>? glows,
  }) => AppPalette(
    background: background ?? this.background,
    surface: surface ?? this.surface,
    surfaceSolid: surfaceSolid ?? this.surfaceSolid,
    text: text ?? this.text,
    muted: muted ?? this.muted,
    primary: primary ?? this.primary,
    onPrimary: onPrimary ?? this.onPrimary,
    tint: tint ?? this.tint,
    border: border ?? this.border,
    successBg: successBg,
    successFg: successFg,
    warningBg: warningBg,
    warningFg: warningFg,
    dangerBg: dangerBg,
    dangerFg: dangerFg,
    neutralBg: neutralBg,
    neutralFg: neutralFg,
    accent: accent,
    glows: glows ?? this.glows,
    borderWidth: borderWidth,
    outlinedStatus: outlinedStatus,
  );

  /// Themes switch instantly; there is nothing to animate between.
  @override
  AppPalette lerp(AppPalette? other, double t) =>
      t < .5 || other == null ? this : other;
}
