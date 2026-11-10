import 'package:flutter/material.dart';
import '../../widgets/dark_text_field.dart';

/// Numeric combustion input field wrapped with optional pre-flight validation.
class NumericCombustionField extends StatelessWidget {
  final String label;
  final String hintText;
  final String? unit;
  final TextEditingController controller;
  final TextInputAction textInputAction;
  final VoidCallback onChanged;
  final bool required;

  const NumericCombustionField({
    super.key,
    required this.label,
    required this.hintText,
    this.unit,
    required this.controller,
    required this.textInputAction,
    required this.onChanged,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return DarkTextField(
      label: label,
      hintText: hintText,
      unit: unit,
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: textInputAction,
      onChanged: onChanged,
      validator:
          required ? (v) => (v == null || v.trim().isEmpty) ? '' : null : null,
    );
  }
}
