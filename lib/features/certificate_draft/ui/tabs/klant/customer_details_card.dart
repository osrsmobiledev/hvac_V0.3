import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/core/utils/belgian_formatters.dart';
import 'package:hvac_app/features/certificate_draft/ui/widgets/bento_main_section.dart';
import 'klant_form_controllers.dart';
import 'klant_form_field.dart';

/// Bento card presenting all primary customer contact and address fields.
///
/// Layout follows the preferred theme:
/// 1. Bedrijfsnaam / Klant (Optioneel) — Full width
/// 2. Voornaam & Achternaam — Balanced 2-column row (1:1)
/// 3. Straat — Full width address search input
/// 4. Nr & Bus — Balanced 2-column row (1:1)
/// 5. Postcode & Gemeente — Balanced 2-column row (1:1)
/// 6. Tel — Full width Belgian phone input with permanent +32 prefix
/// 7. Email — Full width email input
class CustomerDetailsCard extends StatelessWidget {
  final KlantFormControllers controllers;
  final VoidCallback onChanged;
  final bool readOnly;
  final Widget? actionButtons;

  const CustomerDetailsCard({
    super.key,
    required this.controllers,
    required this.onChanged,
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
                // 1. Bedrijfsnaam / Klant (Optioneel) — Full width
                KlantFormField(
                  fieldKey: const ValueKey('customer_company'),
                  controller: controllers.company,
                  label: AppDictionary.lblCompanyOrCustomerOptional,
                  hint: AppDictionary.hintCompany,
                  readOnly: readOnly,
                  onChanged: onChanged,
                ),
                const SizedBox(height: 12),

                // 2. Voornaam & Achternaam — 2-Column Row (1:1)
                Row(
                  children: [
                    Expanded(
                      child: KlantFormField(
                        fieldKey: const ValueKey('customer_firstName'),
                        controller: controllers.firstName,
                        label: AppDictionary.lblFirstName,
                        hint: AppDictionary.hintFirstName,
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
                        readOnly: readOnly,
                        onChanged: onChanged,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 3. Straat — Full width address input
                KlantFormField(
                  fieldKey: const ValueKey('customer_street'),
                  controller: controllers.street,
                  label: AppDictionary.lblStreet,
                  hint: AppDictionary.hintSearchAddress,
                  readOnly: readOnly,
                  onChanged: onChanged,
                ),
                const SizedBox(height: 12),

                // 4. Nr & Bus — 2-Column Row (1:1)
                Row(
                  children: [
                    Expanded(
                      child: KlantFormField(
                        fieldKey: const ValueKey('customer_houseNumber'),
                        controller: controllers.houseNumber,
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

                // 5. Postcode & Gemeente — 2-Column Row (1:1)
                Row(
                  children: [
                    Expanded(
                      child: KlantFormField(
                        fieldKey: const ValueKey('customer_postalCode'),
                        controller: controllers.postalCode,
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
                        fieldKey: const ValueKey('customer_city'),
                        controller: controllers.city,
                        label: AppDictionary.lblCity,
                        hint: AppDictionary.hintCity,
                        readOnly: readOnly,
                        onChanged: onChanged,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 6. Tel — Full width Belgian phone input
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

                // 7. Email — Full width email input
                KlantFormField(
                  fieldKey: const ValueKey('customer_email'),
                  controller: controllers.email,
                  label: AppDictionary.lblEmail,
                  hint: AppDictionary.hintEmail,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  readOnly: readOnly,
                  onChanged: onChanged,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
