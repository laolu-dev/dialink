import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import 'package:dialink/src/app/theme/app_palette.dart';

/// A card, bar or panel. Frosted glass in the glass theme, solid otherwise.
class AppSurface extends StatelessWidget {
  const AppSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 20,
    this.onTap,
    this.selected = false,
    this.color,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;

  /// Outlines the surface in the primary colour.
  final bool selected;

  /// Replaces the surface colour, e.g. for a warning banner.
  final Color? color;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: BorderSide(
        color: selected ? p.primary : borderColor ?? p.border,
        width: selected ? p.borderWidth + 1 : p.borderWidth,
      ),
    );

    Widget surface = Material(
      color: color ?? p.surface,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );

    if (p.isGlass && color == null) {
      surface = ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: surface,
        ),
      );
    }
    return surface;
  }
}

/// The page background: soft colour fields behind the glass theme, the plain
/// background colour otherwise.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    if (!p.isGlass) return ColoredBox(color: p.background, child: child);

    Widget glow(Color color, Alignment alignment) => Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: alignment,
            radius: .9,
            colors: [color, color.withValues(alpha: 0)],
          ),
        ),
      ),
    );

    const spots = [Alignment(-.8, -.9), Alignment(.9, .5), Alignment(.4, -.5)];
    return ColoredBox(
      color: p.background,
      child: Stack(
        children: [
          for (final (i, color) in p.glows.indexed) glow(color, spots[i % 3]),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}
