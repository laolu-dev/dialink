import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import 'package:dialink/src/core/core.dart';

class CustomTextfield extends StatelessWidget {
  const CustomTextfield({
    super.key,
    this.hint,
    this.inputType,
    this.validator,
    this.maxLength,
    this.maxLines = 1,
    required this.label,
    required this.controller,
  });

  final String label;
  final String? hint;
  final int maxLines;
  final int? maxLength;
  final TextInputType? inputType;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 4,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.textTheme.labelLarge),
        TextFormField(
          controller: controller,
          keyboardType: inputType,
          validator: validator,
          maxLines: maxLines,
          maxLength: maxLength,
          buildCounter: switch (maxLength != null) {
            true => (context,
                    {required currentLength,
                    required isFocused,
                    required maxLength}) =>
                Text(
                  "$currentLength/$maxLength",
                  style: context.textTheme.labelMedium?.copyWith(
                    color: AppColors.textColor.withValues(alpha: .4),
                  ),
                ),
            _ => null
          },
          decoration: switch (maxLength != null) {
            true => InputDecoration(
                hintText: hint,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.secondary, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.secondary.withValues(alpha: .6),
                    width: 0.5,
                  ),
                ),
              ),
            _ => InputDecoration(hintText: hint)
          },
        ),
        12.0.verticalSpacing
      ],
    );
  }
}

class CustomPasswordTextfield extends StatefulWidget {
  const CustomPasswordTextfield({
    super.key,
    this.hint,
    this.validator,
    required this.label,
    required this.controller,
  });

  final String label;
  final String? hint;
  final String? Function(String?)? validator;
  final TextEditingController controller;

  @override
  State<CustomPasswordTextfield> createState() =>
      _CustomPasswordTextfieldState();
}

class _CustomPasswordTextfieldState extends State<CustomPasswordTextfield> {
  bool _obscureText = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 4,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: context.textTheme.labelLarge),
        TextFormField(
          obscuringCharacter: '●',
          controller: widget.controller,
          validator: widget.validator,
          obscureText: !_obscureText,
          decoration: InputDecoration(
            hintText: widget.hint,
            suffixIcon: IconButton(
              onPressed: () => setState(() => _obscureText = !_obscureText),
              icon: Icon(
                switch (_obscureText) {
                  false => Iconsax.eye_slash,
                  _ => Iconsax.eye
                },
                color: switch (_obscureText) {
                  true => AppColors.secondary,
                  _ => AppColors.textColor.withValues(alpha: .3)
                },
              ),
            ),
          ),
        ),
        12.0.verticalSpacing
      ],
    );
  }
}
