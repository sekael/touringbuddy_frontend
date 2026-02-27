import 'package:flutter/material.dart';

class NameFormField extends StatelessWidget {
  const NameFormField({
    super.key,
    required this.controller,
    this.labelText,
    this.maxInputLength = 50,
    this.validatorOverride,
  });

  final TextEditingController controller;
  final String? labelText;
  final int maxInputLength;
  final String? Function(String? value)? validatorOverride;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final displayText = labelText ?? 'Name';

    String? defaultValidator(String? v) {
      final value = v?.trim() ?? '';
      if (value.isEmpty) {
        return '$displayText is required';
      }
      if (value.length > maxInputLength) {
        return '$displayText must be at most $maxInputLength characters long';
      }
      return null;
    }

    return TextFormField(
      controller: controller,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: displayText,
        border: OutlineInputBorder(),
      ),
      validator: validatorOverride ?? defaultValidator,
      style: t.bodyMedium!.copyWith(
        color: Theme.of(context).colorScheme.inverseSurface,
      ),
    );
  }
}
