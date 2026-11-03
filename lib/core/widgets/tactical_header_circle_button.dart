// File: lib/core/widgets/tactical_header_circle_button.dart
// Responsibility: Circular tactical glass icon button designed for dialog headers.

import 'package:flutter/material.dart';

/// Circular tactical glass icon button designed for dialog headers.
class TacticalHeaderCircleButton extends StatelessWidget {
  const TacticalHeaderCircleButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final Widget icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.08),
      shape: CircleBorder(
        side: BorderSide(
          color: Colors.white.withValues(alpha: 0.15),
          width: 0.8,
        ),
      ),
      child: IconButton(
        iconSize: 18,
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.all(7),
        constraints: const BoxConstraints(),
        tooltip: tooltip,
        icon: icon,
        onPressed: onPressed,
      ),
    );
  }
}
