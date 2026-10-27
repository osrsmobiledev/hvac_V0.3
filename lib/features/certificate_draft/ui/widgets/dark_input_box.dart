import 'package:flutter/material.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'dark_input_label.dart';
import 'dark_input_prefix.dart';

/// Reusable dark box layout matching the flue gas parameter boxes on Tab 1 (Data).
///
/// Features:
/// - Crisp white label text positioned above the box.
/// - Deep dark container surface (#0C0C0C) with 12px squircle radius.
/// - White/grey tinted border outline (Colors.white with alpha 0.22).
/// - Standard 50px height with horizontally-padded inner content slot.
/// - Provides [decoration] for native [TextField] widgets to guarantee
///   perfect vertical text alignment and amber-gold focus highlighting.
class DarkInputBox extends StatelessWidget {
  final String label;
  final Widget child;
  final double height;
  final Color? borderColor;
  final EdgeInsetsGeometry padding;

  const DarkInputBox({
    super.key,
    required this.label,
    required this.child,
    this.height = 50.0,
    this.borderColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
  });

  /// Single source of truth for user-entered input text style across all form fields.
  static const TextStyle inputStyle = TextStyle(
    color: Colors.white,
    fontSize: 15,
    fontWeight: FontWeight.w500,
  );

  /// Factory helper for creating standard tactical [InputDecoration]
  /// with dark #0C0C0C fill, white/grey resting border, and gold focused border.
  /// When [readOnly] is true, renders in a recessed, greyed-out protected state.
  static InputDecoration decoration({
    String? hintText,
    String? prefixText,
    TextStyle? prefixStyle,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool readOnly = false,
    EdgeInsetsGeometry? contentPadding,
    double? fontSize,
  }) {
    final effectivePrefix = prefixText != null
        ? DarkInputPrefix.text(prefixText, isMuted: readOnly)
        : prefixIcon != null
            ? Padding(
                padding: const EdgeInsets.only(left: 14.0, right: 10.0),
                child: prefixIcon,
              )
            : null;

    final restingBorderColor = readOnly
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.22);

    return InputDecoration(
      filled: true,
      fillColor: readOnly ? const Color(0xFF090909) : const Color(0xFF0C0C0C),
      prefixIcon: effectivePrefix,
      prefixIconConstraints: effectivePrefix != null
          ? const BoxConstraints(minWidth: 0, minHeight: 0)
          : null,
      suffixIcon: suffixIcon,
      contentPadding: contentPadding ??
          EdgeInsets.only(
            left: prefixText != null ? 4.0 : 14.0,
            right: 10.0,
            top: 12.0,
            bottom: 12.0,
          ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: restingBorderColor,
          width: 1.0,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: restingBorderColor,
          width: 1.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(
          color: readOnly ? restingBorderColor : AppColors.amberGoldBorder,
          width: readOnly ? 1.0 : 1.2,
        ),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(
          color: AppColors.errorRed,
          width: 1.0,
        ),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(
          color: AppColors.errorRed,
          width: 1.4,
        ),
      ),
      errorStyle: const TextStyle(
        color: AppColors.errorRed,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      hintText: hintText,
      hintStyle: TextStyle(
        color: readOnly ? Colors.white24 : Colors.white38,
        fontSize: fontSize ?? 15,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Centralized reusable label above the container
        DarkInputLabel(label),
        // Deep dark box with white/grey tinted border
        Container(
          height: height,
          width: double.infinity,
          alignment: Alignment.centerLeft,
          padding: padding,
          decoration: BoxDecoration(
            color: const Color(0xFF0C0C0C),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor ?? Colors.white.withValues(alpha: 0.22),
              width: 1.0,
            ),
          ),
          child: child,
        ),
      ],
    );
  }
}
