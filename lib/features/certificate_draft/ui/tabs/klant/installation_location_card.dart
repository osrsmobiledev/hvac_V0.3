import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/core/widgets/tactical_toggle_button.dart';
import 'package:hvac_app/features/certificate_draft/ui/widgets/bento_main_section.dart';
import 'effective_location_preview.dart';
import 'klant_form_controllers.dart';
import 'klant_form_field.dart';

/// Bento card presenting appliance installation location.
///
/// Features:
/// - Dropdown section titled 'Locatie Toestel'
/// - Theme-aligned Switch toggle for "Installatieadres is hetzelfde als klantadres":
///   * Disabled/greyed out unless a customer is selected or in edit mode (Nieuw / Bewerken).
///   * Amber-tinted glowing toggle matching BO2 Tactical HUD when active.
///   * Slate grey toggle when separate address is active.
/// - Dynamic 'Effectieve installatielocatie' preview tile showing active address & source badge.
/// - Collapsible separate address fields when installation address differs.
class InstallationLocationCard extends StatelessWidget {
  final KlantFormControllers controllers;
  final bool isSameAsCustomer;
  final ValueChanged<bool> onSameAddressChanged;
  final VoidCallback onChanged;
  final bool isEditing;
  final bool hasCustomer;
  final bool readOnly;

  const InstallationLocationCard({
    super.key,
    required this.controllers,
    required this.isSameAsCustomer,
    required this.onSameAddressChanged,
    required this.onChanged,
    this.isEditing = false,
    this.hasCustomer = false,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return BentoMainSection(
      title: AppDictionary.headerApplianceLocation,
      child: AbsorbPointer(
        absorbing: readOnly,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Reusable tactical toggle: Installatieadres is hetzelfde als klantadres
            TacticalToggleButton(
              label: AppDictionary.lblSameAsCustomerAddress,
              value: isSameAsCustomer,
              enabled: isEditing || hasCustomer,
              onChanged: isEditing ? onSameAddressChanged : null,
            ),
            const SizedBox(height: 12),

            // Effective Installation Location Preview Box
            EffectiveLocationPreview(
              controllers: controllers,
              isSameAsCustomer: isSameAsCustomer,
            ),

            // Collapsible separate address fields (when switch is OFF)
            if (!isSameAsCustomer) ...[
              const SizedBox(height: 14),

              // Straat (Installatie) — Full width
              KlantFormField(
                fieldKey: const ValueKey('loc_street'),
                controller: controllers.locStreet,
                label: AppDictionary.lblStreetInstallation,
                hint: AppDictionary.hintSearchAddress,
                readOnly: readOnly,
                onChanged: onChanged,
              ),
              const SizedBox(height: 12),

              // Nr & Bus — 2-Column Row (1:1)
              Row(
                children: [
                  Expanded(
                    child: KlantFormField(
                      fieldKey: const ValueKey('loc_houseNumber'),
                      controller: controllers.locHouseNumber,
                      label: AppDictionary.lblHouseNumber,
                      hint: AppDictionary.hintHouseNumber,
                      keyboardType: TextInputType.streetAddress,
                      readOnly: readOnly,
                      onChanged: onChanged,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: KlantFormField(
                      fieldKey: const ValueKey('loc_boxNumber'),
                      controller: controllers.locBoxNumber,
                      label: AppDictionary.lblBox,
                      hint: AppDictionary.hintBox,
                      readOnly: readOnly,
                      onChanged: onChanged,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Postcode & Gemeente — 2-Column Row (1:1)
              Row(
                children: [
                  Expanded(
                    child: KlantFormField(
                      fieldKey: const ValueKey('loc_postalCode'),
                      controller: controllers.locPostalCode,
                      label: AppDictionary.lblPostalCode,
                      hint: AppDictionary.hintPostalCode,
                      keyboardType: TextInputType.number,
                      readOnly: readOnly,
                      onChanged: onChanged,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: KlantFormField(
                      fieldKey: const ValueKey('loc_municipality'),
                      controller: controllers.locMunicipality,
                      label: AppDictionary.lblCity,
                      hint: AppDictionary.hintCity,
                      readOnly: readOnly,
                      onChanged: onChanged,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
