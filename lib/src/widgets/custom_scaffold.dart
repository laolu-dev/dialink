import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.child,
    this.padding,
    this.makeScrollable = false,
  });

  final Widget child;
  final bool makeScrollable;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: switch (makeScrollable) {
          true => SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: child,
            ),
          _ => Padding(
              padding:
                  padding ?? EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: child,
            ),
        },
      ),
    );
  }
}
