import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'dark_input_box.dart';
import 'dark_input_label.dart';

/// Reusable dark form input field with zero-layout-shift red border validation.
///
/// Features:
/// - Clean label above the box using [DarkInputLabel].
/// - Validates strictly with [validator] and [autovalidateMode].
/// - Displays a crisp red border when invalid, with zero error text below and zero height jump.
/// - Keeps [FormFieldState] and [TextEditingController] in continuous sync so
///   autofill or programmatic text updates immediately clear/update validation state.
class DarkTextFormField extends StatefulWidget {
  final Key? fieldKey;
  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? prefixText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool readOnly;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;
  final AutovalidateMode autovalidateMode;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final TextCapitalization textCapitalization;
  final VoidCallback? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;

  const DarkTextFormField({
    super.key,
    this.fieldKey,
    required this.label,
    required this.controller,
    this.hint,
    this.prefixText,
    this.prefixIcon,
    this.suffixIcon,
    this.readOnly = false,
    this.inputFormatters,
    this.validator,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.textCapitalization = TextCapitalization.none,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
  });

  @override
  State<DarkTextFormField> createState() => _DarkTextFormFieldState();
}

class _DarkTextFormFieldState extends State<DarkTextFormField> {
  FormFieldState<String>? _fieldState;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant DarkTextFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
    }
    if (oldWidget.readOnly != widget.readOnly) {
      if (widget.readOnly && _fieldState?.hasError == true) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _fieldState?.reset();
        });
      }
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (!mounted ||
        _fieldState == null ||
        _fieldState!.value == widget.controller.text) {
      return;
    }
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted &&
            _fieldState != null &&
            _fieldState!.value != widget.controller.text) {
          _fieldState!.didChange(widget.controller.text);
        }
      });
    } else {
      _fieldState!.didChange(widget.controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        DarkInputLabel(widget.label, isMuted: widget.readOnly),
        FormField<String>(
          key: widget.fieldKey,
          initialValue: widget.controller.text,
          validator: widget.validator != null
              ? (_) => widget.validator!(widget.controller.text)
              : null,
          autovalidateMode: widget.autovalidateMode,
          builder: (FormFieldState<String> fieldState) {
            _fieldState = fieldState;
            final isError = fieldState.hasError;

            return TextField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              readOnly: widget.readOnly,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              textCapitalization: widget.textCapitalization,
              inputFormatters: widget.inputFormatters,
              onChanged: (value) {
                fieldState.didChange(value);
                widget.onChanged?.call();
              },
              onSubmitted: widget.onSubmitted,
              style: widget.readOnly
                  ? const TextStyle(
                      color: Color(0xFF9E9E9E),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    )
                  : DarkInputBox.inputStyle,
              cursorColor: widget.readOnly
                  ? Colors.transparent
                  : AppColors.amberGoldBorder,
              decoration: DarkInputBox.decoration(
                hintText: widget.hint,
                prefixText: widget.prefixText,
                prefixIcon: widget.prefixIcon,
                suffixIcon: widget.suffixIcon,
                readOnly: widget.readOnly,
                isError: isError,
              ),
            );
          },
        ),
      ],
    );
  }
}
