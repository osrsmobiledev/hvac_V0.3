// File: lib/core/widgets/scanner_torch_button.dart
// Responsibility: Tactical circular torch toggle button for camera viewfinders.

import 'package:flutter/material.dart';
import 'package:hvac_app/app/theme/app_colors.dart';

/// Tactical floating circular button to toggle the camera torch.
class ScannerTorchButton extends StatelessWidget {
  final bool isTorchOn;
  final VoidCallback onToggle;

  const ScannerTorchButton({
    super.key,
    required this.isTorchOn,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isTorchOn
          ? AppColors.amberGold.withValues(alpha: 0.25)
          : Colors.black.withValues(alpha: 0.65),
      shape: CircleBorder(
        side: BorderSide(
          color: isTorchOn
              ? AppColors.amberGold
              : Colors.white.withValues(alpha: 0.22),
          width: 1.0,
        ),
      ),
      child: IconButton(
        iconSize: 20,
        icon: Icon(
          isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
          color: isTorchOn ? AppColors.amberGold : AppColors.textSecondary,
        ),
        onPressed: onToggle,
      ),
    );
  }
}
