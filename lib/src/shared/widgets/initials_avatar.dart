import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:dialink/src/app/theme/app_palette.dart';
import 'package:dialink/src/core/utils/extensions.dart';

/// Initials in a tinted circle.
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({super.key, required this.name, this.size = 44});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final initials = name
        .replaceFirst('Dr. ', '')
        .split(' ')
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part.characters.first.toUpperCase())
        .join();

    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: p.tint, shape: BoxShape.circle),
        child: Text(
          initials,
          style: context.textTheme.labelLarge!.copyWith(
            color: p.primary,
            fontSize: size * .34,
          ),
        ),
      ),
    );
  }
}
