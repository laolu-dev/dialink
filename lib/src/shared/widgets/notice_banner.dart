import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import 'package:dialink/src/app/theme/app_palette.dart';
import 'package:dialink/src/core/utils/extensions.dart';
import 'package:dialink/src/shared/widgets/app_surface.dart';

/// A tappable notice, e.g. to confirm the email address.
class NoticeBanner extends StatelessWidget {
  const NoticeBanner({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String message;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return AppSurface(
      color: p.warningBg,
      borderColor: p.warningFg.withValues(alpha: p.outlinedStatus ? 1 : .35),
      padding: const EdgeInsets.all(14),
      radius: 18,
      onTap: onTap,
      child: Row(
        spacing: 12,
        children: [
          Icon(icon, color: p.warningFg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.textTheme.titleSmall!.copyWith(
                    color: p.warningFg,
                  ),
                ),
                Text(
                  message,
                  style: context.textTheme.bodyMedium!.copyWith(
                    color: p.warningFg,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null) Icon(Iconsax.arrow_right_3, color: p.warningFg),
        ],
      ),
    );
  }
}
