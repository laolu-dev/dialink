import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import 'package:dialink/src/app/theme/app_palette.dart';
import 'package:dialink/src/core/utils/extensions.dart';
import 'package:dialink/src/shared/utils/keyboard.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.hint,
    this.inputType,
    this.validator,
    this.maxLength,
    this.maxLines = 1,
    this.icon,
    this.autofillHints,
    this.textInputAction,
    required this.label,
    required this.controller,
  });

  final String label;
  final String? hint;
  final int maxLines;
  final int? maxLength;
  final IconData? icon;
  final Iterable<String>? autofillHints;
  final TextInputAction? textInputAction;
  final TextInputType? inputType;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        spacing: 6,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The label is read with the field, not as loose text above it.
          ExcludeSemantics(
            child: Text(label, style: context.textTheme.labelLarge),
          ),
          Semantics(
            label: label,
            child: TextFormField(
              controller: controller,
              keyboardType: inputType,
              textInputAction: textInputAction,
              autofillHints: autofillHints,
              validator: validator,
              maxLines: maxLines,
              maxLength: maxLength,
              onTapOutside: (_) => closeKeyboard(),
              style: context.textTheme.bodyLarge,
              buildCounter: switch (maxLength != null) {
                true =>
                  (
                    context, {
                    required currentLength,
                    required isFocused,
                    required maxLength,
                  }) => Text(
                    "$currentLength/$maxLength",
                    style: context.textTheme.bodySmall,
                  ),
                _ => null,
              },
              decoration: InputDecoration(
                hintText: hint,
                prefixIcon: icon != null ? Icon(icon, size: 20) : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AppPasswordField extends StatefulWidget {
  const AppPasswordField({
    super.key,
    this.hint,
    this.validator,
    this.isNewPassword = false,
    this.textInputAction,
    this.onSubmitted,
    required this.label,
    required this.controller,
  });

  final String label;
  final String? hint;
  final String? Function(String?)? validator;
  final TextEditingController controller;

  /// Lets the password manager suggest a strong password.
  final bool isNewPassword;
  final TextInputAction? textInputAction;
  final VoidCallback? onSubmitted;

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        spacing: 6,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExcludeSemantics(
            child: Text(widget.label, style: context.textTheme.labelLarge),
          ),
          Semantics(
            label: widget.label,
            child: TextFormField(
              obscuringCharacter: '●',
              controller: widget.controller,
              validator: widget.validator,
              obscureText: !_visible,
              textInputAction: widget.textInputAction,
              onFieldSubmitted: (_) => widget.onSubmitted?.call(),
              onTapOutside: (_) => closeKeyboard(),
              autofillHints: [
                widget.isNewPassword
                    ? AutofillHints.newPassword
                    : AutofillHints.password,
              ],
              style: context.textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: widget.hint,
                prefixIcon: const Icon(Iconsax.lock, size: 20),
                suffixIcon: IconButton(
                  tooltip: _visible ? "Hide password" : "Show password",
                  onPressed: () => setState(() => _visible = !_visible),
                  icon: Icon(
                    _visible ? Iconsax.eye : Iconsax.eye_slash,
                    color: _visible ? context.palette.primary : null,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
