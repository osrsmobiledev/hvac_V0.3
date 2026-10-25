import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'tactical_dialog_button.dart';
import 'tactical_dialog_window.dart';

/// Centralized confirmation dialog combining [TacticalDialogWindow] and [TacticalDialogActions].
///
/// Shares the exact visual architecture as the BO2 Time Picker modal:
/// - Dark charcoal glass surface with 24px border radius.
/// - Top title with signature glowing HUD laser divider.
/// - Centered message text with comfortable line height.
/// - Symmetrical two-button bottom row with tactile haptic feedback.
class TacticalConfirmDialog extends StatelessWidget {
  const TacticalConfirmDialog({
    super.key,
    required this.title,
    required this.content,
    this.confirmLabel = AppDictionary.dlgYes,
    this.cancelLabel = AppDictionary.dlgNo,
    this.isDestructive = false,
    this.onConfirm,
    this.onCancel,
  });

  /// Dialog header title.
  final String title;

  /// Explanatory message for the user.
  final String content;

  /// Label for affirmative action (e.g. "Ja", "Ja, Wissen", "OK").
  final String confirmLabel;

  /// Label for dismissal action (e.g. "Nee", "Annuleren").
  final String cancelLabel;

  /// Whether this dialog confirms a destructive action (turns accent red).
  final bool isDestructive;

  /// Callback when confirm is pressed.
  final VoidCallback? onConfirm;

  /// Callback when cancel is pressed.
  final VoidCallback? onCancel;

  /// Displays the tactical confirmation dialog and returns `true` if confirmed, `false` otherwise.
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String content,
    String confirmLabel = AppDictionary.dlgYes,
    String cancelLabel = AppDictionary.dlgNo,
    bool isDestructive = false,
  }) {
    return showTacticalDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => TacticalConfirmDialog(
        title: title,
        content: content,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
        onConfirm: () => Navigator.of(ctx).pop(true),
        onCancel: () => Navigator.of(ctx).pop(false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TacticalDialogWindow(
      title: title,
      maxWidth: 360.0,
      isDestructive: isDestructive,
      actions: TacticalDialogActions(
        cancelLabel: cancelLabel,
        confirmLabel: confirmLabel,
        isDestructive: isDestructive,
        onCancel: onCancel,
        onConfirm: onConfirm,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 6),
        child: Text(
          content,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: AppTheme.fontFamily,
            color: AppColors.textSecondary,
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
