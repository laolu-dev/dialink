import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dialink/src/app/theme/app_themes.dart';
import 'package:dialink/src/core/services/app_icon/app_icon_channel.dart';
import 'package:dialink/src/core/storage/preferences.dart';
part 'theme_settings_controller.g.dart';

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
    (state.iconFollowsTheme ? state.theme : AppThemeId.platformDefault)
        .iconName,
  );

  void setMode(ThemeMode mode) {
    state = state.copyWith(mode: mode);
    _prefs.setString(_modeKey, mode.name);
  }
}
