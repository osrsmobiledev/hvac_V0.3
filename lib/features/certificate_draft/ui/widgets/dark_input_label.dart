import 'package:flutter/material.dart';
import 'package:hvac_app/app/theme/app_colors.dart';

/// Centralized reusable label widget for input fields across all workflow tabs.
///
/// Features:
/// - Single source of truth for input box titles across the entire application.
/// - Unified typography: 13px, FontWeight.w600, crisp white text.
/// - Consistent 6px bottom spacing above the input container.
/// - Automatically dims color to [AppColors.textMuted] when [isMuted] is true.
class DarkInputLabel extends StatelessWidget {
  final String text;
  final bool isMuted;

  const DarkInputLabel(
    this.text, {
    super.key,
    this.isMuted = false,
  });

  /// The standard label text style used across all workflow forms.
  static TextStyle style({bool isMuted = false}) => TextStyle(
        color: isMuted ? AppColors.textMuted : Colors.white,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          maxLines: 1,
          style: style(isMuted: isMuted),
        ),
      ),
    );
  }
}
