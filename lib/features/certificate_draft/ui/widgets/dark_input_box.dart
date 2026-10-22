import 'package:flutter/material.dart';
import 'package:hvac_app/app/theme/app_colors.dart';

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

  /// Factory helper for creating standard tactical [InputDecoration]
  /// with dark #0C0C0C fill, white/grey resting border, and gold focused border.
  static InputDecoration decoration({String? hintText}) {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFF0C0C0C),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 14.0,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: 0.22),
          width: 1.0,
        ),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(
          color: AppColors.amberGold,
          width: 1.4,
        ),
      ),
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Colors.white38,
        fontSize: 15,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label above the container
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 6),
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
