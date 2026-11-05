import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app_palette.dart';

const _jakarta = 'Plus Jakarta Sans';
const _atkinson = 'Atkinson Hyperlegible';

/// The themes a patient can pick in Account. Glass is the default on iOS
/// and Clinical everywhere else.
enum AppThemeId {
  glass(
    label: 'Glass',
    description: 'Frosted, translucent surfaces',
    fontFamily: _jakarta,
    iosOnly: true,
    light: AppPalette(
      background: Color(0xFFE3F0F2),
      surface: Color(0x8CFFFFFF),
      surfaceSolid: Color(0xFFF7FBFC),
      text: Color(0xFF0E1E22),
      muted: Color(0xFF4E6166),
      primary: Color(0xFF0B7A83),
      onPrimary: Color(0xFFFFFFFF),
      tint: Color(0x240B7A83),
      border: Color(0xBFFFFFFF),
      glows: [Color(0xFFBFE3E7), Color(0xFFF4DCC8), Color(0xFFD6DEF8)],
    ),
    dark: AppPalette.dark(
      background: Color(0xFF0A1416),
      surface: Color(0x80243034),
      surfaceSolid: Color(0xFF172326),
      text: Color(0xFFEAF4F5),
      muted: Color(0xFFA3B6BA),
      primary: Color(0xFF5CD0D6),
      onPrimary: Color(0xFF00363A),
      tint: Color(0x2E5CD0D6),
      border: Color(0x24FFFFFF),
      glows: [Color(0xFF0F3A3F), Color(0xFF3A2433), Color(0xFF1A2648)],
    ),
  ),
  clinical(
    label: 'Clinical',
    description: 'Clean and calm',
    fontFamily: _jakarta,
    light: AppPalette(
      background: Color(0xFFF4F8F9),
      surface: Color(0xFFFFFFFF),
      surfaceSolid: Color(0xFFFFFFFF),
      text: Color(0xFF0E1E22),
      muted: Color(0xFF5A6B70),
      primary: Color(0xFF0B7A83),
      onPrimary: Color(0xFFFFFFFF),
      tint: Color(0xFFDDF1F2),
      border: Color(0xFFE1E9EB),
    ),
    dark: AppPalette.dark(
      background: Color(0xFF0A1517),
      surface: Color(0xFF122124),
      surfaceSolid: Color(0xFF122124),
      text: Color(0xFFE6F2F3),
      muted: Color(0xFF93A8AC),
      primary: Color(0xFF4FC3C9),
      onPrimary: Color(0xFF00363A),
      tint: Color(0xFF12393C),
      border: Color(0xFF1F3437),
    ),
  ),
  sage(
    label: 'Sage',
    description: 'Soft greens, natural and calm',
    fontFamily: _jakarta,
    light: AppPalette(
      background: Color(0xFFF6F4EE),
      surface: Color(0xFFFFFFFF),
      surfaceSolid: Color(0xFFFFFFFF),
      text: Color(0xFF1F261F),
      muted: Color(0xFF646B5F),
      primary: Color(0xFF3D7A55),
      onPrimary: Color(0xFFFFFFFF),
      tint: Color(0xFFE2EEDF),
      border: Color(0xFFE5E2D8),
      accent: Color(0xFFE9B44C),
    ),
    dark: AppPalette.dark(
      background: Color(0xFF121611),
      surface: Color(0xFF1B211A),
      surfaceSolid: Color(0xFF1B211A),
      text: Color(0xFFE8ECE3),
      muted: Color(0xFF9CA594),
      primary: Color(0xFF8FC9A0),
      onPrimary: Color(0xFF0D2B18),
      tint: Color(0xFF22362A),
      border: Color(0xFF2A3328),
      accent: Color(0xFFE9B44C),
    ),
  ),
  sunset(
    label: 'Sunset',
    description: 'Warm and friendly',
    fontFamily: _jakarta,
    light: AppPalette(
      background: Color(0xFFFFF7F2),
      surface: Color(0xFFFFFFFF),
      surfaceSolid: Color(0xFFFFFFFF),
      text: Color(0xFF2A1A14),
      muted: Color(0xFF77625A),
      primary: Color(0xFFC4532F),
      onPrimary: Color(0xFFFFFFFF),
      tint: Color(0xFFFCE3D8),
      border: Color(0xFFF2E1D8),
      accent: Color(0xFF2F6F8F),
    ),
    dark: AppPalette.dark(
      background: Color(0xFF1A1210),
      surface: Color(0xFF251A16),
      surfaceSolid: Color(0xFF251A16),
      text: Color(0xFFF6E9E3),
      muted: Color(0xFFB39C92),
      primary: Color(0xFFFF9A76),
      onPrimary: Color(0xFF4A1606),
      tint: Color(0xFF45261B),
      border: Color(0xFF3A2A24),
      accent: Color(0xFF7FB8D4),
    ),
  ),
  midnight(
    label: 'Midnight',
    description: 'Bold indigo, high energy',
    fontFamily: _jakarta,
    light: AppPalette(
      background: Color(0xFFF5F5FB),
      surface: Color(0xFFFFFFFF),
      surfaceSolid: Color(0xFFFFFFFF),
      text: Color(0xFF12122A),
      muted: Color(0xFF5C5C78),
      primary: Color(0xFF4B3FE0),
      onPrimary: Color(0xFFFFFFFF),
      tint: Color(0xFFE5E3FC),
      border: Color(0xFFE3E3EF),
      accent: Color(0xFFFF6F61),
    ),
    dark: AppPalette.dark(
      background: Color(0xFF0B0B18),
      surface: Color(0xFF15152A),
      surfaceSolid: Color(0xFF15152A),
      text: Color(0xFFEDEDFA),
      muted: Color(0xFF9C9CC0),
      primary: Color(0xFFA59CFF),
      onPrimary: Color(0xFF1C1270),
      tint: Color(0xFF26236A),
      border: Color(0xFF262645),
      accent: Color(0xFFFF8A7A),
    ),
  ),
  highContrast(
    label: 'High contrast',
    description: 'Strong outlines, for low vision and colour blindness',
    fontFamily: _atkinson,
    textScale: 1.05,
    isAccessibility: true,
    light: AppPalette(
      background: Color(0xFFFFFFFF),
      surface: Color(0xFFFFFFFF),
      surfaceSolid: Color(0xFFFFFFFF),
      text: Color(0xFF000000),
      muted: Color(0xFF1A1A1A),
      primary: Color(0xFF0030B8),
      onPrimary: Color(0xFFFFFFFF),
      tint: Color(0xFFE6ECFF),
      border: Color(0xFF000000),
      accent: Color(0xFF000000),
      successBg: Color(0xFFFFFFFF),
      successFg: Color(0xFF005A1E),
      warningBg: Color(0xFFFFFFFF),
      warningFg: Color(0xFF5C3A00),
      dangerBg: Color(0xFFFFFFFF),
      dangerFg: Color(0xFF9E0000),
      neutralBg: Color(0xFFFFFFFF),
      neutralFg: Color(0xFF000000),
      borderWidth: 2,
      outlinedStatus: true,
    ),
    dark: AppPalette(
      background: Color(0xFF000000),
      surface: Color(0xFF000000),
      surfaceSolid: Color(0xFF000000),
      text: Color(0xFFFFFFFF),
      muted: Color(0xFFF0F0F0),
      primary: Color(0xFFFFD60A),
      onPrimary: Color(0xFF000000),
      tint: Color(0xFF2A2400),
      border: Color(0xFFFFFFFF),
      accent: Color(0xFFFFFFFF),
      successBg: Color(0xFF000000),
      successFg: Color(0xFF7CFFA0),
      warningBg: Color(0xFF000000),
      warningFg: Color(0xFFFFD60A),
      dangerBg: Color(0xFF000000),
      dangerFg: Color(0xFFFF8A80),
      neutralBg: Color(0xFF000000),
      neutralFg: Color(0xFFFFFFFF),
      borderWidth: 2,
      outlinedStatus: true,
    ),
  ),
  easyRead(
    label: 'Easy read',
    description: 'Larger text, less glare and less motion',
    fontFamily: _atkinson,
    textScale: 1.15,
    reduceMotion: true,
    isAccessibility: true,
    light: AppPalette(
      background: Color(0xFFFBF7EC),
      surface: Color(0xFFFFFDF6),
      surfaceSolid: Color(0xFFFFFDF6),
      text: Color(0xFF1B2A4A),
      muted: Color(0xFF3E4C66),
      primary: Color(0xFF1F5FAF),
      onPrimary: Color(0xFFFFFFFF),
      tint: Color(0xFFE3ECF8),
      border: Color(0xFFE6DFCB),
      accent: Color(0xFFD9822B),
    ),
    dark: AppPalette.dark(
      background: Color(0xFF14181F),
      surface: Color(0xFF1C222C),
      surfaceSolid: Color(0xFF1C222C),
      text: Color(0xFFF2EEE3),
      muted: Color(0xFFC3C8D2),
      primary: Color(0xFF8DB8F2),
      onPrimary: Color(0xFF0A2547),
      tint: Color(0xFF24344C),
      border: Color(0xFF2E3644),
      accent: Color(0xFFE89A4A),
    ),
  );

  const AppThemeId({
    required this.label,
    required this.description,
    required this.fontFamily,
    required this.light,
    required this.dark,
    this.textScale = 1,
    this.reduceMotion = false,
    this.isAccessibility = false,
    this.iosOnly = false,
  });

  final String label;
  final String description;
  final String fontFamily;
  final AppPalette light;
  final AppPalette dark;

  /// Multiplies the system text size.
  final double textScale;

  /// Turns off page and widget animations.
  final bool reduceMotion;
  final bool isAccessibility;
  final bool iosOnly;

  /// This theme's app icon, as shown in the app.
  String get iconAsset => 'assets/icons/$name.png';

  AppPalette palette(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;

  static bool get _isIOS => defaultTargetPlatform == TargetPlatform.iOS;

  static AppThemeId get platformDefault => _isIOS ? glass : clinical;

  /// The themes offered on this device.
  static List<AppThemeId> get available =>
      values.where((theme) => !theme.iosOnly || _isIOS).toList();
}
