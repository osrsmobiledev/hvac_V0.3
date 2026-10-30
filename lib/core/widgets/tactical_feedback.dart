import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';

/// Centralized utility for tactical dark floating feedback toasts (SnackBars).
///
/// Features:
/// - Replaces ad-hoc, inconsistent snackbar boilerplate across all workflow tabs.
/// - Dark tactical theme with glowing colored borders matching BO2 visual style.
/// - Built-in haptic feedback triggers (light for success, heavy for error).
abstract final class TacticalFeedback {
  /// Displays a tactical floating green success toast.
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(milliseconds: 2200),
  }) {
    HapticFeedback.lightImpact();
    _showFloatingToast(
      context: context,
      message: message,
      icon: Icons.check_circle_rounded,
      iconColor: AppColors.successGreen,
      backgroundColor: const Color(0xFF141E18),
      borderColor: AppColors.successGreen.withValues(alpha: 0.6),
      duration: duration,
    );
  }

  /// Displays a tactical floating amber/gold information toast.
  static void showInfo(
    BuildContext context,
    String message, {
    IconData icon = Icons.info_outline_rounded,
    Duration duration = const Duration(seconds: 2),
  }) {
    HapticFeedback.selectionClick();
    _showFloatingToast(
      context: context,
      message: message,
      icon: icon,
      iconColor: AppColors.amberGold,
      backgroundColor: const Color(0xFF1A1710),
      borderColor: AppColors.amberGold.withValues(alpha: 0.6),
      duration: duration,
    );
  }

  /// Displays a tactical floating terracotta/red error toast.
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(milliseconds: 2600),
  }) {
    HapticFeedback.heavyImpact();
    _showFloatingToast(
      context: context,
      message: message,
      icon: Icons.error_outline_rounded,
      iconColor: AppColors.errorRed,
      backgroundColor: const Color(0xFF1E1414),
      borderColor: AppColors.errorRed.withValues(alpha: 0.6),
      duration: duration,
    );
  }

  static void _showFloatingToast({
    required BuildContext context,
    required String message,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required Color borderColor,
    required Duration duration,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borderColor, width: 1.2),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        content: Row(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  color: Colors.white,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
