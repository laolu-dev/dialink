import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import 'package:dialink/src/config/config.dart';
import 'package:dialink/src/core/core.dart';
import 'package:dialink/src/widgets/common.dart';
import 'package:dialink/src/widgets/custom_scaffold.dart';
import 'package:dialink/src/widgets/surface.dart';

/// Theme, light or dark, and the app icon.
class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(themeSettingsControllerProvider);
    final themes = ref.read(themeSettingsControllerProvider.notifier);
    final standard = AppThemeId.available.where((t) => !t.isAccessibility);
    final accessible = AppThemeId.available.where((t) => t.isAccessibility);
    final icon = settings.iconFollowsTheme
        ? settings.theme
        : AppThemeId.platformDefault;

    return AppScaffold(
      title: "Appearance",
      makeScrollable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSurface(
            child: Row(
              spacing: 16,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(
                    icon.iconAsset,
                    width: 60,
                    height: 60,
                    semanticLabel: "${icon.label} app icon",
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "App icon matches theme",
                        style: context.textTheme.titleSmall,
                      ),
                      Text(
                        Theme.of(context).platform == TargetPlatform.iOS
                            ? "iOS will confirm each change."
                            : "Changes when you leave the app.",
                        style: context.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: settings.iconFollowsTheme,
                  onChanged: themes.setIconFollowsTheme,
                ),
              ],
            ),
          ),
          20.0.verticalSpacing,
          const SectionLabel("Mode"),
          SegmentedButton<ThemeMode>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: ThemeMode.system, label: Text("System")),
              ButtonSegment(value: ThemeMode.light, label: Text("Light")),
              ButtonSegment(value: ThemeMode.dark, label: Text("Dark")),
            ],
            selected: {settings.mode},
            onSelectionChanged: (mode) => themes.setMode(mode.first),
          ),
          20.0.verticalSpacing,
          const SectionLabel("Themes"),
          _ThemeGroup(
            themes: standard,
            selected: settings.theme,
            onSelect: themes.setTheme,
          ),
          20.0.verticalSpacing,
          const SectionLabel("Accessibility themes"),
          _ThemeGroup(
            themes: accessible,
            selected: settings.theme,
            onSelect: themes.setTheme,
          ),
        ],
      ),
    );
  }
}

class _ThemeGroup extends StatelessWidget {
  const _ThemeGroup({
    required this.themes,
    required this.selected,
    required this.onSelect,
  });

  final Iterable<AppThemeId> themes;
  final AppThemeId selected;
  final ValueChanged<AppThemeId> onSelect;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return AppSurface(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (final (i, theme) in themes.indexed) ...[
            if (i > 0) const Divider(height: 1, indent: 16, endIndent: 16),
            _ThemeRow(
              theme: theme,
              swatch: theme.palette(brightness),
              selected: theme == selected,
              onTap: () => onSelect(theme),
            ),
          ],
        ],
      ),
    );
  }
}

class _ThemeRow extends StatelessWidget {
  const _ThemeRow({
    required this.theme,
    required this.swatch,
    required this.selected,
    required this.onTap,
  });

  final AppThemeId theme;
  final AppPalette swatch;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            spacing: 14,
            children: [
              // The theme's own colours, so it can be judged before picking.
              ExcludeSemantics(
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: swatch.background,
                    shape: BoxShape.circle,
                    border: Border.all(color: p.border, width: p.borderWidth),
                  ),
                  alignment: Alignment.center,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: swatch.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      theme.label,
                      style: context.textTheme.titleSmall!.copyWith(
                        fontFamily: theme.fontFamily,
                      ),
                    ),
                    Text(
                      theme == AppThemeId.platformDefault
                          ? "${theme.description} · default"
                          : theme.description,
                      style: context.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(
                selected ? Iconsax.tick_circle5 : Iconsax.record,
                color: selected ? p.primary : p.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
