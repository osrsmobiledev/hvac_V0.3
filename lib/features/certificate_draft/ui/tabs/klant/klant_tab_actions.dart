import 'package:flutter/material.dart';
import 'customer_search_modal.dart';
import 'klant_action_dialogs.dart';
import 'klant_data_coordinator.dart';
import 'klant_form_controllers.dart';
import '../../../../customers_installations/domain/customer.dart';
import '../../../../customers_installations/domain/service_location.dart';

/// Handles user actions (search, new, edit, cancel, delete) on the Klant tab.
abstract final class KlantTabActions {
  /// Opens customer search modal and links the selected customer.
  static Future<void> handleSearch({
    required BuildContext context,
    required KlantDataCoordinator coordinator,
    required KlantFormControllers controllers,
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
    controllers.populateCustomer(picked);

    ServiceLocation? location;
    try {
      location = await coordinator.linkPickedCustomer(
        draftId: draftVisitId,
        customer: picked,
      );
    } catch (e, stack) {
      debugPrint('[KlantTabActions] linkPickedCustomer error: $e\n$stack');
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
    required Future<void> Function() saveCallback,
    required VoidCallback onSaved,
  }) async {
    if (!(formKey.currentState?.validate() ?? true)) return;
    await saveCallback();
    if (!context.mounted) return;
    onSaved();
    KlantActionDialogs.showSavedFeedback(context);
  }

  /// Prompts confirmation for cancelling edits and rolling back.
  static Future<void> handleCancel({
    required BuildContext context,
    required VoidCallback onCancel,
  }) async {
    if (!await KlantActionDialogs.confirmCancelEdit(context) ||
        !context.mounted) {
      return;
    }
    onCancel();
  }

  /// Prompts confirmation for unlinking/clearing customer.
  static Future<void> handleDelete({
    required BuildContext context,
    required VoidCallback onDelete,
  }) async {
    if (!await KlantActionDialogs.confirmDeleteCustomer(context) ||
        !context.mounted) {
      return;
    }
    onDelete();
  }
}
