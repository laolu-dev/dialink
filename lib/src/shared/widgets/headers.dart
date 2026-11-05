import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:dialink/src/app/theme/app_palette.dart';
import 'package:dialink/src/core/utils/extensions.dart';

/// A screen's title and an optional line under it.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        Semantics(
          header: true,
          child: Text(title, style: context.textTheme.headlineMedium),
        ),
        if (subtitle != null)
          Text(
            subtitle!,
            style: context.textTheme.bodyLarge!.copyWith(
              color: context.palette.muted,
            ),
          ),
      ],
    );
  }
}

/// A small heading above a group of content.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: context.textTheme.labelLarge!.copyWith(
            color: context.palette.muted,
          ),
        ),
      ),
    );
  }
}
