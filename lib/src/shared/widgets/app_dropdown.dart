import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import 'package:dialink/src/core/utils/extensions.dart';

class AppDropdown extends StatelessWidget {
  const AppDropdown({
    super.key,
    this.hint,
    this.controller,
    this.options = const [],
    required this.label,
  });

  final String? hint;
  final String label;
  final TextEditingController? controller;
  final List<String> options;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      // One node for screen readers, so the field is announced with its label.
      child: MergeSemantics(
        child: Column(
          spacing: 6,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: context.textTheme.labelLarge),
            DropdownMenu<String>(
              expandedInsets: EdgeInsets.zero,
              hintText: hint,
              controller: controller,
              textStyle: context.textTheme.bodyLarge,
              // Material's menu has its own grey field, made 56 dp tall by its
              // 48 dp arrow button. Use the app's field, and let the arrow sit
              // at 40 dp: the whole field is the tap target, so it matches the
              // text fields around it.
              inputDecorationTheme: Theme.of(context).inputDecorationTheme
                  .copyWith(
                    suffixIconConstraints: const BoxConstraints.tightFor(
                      width: 40,
                      height: 40,
                    ),
                  ),
              trailingIcon: const Icon(Iconsax.arrow_down_1),
              selectedTrailingIcon: const Icon(Iconsax.arrow_up_2),
              dropdownMenuEntries: [
                for (final option in options)
                  DropdownMenuEntry<String>(value: option, label: option),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
