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

    // The circle grows a little with the reading size, to stay in proportion
    // with the name beside it; the initials are sized from the circle alone,
    // so large text can't push one of them out. Screen readers read the name.
    final scale = (MediaQuery.textScalerOf(context).scale(16) / 16).clamp(
      1.0,
      1.5,
    );
    final diameter = size * scale;

    return ExcludeSemantics(
      child: MediaQuery.withNoTextScaling(
        child: Container(
          width: diameter,
          height: diameter,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: p.tint, shape: BoxShape.circle),
          child: Text(
            initials,
            maxLines: 1,
            style: context.textTheme.labelLarge!.copyWith(
              color: p.primary,
              fontSize: diameter * .34,
            ),
          ),
        ),
      ),
    );
  }
}
