import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/core/widgets/tactical_confirm_dialog.dart';
import 'package:hvac_app/core/widgets/tactical_feedback.dart';

/// Semantic confirmation dialogs and feedback toasts for Klant tab actions.
///
/// Reuses the centralized [TacticalConfirmDialog] template and [TacticalFeedback]
/// to guarantee consistent BO2 Tactical styling, button placement, and proportions.
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

  /// Displays the sleek green floating feedback toast when customer is saved.
  static void showSavedFeedback(BuildContext context) {
    TacticalFeedback.showSuccess(
      context,
      AppDictionary.toastCustomerSaved,
    );
  }
}
