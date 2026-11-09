// File: lib/features/certificate_draft/ui/widgets/dark_action_field.dart
// Responsibility: Tactical reusable picker input field with centered text and trailing action icon.

import 'package:flutter/material.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'dark_input_box.dart';
import 'dark_input_label.dart';

/// Reusable dark action/picker field with centered text and trailing icon.
class DarkActionField extends StatefulWidget {
  final Key? fieldKey;
  final String? label;
  final TextEditingController? controller;
  final String? valueText;
  final String hint;
  final IconData icon;
  final VoidCallback onTap;
  final TextAlign textAlign;
  final FormFieldValidator<String>? validator;
  final AutovalidateMode autovalidateMode;
  final bool enabled;
  final bool showErrorText;

  const DarkActionField({
    super.key,
    this.fieldKey,
    this.label,
    this.controller,
    this.valueText,
    required this.hint,
    required this.icon,
    required this.onTap,
    this.textAlign = TextAlign.center,
    this.validator,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.enabled = true,
    this.showErrorText = true,
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
  void initState() {
    super.initState();
    _effectiveController.addListener(_onControllerTick);
  }

  void _onControllerTick() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant DarkActionField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller == null && oldWidget.valueText != widget.valueText) {
      _effectiveController.text = widget.valueText ?? '';
    }
  }

  @override
  void dispose() {
    _effectiveController.removeListener(_onControllerTick);
    _internalController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMuted = !widget.enabled;
    final iconColor = isMuted
        ? AppColors.amberGold.withValues(alpha: 0.25)
        : AppColors.amberGold;

    return FormField<String>(
      key: widget.fieldKey,
      validator: (_) => widget.validator?.call(_effectiveController.text),
      autovalidateMode: widget.autovalidateMode,
      builder: (FormFieldState<String> state) {
        final hasError = state.hasError;
        final restingColor = isMuted
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.22);
        final activeBorderColor = hasError ? AppColors.errorRed : restingColor;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.label != null && widget.label!.isNotEmpty)
              DarkInputLabel(widget.label!),
            Stack(
              children: [
                TextField(
                  controller: _effectiveController,
                  readOnly: true,
                  enabled: widget.enabled,
                  keyboardType: TextInputType.none,
                  textInputAction: TextInputAction.none,
                  onTap: widget.enabled
                      ? () {
                          widget.onTap();
                          state.didChange(_effectiveController.text);
                        }
                      : null,
                  textAlign: widget.textAlign,
                  style: isMuted
                      ? DarkInputBox.inputStyle.copyWith(color: Colors.white38)
                      : DarkInputBox.inputStyle,
                  decoration: DarkInputBox.decoration(
                    hintText: widget.hint,
                    readOnly: isMuted,
                  ).copyWith(
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: activeBorderColor,
                        width: 1.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: activeBorderColor,
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: hasError
                            ? AppColors.errorRed
                            : AppColors.amberGoldBorder,
                        width: 1.2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 36.0,
                      vertical: 12.0,
                    ),
                  ),
                ),
                Positioned(
                  top: 14,
                  right: 12,
                  child: IgnorePointer(
                    child: Icon(
                      widget.icon,
                      color: iconColor,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            if (widget.showErrorText && hasError)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 4),
                child: Text(
                  state.errorText ?? '',
                  style: const TextStyle(
                    color: AppColors.errorRed,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
