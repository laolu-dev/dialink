import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../core/core.dart';

class CustomDropdown extends StatelessWidget {
  const CustomDropdown({
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
            trailingIcon: const Icon(Iconsax.arrow_down_1),
            selectedTrailingIcon: const Icon(Iconsax.arrow_up_2),
            dropdownMenuEntries: [
              for (final option in options)
                DropdownMenuEntry<String>(value: option, label: option),
            ],
          ),
        ],
      ),
    );
  }
}
