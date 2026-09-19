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
    return Column(
      spacing: 4,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.textTheme.labelLarge),
        DropdownMenu<String>(
          width: context.deviceSize.width * .5,
          hintText: hint,
          controller: controller,
          textStyle: context.textTheme.labelMedium,
          trailingIcon: Icon(Iconsax.arrow_down_1),
          selectedTrailingIcon: Icon(Iconsax.arrow_up_2),
          inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
                constraints: BoxConstraints(maxHeight: 48),
              ),
          menuStyle: MenuStyle(
          
            backgroundColor: WidgetStatePropertyAll(AppColors.background),
          ),
          dropdownMenuEntries: options
              .map(
                (option) => DropdownMenuEntry<String>(
                  value: option,
                  label: option,
                  labelWidget: Text(
                    option,
                    style: context.textTheme.bodySmall
                        ?.copyWith(color: AppColors.textColor),
                  ),
                ),
              )
              .toList(),
        ),
        12.0.verticalSpacing
      ],
    );
  }
}
