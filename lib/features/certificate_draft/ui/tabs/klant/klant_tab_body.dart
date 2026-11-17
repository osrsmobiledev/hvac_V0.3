import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hvac_app/core/services/basisregisters_service.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/core/widgets/workflow_tab_container.dart';
import 'package:hvac_app/features/certificate_draft/data/basisregisters_models.dart';
import 'address_lookup_dialog.dart';
import 'customer_details_card.dart';
import 'installation_location_card.dart';
import 'klant_action_buttons.dart';
import 'klant_form_controllers.dart';
import 'klant_tab_state_data.dart';

/// Form body for Tab 4 (Klant & Installatieadres).
/// Wrapped in [WorkflowTabContainer] for responsive 600px max width and scroll persistence.
///
/// Hosts all lookup dialog logic so the card widgets stay stateless and simple.
class KlantTabBody extends StatelessWidget {
  final bool isEditing;
  final bool hasCustomer;
  final bool isSameAsCustomer;
  final KlantFormControllers controllers;
  final VoidCallback onFormChanged;
  final void Function(AddressLookupTarget, AddressMatch) onLookupSelected;
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
    required this.onLookupSelected,
    required this.onSameAddressChanged,
    required this.onSearch,
    required this.onNew,
    required this.onEdit,
    required this.onSave,
    required this.onCancel,
    required this.onDelete,
  });

  Future<void> _openLookup(BuildContext context,
      {required bool customer}) async {
    final target = customer
        ? isSameAsCustomer
            ? AddressLookupTarget.shared
            : AddressLookupTarget.billing
        : AddressLookupTarget.installation;
    HapticFeedback.selectionClick();
    final match = await showDialog<AddressMatch>(
      context: context,
      builder: (_) => AddressLookupDialog(
        dialogTitle: customer
            ? BasisregistersDictionary.lookupDialogTitleCustomer
            : BasisregistersDictionary.lookupDialogTitleInstallation,
        initialStreet:
            (customer ? controllers.street : controllers.locStreet).text,
        initialHouseNumber:
            (customer ? controllers.houseNumber : controllers.locHouseNumber)
                .text,
        initialPostcode:
            (customer ? controllers.postalCode : controllers.locPostalCode)
                .text,
        initialMunicipality:
            (customer ? controllers.city : controllers.locMunicipality).text,
        initialBus:
            (customer ? controllers.boxNumber : controllers.locBoxNumber).text,
        search: BasisregistersService.searchCandidates,
        verifyInstallation: target == AddressLookupTarget.billing
            ? null
            : BasisregistersService.enrichMatch,
      ),
    );
    if (context.mounted && match != null) onLookupSelected(target, match);
  }

  @override
  Widget build(BuildContext context) {
    return WorkflowTabContainer(
      scrollKey: 'klant_tab_scroll',
      children: [
        CustomerDetailsCard(
          controllers: controllers,
          onChanged: onFormChanged,
          readOnly: !isEditing,
          isSameAsCustomer: isSameAsCustomer,
          onSameAddressChanged: onSameAddressChanged,
          onCustomerLookupPressed: () => _openLookup(context, customer: true),
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
          onInstallationLookupPressed:
              isEditing ? () => _openLookup(context, customer: false) : null,
        ),
      ],
    );
  }
}
