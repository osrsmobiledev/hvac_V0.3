import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import '../../widgets/dark_input_box.dart';
import '../../widgets/dark_input_label.dart';

/// Standard labeled text input field for the Firma - Technicus tab.
class FirmaField extends StatelessWidget {
  final Key? fieldKey;
  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? prefixText;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;
  final AutovalidateMode autovalidateMode;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final VoidCallback onChanged;

  const FirmaField({
    super.key,
    this.fieldKey,
    required this.label,
    required this.controller,
    this.hint,
    this.prefixText,
    this.inputFormatters,
    this.validator,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        DarkInputLabel(label),
        TextFormField(
          key: fieldKey,
          controller: controller,
          onChanged: (_) => onChanged(),
          validator: validator,
          autovalidateMode: autovalidateMode,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          inputFormatters: inputFormatters,
          style: DarkInputBox.inputStyle,
          cursorColor: AppColors.amberGoldBorder,
          decoration: DarkInputBox.decoration(
            hintText: hint,
            prefixText: prefixText,
          ),
        ),
      ],
    );
  }
}

/// Standard labeled action/picker field with trailing button for date/time.
class FirmaActionField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final VoidCallback onTap;
  final TextAlign textAlign;

  const FirmaActionField({
    super.key,
    required this.label,
    required this.controller,
    required this.hint,
    required this.icon,
    required this.onTap,
    this.textAlign = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        DarkInputLabel(label),
        Stack(
          alignment: Alignment.center,
          children: [
            TextField(
              controller: controller,
              readOnly: true,
              keyboardType: TextInputType.none,
              textInputAction: TextInputAction.none,
              onTap: onTap,
              textAlign: textAlign,
              style: DarkInputBox.inputStyle,
              decoration: DarkInputBox.decoration(
                hintText: hint,
              ).copyWith(
                // Symmetrical 36px horizontal padding guarantees true geometric centering
                // while reserving a safe buffer so text never touches the right icon.
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 36.0,
                  vertical: 12.0,
                ),
              ),
            ),
            Positioned(
              right: 12,
              child: IgnorePointer(
                child: Icon(
                  icon,
                  color: AppColors.amberGold,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
