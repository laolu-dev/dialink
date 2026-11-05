import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:dialink/src/shared/widgets/app_surface.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.child,
    this.padding,
    this.makeScrollable = false,
    this.title,
    this.showBackButton = false,
    this.bottom,
    this.maxWidth = 560,
  });

  final Widget child;
  final bool makeScrollable;
  final EdgeInsetsGeometry? padding;

  /// Shows an app bar with this title.
  final String? title;

  /// Shows an app bar with only a back button, for screens pushed on top.
  final bool showBackButton;

  /// Pinned under the content, e.g. the screen's main button.
  final Widget? bottom;

  /// Content stays readable on wide screens, like an unfolded iPhone Duo.
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final padding =
        this.padding ??
        const EdgeInsets.symmetric(horizontal: 20, vertical: 12);

    Widget body = switch (makeScrollable) {
      true => SingleChildScrollView(padding: padding, child: child),
      _ => Padding(padding: padding, child: child),
    };
    body = Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: body,
      ),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: AppBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: switch (title != null || showBackButton) {
            true => AppBar(title: title != null ? Text(title!) : null),
            _ => null,
          },
          body: SafeArea(child: body),
          bottomNavigationBar: bottom == null
              ? null
              : SafeArea(
                  child: Center(
                    heightFactor: 1,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                        child: bottom,
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
