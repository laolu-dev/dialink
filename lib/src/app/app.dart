import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toastification/toastification.dart';

import 'package:dialink/src/app/router/app_router.dart';
import 'package:dialink/src/app/theme/app_palette.dart';
import 'package:dialink/src/app/theme/app_themes.dart';
import 'package:dialink/src/app/theme/theme_builder.dart';
import 'package:dialink/src/app/theme/theme_settings_controller.dart';
import 'package:dialink/src/core/services/accessibility/reduce_transparency.dart';

class Dialink extends ConsumerWidget {
  const Dialink({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(themeSettingsControllerProvider);
    final reduceTransparency = ref.watch(reduceTransparencyProvider);
    final id = settings.theme;

    ThemeData themeFor(Brightness brightness) {
      final palette = id.palette(brightness);
      return buildTheme(
        id,
        brightness,
        palette: reduceTransparency ? palette.solid : palette,
      );
    }

    return ToastificationWrapper(
      child: MaterialApp.router(
        title: 'Dialink',
        routerConfig: ref.watch(appRouterProvider),
        theme: themeFor(Brightness.light),
        darkTheme: themeFor(Brightness.dark),
        themeMode: settings.mode,
        builder: (context, child) => _Accessibility(id: id, child: child!),
      ),
    );
  }
}

/// Applies the theme's text size and motion, on top of the system's, and
/// drops the glass when the system asks for more contrast.
class _Accessibility extends StatelessWidget {
  const _Accessibility({required this.id, required this.child});

  final AppThemeId id;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final theme = Theme.of(context);
    final palette = theme.extension<AppPalette>()!;

    var page = child;
    if (palette.isGlass && media.highContrast) {
      page = Theme(
        data: buildTheme(id, theme.brightness, palette: palette.solid),
        child: page,
      );
    }

    final scale = media.textScaler.scale(16) / 16 * id.textScale;
    return MediaQuery(
      data: media.copyWith(
        textScaler: TextScaler.linear(scale.clamp(.8, 3)),
        disableAnimations: media.disableAnimations || id.reduceMotion,
      ),
      child: page,
    );
  }
}
