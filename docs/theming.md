# Theming

Seven themes, each in light and dark, in `lib/src/app/theme/app_themes.dart`:
Glass (iOS only, the iOS default), Clinical (the Android default), Sage,
Sunset, Midnight, and two accessibility themes, High contrast and Easy read.

- Colours come from the theme's `AppPalette`, read with `context.palette`.
  Don't hard-code colours in widgets.
- Text uses Plus Jakarta Sans; the accessibility themes use Atkinson
  Hyperlegible. Set weights with `TextStyle.weight()` so the variable font's
  axis follows.
- Glass draws frosted surfaces (`AppSurface`, `AppBackground`). It turns solid
  when iOS Reduce Transparency is on, or with high contrast.
- Easy read scales text and turns animations off; check new animations
  respect `MediaQuery.disableAnimationsOf`.

## Adding a theme

1. Add it to `AppThemeId` with its light and dark palettes.
2. Add its icon colours to `THEMES` in `tool/generate_app_icon.py`, and run
   `python3 tool/generate_app_icon.py` (needs Pillow). This writes the iOS
   icon sets (prod and dev), the Android mipmaps (main and dev) and
   `assets/icons/<theme>.png`.
3. iOS: add `AppIcon-<Theme>` and `AppIconDev-<Theme>` to
   `APP_ALTERNATE_ICONS` in `ios/Flutter/prod.xcconfig` and `dev.xcconfig`.
4. Android: add an `<activity-alias>` named `Launcher<Theme>` to
   `AndroidManifest.xml`, and to `ALIASES` in `MainActivity.kt`.
5. Run `test/app/layout_stress_test.dart` and check light and dark on a
   device.

## App icons

The home screen icon follows the theme (Appearance can turn this off). Dart
sends the theme name ("Sage", or null for the platform default); iOS turns it
into `AppIcon-Sage` or `AppIconDev-Sage` by flavour, and Android enables the
`LauncherSage` alias when the app goes to the background. iOS shows an alert
for each change.
