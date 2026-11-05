import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:dialink/src/core/core.dart';
import 'package:dialink/src/features/authentication/presentation/views/account_screen.dart';
import 'package:dialink/src/features/book-appointment/presentation/views/find_provider_screen.dart';
import 'package:dialink/src/features/book-appointment/presentation/views/home_screen.dart';
import 'package:dialink/src/features/book-appointment/presentation/views/visits_screen.dart';
import 'package:dialink/src/widgets/surface.dart';

part 'home_shell.g.dart';

enum ShellTab {
  home("Home", Iconsax.home_2),
  find("Find", Iconsax.search_normal_1),
  visits("Visits", Iconsax.calendar_1),
  account("Account", Iconsax.user);

  const ShellTab(this.label, this.icon);
  final String label;
  final IconData icon;
}

@Riverpod(keepAlive: true)
class SelectedTab extends _$SelectedTab {
  @override
  ShellTab build() => ShellTab.home;

  void select(ShellTab tab) => state = tab;
}

/// Window widths from here get a side rail instead of bottom tabs, e.g. an
/// unfolded iPhone Duo (669 pt) or a tablet. Split View can narrow the
/// window again, so this follows the width, not the device.
const wideLayoutWidth = 600.0;

/// The signed-in app: four tabs, at the bottom on phones and on the side on
/// wide screens, as iPhone Duo puts navigation.
class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  static const _pages = [
    HomeScreen(),
    FindProviderScreen(),
    VisitsScreen(),
    AccountScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(selectedTabProvider);
    final select = ref.read(selectedTabProvider.notifier).select;
    final wide = MediaQuery.sizeOf(context).width >= wideLayoutWidth;

    final pages = IndexedStack(
      index: tab.index,
      children: [
        for (final (i, page) in _pages.indexed)
          // Off-screen tabs keep their state but don't hold focus or speak.
          TickerMode(
            enabled: i == tab.index,
            child: ExcludeSemantics(excluding: i != tab.index, child: page),
          ),
      ],
    );

    if (wide) {
      return _Backdrop(
        child: Row(
          children: [
            SafeArea(
              right: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 0, 12),
                child: _TabBar(selected: tab, onSelect: select, vertical: true),
              ),
            ),
            Expanded(
              child: MediaQuery.removePadding(
                context: context,
                removeLeft: true,
                child: pages,
              ),
            ),
          ],
        ),
      );
    }

    // The pages leave room for the floating bar through the bottom padding.
    final media = MediaQuery.of(context);
    return _Backdrop(
      child: Stack(
        children: [
          MediaQuery(
            data: media.copyWith(
              padding: media.padding.copyWith(
                bottom: media.padding.bottom + _TabBar.height + 12,
              ),
            ),
            child: pages,
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: media.padding.bottom + 8,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: _TabBar(selected: tab, onSelect: select),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The tab pages draw straight onto the background, so this gives their text
/// fields and ink a [Material] to sit on.
class _Backdrop extends StatelessWidget {
  const _Backdrop({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => AppBackground(
    child: Material(type: MaterialType.transparency, child: child),
  );
}

class _TabBar extends StatelessWidget {
  const _TabBar({
    required this.selected,
    required this.onSelect,
    this.vertical = false,
  });

  /// About the bar's height at the largest text size it allows.
  static const height = 76.0;

  final ShellTab selected;
  final ValueChanged<ShellTab> onSelect;
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    final items = [
      for (final tab in ShellTab.values)
        _TabItem(
          tab: tab,
          selected: tab == selected,
          onTap: () {
            if (tab != selected) HapticFeedback.selectionClick();
            onSelect(tab);
          },
        ),
    ];

    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: AppSurface(
        radius: 34,
        padding: const EdgeInsets.all(6),
        child: vertical
            ? SizedBox(
                width: 72,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 8,
                  children: items,
                ),
              )
            : Row(children: [for (final item in items) Expanded(child: item)]),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  final ShellTab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final color = selected ? p.primary : p.muted;

    return Semantics(
      button: true,
      selected: selected,
      label: tab.label,
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 2,
            children: [
              AnimatedContainer(
                duration: Durations.short4,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: selected ? p.tint : Colors.transparent,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Icon(tab.icon, color: color, size: 22),
              ),
              Text(
                tab.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textScaler: MediaQuery.textScalerOf(
                  context,
                ).clamp(maxScaleFactor: 1.3),
                style: context.textTheme.labelSmall!
                    .weight(selected ? FontWeight.w700 : FontWeight.w400)
                    .copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
