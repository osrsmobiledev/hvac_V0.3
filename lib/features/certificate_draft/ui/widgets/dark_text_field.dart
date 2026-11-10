import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'dark_input_box.dart';
import 'dark_input_label.dart';

/// Reusable dark text form field with integrated label, prefix, and suffix slots.
///
/// Features:
/// - Clean label above the box using [DarkInputLabel].
/// - Validates strictly with [validator] and [AutovalidateMode.onUserInteraction].
/// - Displays a crisp red border when invalid, with zero error text below and zero height jump.
/// - Keeps [FormFieldState] and [TextEditingController] in continuous sync so
///   programmatic text updates (QR scans, simulated values, clearing) immediately
///   update the validation border.
class DarkTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String? hintText;
  final Widget? prefixIcon;
  final String? prefixText;
  final Widget? suffixIcon;
  final String? suffixText;
  final String? unit;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool readOnly;
  final VoidCallback? onChanged;

  /// Optional validator for pre-flight Form validation.
  final String? Function(String?)? validator;

  const DarkTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hintText,
    this.prefixIcon,
    this.prefixText,
    this.suffixIcon,
    this.suffixText,
    this.unit,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.readOnly = false,
    this.onChanged,
    this.validator,
  });

  @override
  State<DarkTextField> createState() => _DarkTextFieldState();
}

class _DarkTextFieldState extends State<DarkTextField> {
  final GlobalKey<FormFieldState<String>> _fieldKey =
      GlobalKey<FormFieldState<String>>();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant DarkTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    final state = _fieldKey.currentState;
    if (!mounted || state == null || state.value == widget.controller.text) {
      return;
    }
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted &&
            _fieldKey.currentState?.value != widget.controller.text) {
          _fieldKey.currentState?.didChange(widget.controller.text);
        }
      });
    } else {
      state.didChange(widget.controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasExplicitSuffix =
        (widget.suffixText != null && widget.suffixText!.isNotEmpty) ||
            widget.suffixIcon != null;

    Widget? effectiveSuffixIcon;
    if (hasExplicitSuffix) {
      effectiveSuffixIcon = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.suffixText != null && widget.suffixText!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                widget.suffixText!,
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.antiqueGold,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          if (widget.suffixIcon != null) widget.suffixIcon!,
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        DarkInputLabel(widget.label, isMuted: widget.readOnly),
        TextFormField(
          key: _fieldKey,
          controller: widget.controller,
          readOnly: widget.readOnly,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: widget.readOnly
              ? DarkInputBox.inputStyle.copyWith(color: Colors.white60)
              : DarkInputBox.inputStyle,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          inputFormatters: [
            if (widget.unit != null && widget.unit!.isNotEmpty)
              UnitSuffixFormatter(widget.unit!),
          ],
          decoration: DarkInputBox.decoration(
            hintText: widget.hintText,
            prefixIcon: widget.prefixIcon,
            prefixText: widget.prefixText,
            suffixIcon: effectiveSuffixIcon,
            readOnly: widget.readOnly,
          ),
          onChanged: (_) => widget.onChanged?.call(),
          validator: widget.validator,
        ),
      ],
    );
  }
}

/// Standard input formatter that cleanly appends a unit suffix (e.g. ` %` or ` °C`)
/// directly inside the text, keeping the cursor right after the number.
class UnitSuffixFormatter extends TextInputFormatter {
  final String unit;

  const UnitSuffixFormatter(this.unit);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final rawText =
        newValue.text.replaceAll(' $unit', '').replaceAll(unit, '').trim();

    if (rawText.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final formatted = '$rawText $unit';
    final targetOffset = rawText.length.clamp(0, formatted.length);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: targetOffset),
    );
  }
}
