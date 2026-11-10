// File: lib/core/widgets/tactical_group_outline.dart
// Responsibility: Centralized reusable tactical group outline for single/multi-choice button sets.

import 'package:flutter/material.dart';
import 'package:hvac_app/app/theme/app_colors.dart';

/// Reusable outer outline container for button groups or binary checks
/// that require a unified zero-jump error outline (e.g. Tab 'Start' activity
/// buttons [ActivityOptionTile], Tab 'Meting' binary checks [TacticalBinaryCheck]).
///
/// Features:
/// - Zero layout shift: Always reserves border space ([borderWidth]) so toggling
///   [hasError] between true/false never causes neighboring content to shift.
/// - Outlines the entire group of choices as a single unified container instead
///   of individual fragmented button borders.
class TacticalGroupOutline extends StatelessWidget {
  final Widget child;
  final bool hasError;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final double borderWidth;
  final Color errorColor;

  const TacticalGroupOutline({
    super.key,
    required this.child,
    required this.hasError,
    this.borderRadius = 8.0,
    this.padding = const EdgeInsets.all(2.0),
    this.borderWidth = 1.2,
    this.errorColor = AppColors.errorRed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: hasError ? errorColor : Colors.transparent,
          width: borderWidth,
        ),
      ),
      child: child,
    );
  }
}
