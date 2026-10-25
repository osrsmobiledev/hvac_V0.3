import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/core/widgets/tactical_confirm_dialog.dart';

/// Semantic confirmation dialogs and feedback toasts for Klant tab actions.
///
/// Reuses the centralized [TacticalConfirmDialog] template to guarantee
/// consistent BO2 Tactical styling, button placement, and proportions.
abstract final class KlantActionDialogs {
  /// Prompts the user before creating a fresh customer entry.
  static Future<bool> confirmNewCustomer(BuildContext context) async {
    return await TacticalConfirmDialog.show(
          context: context,
          title: AppDictionary.dlgNewCustomerTitle,
          content: AppDictionary.dlgNewCustomerContent,
          confirmLabel: AppDictionary.dlgYes,
          cancelLabel: AppDictionary.dlgNo,
          isDestructive: false,
        ) ??
        false;
  }

  /// Prompts the user before entering edit mode on an existing customer.
  static Future<bool> confirmEditCustomer(BuildContext context) async {
    return await TacticalConfirmDialog.show(
          context: context,
          title: AppDictionary.dlgEditCustomerTitle,
          content: AppDictionary.dlgEditCustomerContent,
          confirmLabel: AppDictionary.dlgYes,
          cancelLabel: AppDictionary.dlgNo,
          isDestructive: false,
        ) ??
        false;
  }

  /// Prompts the user before reverting uncommitted customer edits.
  static Future<bool> confirmCancelEdit(BuildContext context) async {
    return await TacticalConfirmDialog.show(
          context: context,
          title: AppDictionary.dlgCancelEditTitle,
          content: AppDictionary.dlgCancelEditContent,
          confirmLabel: AppDictionary.dlgYes,
          cancelLabel: AppDictionary.dlgNo,
          isDestructive: false,
        ) ??
        false;
  }

  /// Prompts the user before unlinking/clearing customer data from the draft.
  static Future<bool> confirmDeleteCustomer(BuildContext context) async {
    return await TacticalConfirmDialog.show(
          context: context,
          title: AppDictionary.dlgDeleteCustomerTitle,
          content: AppDictionary.dlgDeleteCustomerContent,
          confirmLabel: AppDictionary.dlgDeleteConfirm,
          cancelLabel: AppDictionary.btnCancel,
          isDestructive: true,
        ) ??
        false;
  }

  /// Displays the sleek green floating feedback snackbar when customer is saved.
  static void showSavedFeedback(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF141E18),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: AppColors.successGreen.withValues(alpha: 0.6),
            width: 1.2,
          ),
        ),
        content: const Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: AppColors.successGreen,
              size: 22,
            ),
            SizedBox(width: 12),
            Text(
              AppDictionary.toastCustomerSaved,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 2200),
      ),
    );
  }
}
