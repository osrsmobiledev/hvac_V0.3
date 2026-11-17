import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/core/utils/belgian_formatters.dart';
import 'package:hvac_app/features/certificate_draft/ui/widgets/bento_main_section.dart';
import 'address_search_icon.dart';
import 'klant_form_controllers.dart';
import 'klant_form_field.dart';
import 'waar_toestel_toggle.dart';

/// Bento card presenting all primary customer contact and address fields.
///
/// Layout (top-to-bottom):
/// 1. Action buttons (Bewerken / Opslaan / Annuleren …)
/// 2. Bedrijfsnaam / Klant (Optioneel) — full width
/// 3. Voornaam & Achternaam — 2-column row
/// 4. Tel — full width Belgian phone with +32 prefix
/// 5. Email — full width
/// 6. "Waar staat het toestel?" toggle (edit mode only) — BEFORE address
/// 7. Straat — full width with 🔍 search icon (edit mode)
/// 8. Nr & Bus — 2-column row
/// 9. Postcode & Gemeente — 2-column row
class CustomerDetailsCard extends StatelessWidget {
  final KlantFormControllers controllers;
  final VoidCallback onChanged;
  final bool readOnly;

  /// Whether the boiler is at the same address as the customer.
  /// Controls the toggle and which lookup fills which fields.
  final bool isSameAsCustomer;

  /// Callback when the technician flips the "Waar staat het toestel?" choice.
  final ValueChanged<bool> onSameAddressChanged;

  /// Opens the Basisregisters lookup dialog for the customer address.
  final VoidCallback onCustomerLookupPressed;

  final Widget? actionButtons;

  const CustomerDetailsCard({
    super.key,
    required this.controllers,
    required this.onChanged,
    required this.isSameAsCustomer,
    required this.onSameAddressChanged,
    required this.onCustomerLookupPressed,
    this.readOnly = false,
    this.actionButtons,
  });

  @override
  Widget build(BuildContext context) {
    return BentoMainSection(
      title: AppDictionary.headerCustomerDetails,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (actionButtons != null) ...[
            actionButtons!,
            const SizedBox(height: 12),
            const Divider(color: Colors.white10, height: 1),
            const SizedBox(height: 14),
          ],
          AbsorbPointer(
            absorbing: readOnly,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Bedrijfsnaam / Klant (Optioneel) — full width
                KlantFormField(
                  fieldKey: const ValueKey('customer_company'),
                  controller: controllers.company,
                  label: AppDictionary.lblCompanyOrCustomerOptional,
                  hint: AppDictionary.hintCompany,
                  readOnly: readOnly,
                  onChanged: onChanged,
                ),
                const SizedBox(height: 12),

                // 2. Voornaam & Achternaam — 2-column row
                Row(
                  children: [
                    Expanded(
                      child: KlantFormField(
                        fieldKey: const ValueKey('customer_firstName'),
                        controller: controllers.firstName,
                        label: AppDictionary.lblFirstName,
                        hint: AppDictionary.hintFirstName,
                        validator: (v) =>
                            v!.trim().isEmpty ? 'Voornaam is verplicht' : null,
                        readOnly: readOnly,
                        onChanged: onChanged,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: KlantFormField(
                        fieldKey: const ValueKey('customer_lastName'),
                        controller: controllers.lastName,
                        label: AppDictionary.lblLastName,
                        hint: AppDictionary.hintLastName,
                        validator: (v) => v!.trim().isEmpty
                            ? 'Achternaam is verplicht'
                            : null,
                        readOnly: readOnly,
                        onChanged: onChanged,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 3. Tel — full width Belgian phone with permanent +32 prefix
                KlantFormField(
                  fieldKey: const ValueKey('customer_phone'),
                  controller: controllers.phone,
                  label: AppDictionary.lblPhone,
                  hint: AppDictionary.hintPhone,
                  prefixText: BelgianFormatters.phonePrefix,
                  inputFormatters: BelgianFormatters.phoneFormatters,
                  validator: BelgianFormatters.validatePhone,
                  keyboardType: TextInputType.phone,
                  readOnly: readOnly,
                  onChanged: onChanged,
                ),
                const SizedBox(height: 12),

                // 4. Email — full width (optional, validates format when filled)
                KlantFormField(
                  fieldKey: const ValueKey('customer_email'),
                  controller: controllers.email,
                  label: AppDictionary.lblEmail,
                  hint: AppDictionary.hintEmail,
                  keyboardType: TextInputType.emailAddress,
                  validator: BelgianFormatters.validateEmail,
                  readOnly: readOnly,
                  onChanged: onChanged,
                ),
                const SizedBox(height: 16),

                // 5. "Waar staat het toestel?" toggle — only visible in edit mode
                if (!readOnly) ...[
                  WaarToestelToggle(
                    isSameAsCustomer: isSameAsCustomer,
                    onChanged: onSameAddressChanged,
                  ),
                  const SizedBox(height: 14),
                ],

                // 6. Straat — full width with inline 🔍 icon (edit mode)
                KlantFormField(
                  fieldKey: const ValueKey('customer_street'),
                  controller: controllers.street,
                  label: AppDictionary.lblStreet,
                  hint: AppDictionary.hintSearchAddress,
                  validator: (v) =>
                      v!.trim().isEmpty ? 'Straat is verplicht' : null,
                  readOnly: readOnly,
                  onChanged: onChanged,
                  suffixIcon: readOnly
                      ? null
                      : AddressSearchIcon(
                          tooltip: BasisregistersDictionary
                              .tooltipLookupCustomerAddress,
                          onPressed: onCustomerLookupPressed,
                        ),
                ),
                const SizedBox(height: 12),

                // 7. Nr & Bus — 2-column row
                Row(
                  children: [
                    Expanded(
                      child: KlantFormField(
                        fieldKey: const ValueKey('customer_houseNumber'),
                        controller: controllers.houseNumber,
                        label: AppDictionary.lblHouseNumber,
                        hint: AppDictionary.hintHouseNumber,
                        validator: (v) => v!.trim().isEmpty
                            ? 'Huisnummer is verplicht'
                            : null,
                        keyboardType: TextInputType.streetAddress,
                        readOnly: readOnly,
                        onChanged: onChanged,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: KlantFormField(
                        fieldKey: const ValueKey('customer_boxNumber'),
                        controller: controllers.boxNumber,
                        label: AppDictionary.lblBox,
                        hint: AppDictionary.hintBox,
                        readOnly: readOnly,
                        onChanged: onChanged,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 8. Postcode & Gemeente — 2-column row
                Row(
                  children: [
                    Expanded(
                      child: KlantFormField(
                        fieldKey: const ValueKey('customer_postalCode'),
                        controller: controllers.postalCode,
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
                        fieldKey: const ValueKey('customer_city'),
                        controller: controllers.city,
                        label: AppDictionary.lblCity,
                        hint: AppDictionary.hintCity,
                        validator: (v) =>
                            v!.trim().isEmpty ? 'Gemeente is verplicht' : null,
                        textInputAction: TextInputAction.done,
                        readOnly: readOnly,
                        onChanged: onChanged,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
