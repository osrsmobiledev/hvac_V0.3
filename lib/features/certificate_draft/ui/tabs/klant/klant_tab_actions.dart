import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/basisregisters_dictionary.dart';
import 'package:hvac_app/features/customers_installations/domain/customer.dart';
import 'package:hvac_app/features/customers_installations/domain/service_location.dart';
import 'customer_search_modal.dart';
import 'klant_action_dialogs.dart';
import 'klant_data_coordinator.dart';

/// Handles user actions (search, new, edit, cancel, delete) on the Klant tab.
abstract final class KlantTabActions {
  /// Opens customer search modal and links the selected customer.
  static Future<void> handleSearch({
    required BuildContext context,
    required KlantDataCoordinator coordinator,
    required int? draftVisitId,
    required Customer? activeCustomer,
    required VoidCallback onClear,
    required void Function(Customer customer, ServiceLocation? location)
        onSelected,
  }) async {
    final picked = await CustomerSearchModal.show(
      context,
      repository: coordinator.customerRepo,
      onCustomerDeleted: (deletedId) {
        if (activeCustomer?.id == deletedId) onClear();
      },
    );
    if (picked == null || !context.mounted) return;

    ServiceLocation? location;
    try {
      location = await coordinator.linkPickedCustomer(
        draftId: draftVisitId,
        customer: picked,
      );
    } catch (e, stack) {
      debugPrint('[KlantTabActions] linkPickedCustomer error: $e\n$stack');
      if (context.mounted) {
        KlantActionDialogs.showErrorFeedback(
          context,
          BasisregistersDictionary.toastSaveFailed,
        );
      }
      return;
    }
    if (context.mounted) {
      onSelected(picked, location);
    }
  }

  /// Prompts confirmation for creating a new customer.
  static Future<bool> confirmNew(BuildContext context) =>
      KlantActionDialogs.confirmNewCustomer(context);

  /// Prompts confirmation for editing existing customer details.
  static Future<bool> confirmEdit(BuildContext context) =>
      KlantActionDialogs.confirmEditCustomer(context);

  /// Validates form and persists changes, displaying feedback on success.
  static Future<void> handleSave({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required Future<bool> Function() saveCallback,
    required VoidCallback onSaved,
  }) async {
    if (!(formKey.currentState?.validate() ?? true)) return;
    final success = await saveCallback();
    if (!context.mounted) return;
    if (success) {
      onSaved();
      KlantActionDialogs.showSavedFeedback(context);
    } else {
      KlantActionDialogs.showErrorFeedback(
        context,
        BasisregistersDictionary.toastSaveFailed,
      );
    }
  }

  /// Prompts confirmation for cancelling edits and rolling back.
  static Future<void> handleCancel({
    required BuildContext context,
    required Future<bool> Function() onCancel,
  }) async {
    if (!await KlantActionDialogs.confirmCancelEdit(context) ||
        !context.mounted) {
      return;
    }
    final success = await onCancel();
    if (!context.mounted) return;
    if (!success) {
      KlantActionDialogs.showErrorFeedback(
        context,
        BasisregistersDictionary.toastRollbackFailed,
      );
    }
  }

  /// Prompts confirmation for unlinking/clearing customer.
  static Future<void> handleDelete({
    required BuildContext context,
    required Future<void> Function() onDelete,
  }) async {
    if (!await KlantActionDialogs.confirmDeleteCustomer(context) ||
        !context.mounted) {
      return;
    }
    await onDelete();
  }
}
