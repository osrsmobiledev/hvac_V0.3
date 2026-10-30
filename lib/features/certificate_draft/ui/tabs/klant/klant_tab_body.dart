import 'package:flutter/material.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/core/widgets/workflow_tab_container.dart';
import 'customer_details_card.dart';
import 'installation_location_card.dart';
import 'klant_action_buttons.dart';
import 'klant_form_controllers.dart';

/// Form body for Tab 4 (Klant & Installatieadres).
/// Wrapped in [WorkflowTabContainer] for responsive 600px max width and scroll persistence.
class KlantTabBody extends StatelessWidget {
  final bool isEditing;
  final bool hasCustomer;
  final bool isSameAsCustomer;
  final KlantFormControllers controllers;
  final VoidCallback onFormChanged;
  final ValueChanged<bool> onSameAddressChanged;
  final VoidCallback onSearch;
  final VoidCallback onNew;
  final VoidCallback onEdit;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final VoidCallback onDelete;

  const KlantTabBody({
    super.key,
    required this.isEditing,
    required this.hasCustomer,
    required this.isSameAsCustomer,
    required this.controllers,
    required this.onFormChanged,
    required this.onSameAddressChanged,
    required this.onSearch,
    required this.onNew,
    required this.onEdit,
    required this.onSave,
    required this.onCancel,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return WorkflowTabContainer(
      scrollKey: 'klant_tab_scroll',
      children: [
        CustomerDetailsCard(
          controllers: controllers,
          onChanged: onFormChanged,
          readOnly: !isEditing,
          actionButtons: KlantActionButtons(
            isEditing: isEditing,
            hasCustomer: hasCustomer,
            onSearch: onSearch,
            onNew: onNew,
            onEdit: onEdit,
            onSave: onSave,
            onCancel: onCancel,
            onDelete: onDelete,
          ),
        ),
        const SizedBox(height: AppTheme.bentoCardSpacing),
        InstallationLocationCard(
          controllers: controllers,
          isSameAsCustomer: isSameAsCustomer,
          onSameAddressChanged: onSameAddressChanged,
          onChanged: onFormChanged,
          isEditing: isEditing,
          hasCustomer: hasCustomer,
          readOnly: !isEditing,
        ),
      ],
    );
  }
}
