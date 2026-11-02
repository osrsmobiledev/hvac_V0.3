// File: lib/features/certificate_draft/ui/widgets/dark_action_field.dart
// Responsibility: Tactical reusable picker input field with centered text and trailing action icon.

import 'package:flutter/material.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'dark_input_box.dart';
import 'dark_input_label.dart';

/// Reusable dark action/picker field with centered text and trailing icon.
class DarkActionField extends StatefulWidget {
  final String? label;
  final TextEditingController? controller;
  final String? valueText;
  final String hint;
  final IconData icon;
  final VoidCallback onTap;
  final TextAlign textAlign;

  const DarkActionField({
    super.key,
    this.label,
    this.controller,
    this.valueText,
    required this.hint,
    required this.icon,
    required this.onTap,
    this.textAlign = TextAlign.center,
  });

  @override
  State<DarkActionField> createState() => _DarkActionFieldState();
}

class _DarkActionFieldState extends State<DarkActionField> {
  TextEditingController? _internalController;

  TextEditingController get _effectiveController =>
      widget.controller ??
      (_internalController ??=
          TextEditingController(text: widget.valueText ?? ''));

  @override
  void didUpdateWidget(covariant DarkActionField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller == null && oldWidget.valueText != widget.valueText) {
      _effectiveController.text = widget.valueText ?? '';
    }
  }

  @override
  void dispose() {
    _internalController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null && widget.label!.isNotEmpty)
          DarkInputLabel(widget.label!),
        Stack(
          alignment: Alignment.center,
          children: [
            TextField(
              controller: _effectiveController,
              readOnly: true,
              keyboardType: TextInputType.none,
              textInputAction: TextInputAction.none,
              onTap: widget.onTap,
              textAlign: widget.textAlign,
              style: DarkInputBox.inputStyle,
              decoration: DarkInputBox.decoration(
                hintText: widget.hint,
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
                  widget.icon,
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
