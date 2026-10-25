import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';

/// Reusable tactical dialog button component matching the BO2 time picker style.
///
/// Provides two visual variants:
/// - [TacticalDialogButton.primary]: Filled capsule button (antique gold or error red).
/// - [TacticalDialogButton.secondary]: Outlined dark capsule button (#1E1E1E).
///
/// Both variants feature a 48px height, 24px pill radius, and tactile haptic click.
class TacticalDialogButton extends StatelessWidget {
  const TacticalDialogButton._({
    required this.label,
    required this.onPressed,
    required this.isPrimary,
    this.isDestructive = false,
  });

  /// Factory constructor for the primary affirmative action button (OK, Opslaan, Ja).
  const factory TacticalDialogButton.primary({
    required String label,
    required VoidCallback? onPressed,
    bool isDestructive,
  }) = _PrimaryTacticalDialogButton;

  /// Factory constructor for the secondary dismissal button (Annuleren, Nee).
  const factory TacticalDialogButton.secondary({
    required String label,
    required VoidCallback? onPressed,
  }) = _SecondaryTacticalDialogButton;

  /// The text displayed on the button.
  final String label;

  /// Triggered when the button is tapped. Triggers [HapticFeedback.selectionClick].
  final VoidCallback? onPressed;

  /// Whether this is a filled primary action or an outlined secondary action.
  final bool isPrimary;

  /// Whether the action is destructive (e.g., delete/clear), rendering in signal red.
  final bool isDestructive;

  void _handleTap() {
    HapticFeedback.selectionClick();
    onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (!isPrimary) {
      return OutlinedButton(
        onPressed: onPressed == null ? null : _handleTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          minimumSize: const Size.fromHeight(48),
          backgroundColor: const Color(0xFF1E1E1E),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.14),
            width: 1.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          foregroundColor: Colors.white70,
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            maxLines: 1,
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    if (isDestructive) {
      final errorColor = Theme.of(context).colorScheme.error;
      return OutlinedButton(
        onPressed: onPressed == null ? null : _handleTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          minimumSize: const Size.fromHeight(48),
          backgroundColor: const Color(0xFF1E1E1E),
          side: BorderSide(
            color: errorColor.withValues(alpha: 0.65),
            width: 1.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          foregroundColor: errorColor,
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            maxLines: 1,
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }

    return FilledButton(
      onPressed: onPressed == null ? null : _handleTap,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        minimumSize: const Size.fromHeight(48),
        backgroundColor: AppColors.antiqueGold,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          label,
          maxLines: 1,
          style: const TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _PrimaryTacticalDialogButton extends TacticalDialogButton {
  const _PrimaryTacticalDialogButton({
    required super.label,
    required super.onPressed,
    super.isDestructive = false,
  }) : super._(isPrimary: true);
}

class _SecondaryTacticalDialogButton extends TacticalDialogButton {
  const _SecondaryTacticalDialogButton({
    required super.label,
    required super.onPressed,
  }) : super._(isPrimary: false);
}

/// Symmetrical two-button or single-button row for the bottom of tactical dialogs.
class TacticalDialogActions extends StatelessWidget {
  const TacticalDialogActions({
    super.key,
    required this.cancelLabel,
    required this.confirmLabel,
    required this.onCancel,
    required this.onConfirm,
    this.isDestructive = false,
  });

  /// Factory for a single full-width dismissal button (e.g. Sluiten / OK).
  const TacticalDialogActions.single({
    super.key,
    required String label,
    required VoidCallback? onPressed,
  })  : cancelLabel = label,
        confirmLabel = '',
        onCancel = onPressed,
        onConfirm = null,
        isDestructive = false;

  final String cancelLabel;
  final String confirmLabel;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    if (confirmLabel.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: TacticalDialogButton.secondary(
          label: cancelLabel,
          onPressed: onCancel,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: TacticalDialogButton.secondary(
              label: cancelLabel,
              onPressed: onCancel,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TacticalDialogButton.primary(
              label: confirmLabel,
              isDestructive: isDestructive,
              onPressed: onConfirm,
            ),
          ),
        ],
      ),
    );
  }
}
