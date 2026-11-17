import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/core/utils/belgian_formatters.dart';
import 'package:hvac_app/features/certificate_draft/ui/widgets/bento_main_section.dart';
import 'address_search_icon.dart';
import 'effective_location_preview.dart';
import 'klant_form_controllers.dart';
import 'klant_form_field.dart';

/// Bento card for the appliance installation location.
///
/// UX flow (top-to-bottom):
/// • The toggle ("Afwijkend installatieadres") is controlled by the parent
///   via [onSameAddressChanged]. It has moved to [CustomerDetailsCard] as the
///   "Waar staat het toestel?" question — this card now only reacts to the
///   current [isSameAsCustomer] value.
///
/// Shared mode ([isSameAsCustomer] == true):
///   Shows [EffectiveLocationPreview] only. No input fields, no search button.
///   The technician has already looked up the address in Klantgegevens.
///
/// Separate mode ([isSameAsCustomer] == false):
///   Shows installation address fields with an inline 🔍 icon on Straat.
///   The [EffectiveLocationPreview] box renders **below** the fields so it
///   reads as the confirmed result of what was entered.
class InstallationLocationCard extends StatelessWidget {
  final KlantFormControllers controllers;
  final bool isSameAsCustomer;
  final ValueChanged<bool> onSameAddressChanged;
  final VoidCallback onChanged;
  final bool isEditing;
  final bool hasCustomer;
  final bool readOnly;

  /// Opens the Basisregisters lookup dialog pre-filled with installation
  /// address fields. Called only in separate mode.
  final VoidCallback? onInstallationLookupPressed;

  const InstallationLocationCard({
    super.key,
    required this.controllers,
    required this.isSameAsCustomer,
    required this.onSameAddressChanged,
    required this.onChanged,
    this.isEditing = false,
    this.hasCustomer = false,
    this.readOnly = false,
    this.onInstallationLookupPressed,
  });

  @override
  Widget build(BuildContext context) {
    return BentoMainSection(
      title: AppDictionary.headerApplianceLocation,
      child: isSameAsCustomer
          ? _SharedModeContent(controllers: controllers)
          : _SeparateModeContent(
              controllers: controllers,
              isEditing: isEditing,
              readOnly: readOnly,
              onChanged: onChanged,
              onLookupPressed: onInstallationLookupPressed,
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared mode — boiler is at the customer's address
// ---------------------------------------------------------------------------

/// Shows only the effective address preview. The address was already filled
/// and (optionally) verified in the Klantgegevens card above.
class _SharedModeContent extends StatelessWidget {
  final KlantFormControllers controllers;

  const _SharedModeContent({required this.controllers});

  @override
  Widget build(BuildContext context) {
    return EffectiveLocationPreview(
      controllers: controllers,
      isSameAsCustomer: true,
    );
  }
}

// ---------------------------------------------------------------------------
// Separate mode — boiler is at a different address
// ---------------------------------------------------------------------------

/// Shows installation address input fields (with inline 🔍 on Straat) then
/// the [EffectiveLocationPreview] below as the confirmed result.
class _SeparateModeContent extends StatelessWidget {
  final KlantFormControllers controllers;
  final bool isEditing;
  final bool readOnly;
  final VoidCallback onChanged;
  final VoidCallback? onLookupPressed;

  const _SeparateModeContent({
    required this.controllers,
    required this.isEditing,
    required this.readOnly,
    required this.onChanged,
    this.onLookupPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AbsorbPointer(
          absorbing: readOnly,
          child: Column(
            children: [
              // Straat (Installatie) — full width with inline 🔍 icon
              KlantFormField(
                fieldKey: const ValueKey('loc_street'),
                controller: controllers.locStreet,
                label: AppDictionary.lblStreetInstallation,
                hint: AppDictionary.hintSearchAddress,
                validator: (v) =>
                    v!.trim().isEmpty ? 'Installatiestraat is verplicht' : null,
                readOnly: readOnly,
                onChanged: onChanged,
                suffixIcon: (isEditing && !readOnly && onLookupPressed != null)
                    ? AddressSearchIcon(
                        tooltip: BasisregistersDictionary
                            .tooltipLookupInstallationAddress,
                        onPressed: onLookupPressed!,
                      )
                    : null,
              ),
              const SizedBox(height: 12),

              // Nr & Bus — 2-column row
              Row(
                children: [
                  Expanded(
                    child: KlantFormField(
                      fieldKey: const ValueKey('loc_houseNumber'),
                      controller: controllers.locHouseNumber,
                      label: AppDictionary.lblHouseNumber,
                      hint: AppDictionary.hintHouseNumber,
                      validator: (v) =>
                          v!.trim().isEmpty ? 'Huisnummer is verplicht' : null,
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

              // Postcode & Gemeente — 2-column row
              Row(
                children: [
                  Expanded(
                    child: KlantFormField(
                      fieldKey: const ValueKey('loc_postalCode'),
                      controller: controllers.locPostalCode,
                      label: AppDictionary.lblPostalCode,
                      hint: AppDictionary.hintPostalCode,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      validator: BelgianFormatters.validatePostalCode,
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
                      validator: (v) =>
                          v!.trim().isEmpty ? 'Gemeente is verplicht' : null,
                      readOnly: readOnly,
                      onChanged: onChanged,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Preview below fields — reads as the confirmed result of what was entered.
        EffectiveLocationPreview(
          controllers: controllers,
          isSameAsCustomer: false,
        ),
      ],
    );
  }
}
