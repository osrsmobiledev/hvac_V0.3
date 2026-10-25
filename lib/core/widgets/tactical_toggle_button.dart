import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hvac_app/app/theme/app_colors.dart';

/// Reusable BO2 Tactical toggle switch & labeled row component.
///
/// Encapsulates:
/// - Official Flutter Material 3 [Switch] with "BO2 Tactical HUD" tokens:
///   * Active/ON: Amber gold thumb, dark amber-brown track, subtle gold glow outline.
///   * Inactive/OFF: Metallic slate grey thumb, dark graphite track, subtle outline.
///   * Disabled/Locked: Muted dark grey thumb, deep charcoal track, muted outline.
/// - Tactile haptic feedback on state change ([HapticFeedback.selectionClick]).
/// - Optional full-row layout with leading label and subtitle.
class TacticalToggleButton extends StatelessWidget {
  final String? label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool enabled;
  final EdgeInsetsGeometry padding;

  const TacticalToggleButton({
    super.key,
    this.label,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.padding = EdgeInsets.zero,
  });

  /// The raw tactile [Switch] without surrounding row layout.
  static Widget rawSwitch({
    required bool value,
    required ValueChanged<bool>? onChanged,
    bool enabled = true,
  }) {
    final effectiveOnChanged = enabled && onChanged != null
        ? (bool val) {
            HapticFeedback.selectionClick();
            onChanged(val);
          }
        : null;

    return Switch(
      value: value,
      onChanged: effectiveOnChanged,
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return const Color(0xFF4A4A4A);
        }
        if (states.contains(WidgetState.selected)) {
          return AppColors.amberGold;
        }
        return const Color(0xFF8E8E93);
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return const Color(0xFF161616);
        }
        if (states.contains(WidgetState.selected)) {
          return const Color(0xFF4A3600);
        }
        return const Color(0xFF1E1E1E);
      }),
      trackOutlineColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return const Color(0xFF2C2C2C);
        }
        if (states.contains(WidgetState.selected)) {
          return AppColors.amberGold.withValues(alpha: 0.4);
        }
        return const Color(0xFF383838);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveSwitch = rawSwitch(
      value: value,
      onChanged: onChanged,
      enabled: enabled,
    );

    if (label == null) {
      return Padding(padding: padding, child: effectiveSwitch);
    }

    final isInteractive = enabled && onChanged != null;

    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label!,
                  style: TextStyle(
                    fontSize: 14,
                    color: isInteractive ? Colors.white : AppColors.textMuted,
                    fontWeight:
                        isInteractive ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          effectiveSwitch,
        ],
      ),
    );
  }
}
