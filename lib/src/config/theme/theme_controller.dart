import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_themes.dart';

part 'theme_controller.g.dart';

/// Loaded before the app starts, so the saved theme shows on the first frame.
@Riverpod(keepAlive: true)
SharedPreferences preferences(Ref ref) =>
    throw UnimplementedError('Overridden in main()');

@immutable
class ThemeSettings {
  const ThemeSettings({
    required this.theme,
    required this.mode,
    required this.iconFollowsTheme,
  });

  final AppThemeId theme;

  /// System follows the device's light or dark setting.
  final ThemeMode mode;

  /// The home screen icon changes with the theme.
  final bool iconFollowsTheme;

  ThemeSettings copyWith({
    AppThemeId? theme,
    ThemeMode? mode,
    bool? iconFollowsTheme,
  }) => ThemeSettings(
    theme: theme ?? this.theme,
    mode: mode ?? this.mode,
    iconFollowsTheme: iconFollowsTheme ?? this.iconFollowsTheme,
  );
}

/// The patient's theme and light/dark choice, kept on this device.
@Riverpod(keepAlive: true)
class ThemeSettingsController extends _$ThemeSettingsController {
  static const _themeKey = 'dialink.theme';
  static const _modeKey = 'dialink.themeMode';
  static const _iconKey = 'dialink.iconFollowsTheme';

  SharedPreferences get _prefs => ref.read(preferencesProvider);

  @override
  ThemeSettings build() {
    final prefs = ref.watch(preferencesProvider);
    final saved = AppThemeId.values.asNameMap()[prefs.getString(_themeKey)];
    final mode = ThemeMode.values.asNameMap()[prefs.getString(_modeKey)];

    return ThemeSettings(
      // A theme saved on another platform may not be offered here.
      theme: AppThemeId.available.contains(saved)
          ? saved!
          : AppThemeId.platformDefault,
      mode: mode ?? ThemeMode.system,
      iconFollowsTheme: prefs.getBool(_iconKey) ?? true,
    );
  }

  void setTheme(AppThemeId theme) {
    state = state.copyWith(theme: theme);
    _prefs.setString(_themeKey, theme.name);
    _syncIcon();
  }

  void setIconFollowsTheme(bool follow) {
    state = state.copyWith(iconFollowsTheme: follow);
    _prefs.setBool(_iconKey, follow);
    _syncIcon();
  }

  /// The standard icon is the platform's default theme's.
  void _syncIcon() => AppIcon.set(
    state.iconFollowsTheme ? state.theme : AppThemeId.platformDefault,
  );

  void setMode(ThemeMode mode) {
    state = state.copyWith(mode: mode);
    _prefs.setString(_modeKey, mode.name);
  }
}

/// The home screen icon, one per theme. See tool/generate_app_icon.py.
///
/// iOS shows an alert each time the icon changes; Android swaps it once the
/// app is in the background.
abstract final class AppIcon {
  static const _channel = MethodChannel('dialink/app_icon');

  static Future<void> set(AppThemeId theme) async {
    final suffix = theme.name[0].toUpperCase() + theme.name.substring(1);
    // The primary icons, Glass on iOS and Clinical on Android, are null.
    final String? name;
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        name = theme == AppThemeId.glass ? null : 'AppIcon-$suffix';
      case TargetPlatform.android:
        name = theme == AppThemeId.clinical ? null : 'Launcher$suffix';
      default:
        return;
    }

    try {
      await _channel.invokeMethod<bool>('setIcon', name);
    } on PlatformException catch (e) {
      debugPrint('App icon not changed: ${e.message}');
    } on MissingPluginException {
      // Not available on this platform.
    }
  }
}

/// Whether iOS asks apps to reduce transparency. Glass is drawn solid then.
///
/// Flutter doesn't expose the setting, so the app asks iOS at launch and
/// each time it comes back to the foreground.
@Riverpod(keepAlive: true)
class ReduceTransparency extends _$ReduceTransparency {
  static const _channel = MethodChannel('dialink/accessibility');

  @override
  bool build() {
    if (defaultTargetPlatform != TargetPlatform.iOS) return false;

    final listener = AppLifecycleListener(onResume: _read);
    ref.onDispose(listener.dispose);
    _read();
    return false;
  }

  Future<void> _read() async {
    try {
      final reduce = await _channel.invokeMethod<bool>('reduceTransparency');
      if (ref.mounted) state = reduce ?? false;
    } on PlatformException {
      // Keep the current value.
    } on MissingPluginException {
      // Keep the current value.
    }
  }
}
