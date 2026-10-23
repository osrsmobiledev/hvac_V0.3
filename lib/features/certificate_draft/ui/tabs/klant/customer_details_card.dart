import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/core/utils/belgian_formatters.dart';
import 'package:hvac_app/features/certificate_draft/ui/widgets/bento_main_section.dart';
import 'klant_form_controllers.dart';
import 'klant_form_field.dart';

/// Bento card presenting all primary customer contact and billing fields.
class CustomerDetailsCard extends StatelessWidget {
  final KlantFormControllers controllers;
  final VoidCallback onChooseCustomer;
  final VoidCallback onNewCustomer;
  final VoidCallback onChanged;

  const CustomerDetailsCard({
    super.key,
    required this.controllers,
    required this.onChooseCustomer,
    required this.onNewCustomer,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BentoMainSection(
      title: AppDictionary.headerCustomerDetails,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Action button row
          Row(
            children: [
              Expanded(
                flex: 3,
                child: _buildActionBtn(
                  label: AppDictionary.btnChooseCustomer,
                  icon: Icons.person_search_rounded,
                  isGold: true,
                  onTap: onChooseCustomer,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: _buildActionBtn(
                  label: AppDictionary.btnNewCustomer,
                  icon: Icons.person_add_alt_1_rounded,
                  isGold: false,
                  onTap: onNewCustomer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Company Name
          KlantFormField(
            fieldKey: const ValueKey('customer_company'),
            controller: controllers.company,
            label: 'Bedrijfsnaam (optioneel)',
            hint: 'bv. Jansen BV',
            onChanged: onChanged,
          ),
          const SizedBox(height: 10),

          // First & Last Name
          Row(
            children: [
              Expanded(
                child: KlantFormField(
                  fieldKey: const ValueKey('customer_firstName'),
                  controller: controllers.firstName,
                  label: 'Voornaam',
                  hint: 'Jan',
                  onChanged: onChanged,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: KlantFormField(
                  fieldKey: const ValueKey('customer_lastName'),
                  controller: controllers.lastName,
                  label: 'Achternaam *',
                  hint: 'Jansen',
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Street
          KlantFormField(
            fieldKey: const ValueKey('customer_street'),
            controller: controllers.street,
            label: 'Straat',
            hint: 'Kerkstraat',
            onChanged: onChanged,
          ),
          const SizedBox(height: 10),

          // House Number & Box
          Row(
            children: [
              Expanded(
                flex: 2,
                child: KlantFormField(
                  fieldKey: const ValueKey('customer_houseNumber'),
                  controller: controllers.houseNumber,
                  label: 'Nummer',
                  hint: '42',
                  keyboardType: TextInputType.streetAddress,
                  onChanged: onChanged,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 1,
                child: KlantFormField(
                  fieldKey: const ValueKey('customer_boxNumber'),
                  controller: controllers.boxNumber,
                  label: 'Bus',
                  hint: 'B',
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Postcode & City
          Row(
            children: [
              Expanded(
                flex: 2,
                child: KlantFormField(
                  fieldKey: const ValueKey('customer_postalCode'),
                  controller: controllers.postalCode,
                  label: 'Postcode',
                  hint: '9000',
                  keyboardType: TextInputType.number,
                  onChanged: onChanged,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 3,
                child: KlantFormField(
                  fieldKey: const ValueKey('customer_city'),
                  controller: controllers.city,
                  label: 'Gemeente / Stad',
                  hint: 'Gent',
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Phone & Email
          Row(
            children: [
              Expanded(
                child: KlantFormField(
                  fieldKey: const ValueKey('customer_phone'),
                  controller: controllers.phone,
                  label: 'Telefoon',
                  prefixText: BelgianFormatters.phonePrefix,
                  inputFormatters: BelgianFormatters.phoneFormatters,
                  validator: BelgianFormatters.validatePhone,
                  hint: '470 12 34 56',
                  keyboardType: TextInputType.phone,
                  onChanged: onChanged,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: KlantFormField(
                  fieldKey: const ValueKey('customer_email'),
                  controller: controllers.email,
                  label: 'E-mailadres',
                  hint: 'jan@voorbeeld.be',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn({
    required String label,
    required IconData icon,
    required bool isGold,
    required VoidCallback onTap,
  }) {
    return OutlinedButton.icon(
      onPressed: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      icon: Icon(
        icon,
        size: isGold ? 18 : 16,
        color: isGold ? AppColors.antiqueGold : AppColors.textSecondary,
      ),
      label: Text(
        label,
        style: TextStyle(
          color: isGold ? AppColors.antiqueGold : AppColors.textSecondary,
          fontSize: 12,
          fontWeight: isGold ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: isGold ? AppColors.antiqueGold : AppColors.goldHairline,
          width: 1.0,
        ),
        backgroundColor: isGold
            ? AppColors.antiqueGold.withValues(alpha: 0.08)
            : AppColors.charcoalGlass,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
