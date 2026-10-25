import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/core/utils/belgian_formatters.dart';
import '../../widgets/bento_main_section.dart';
import 'firma_field.dart';

/// Company details section on Tab 3 (Firma - Technicus).
///
/// Follows the symmetrical 12px layout matching Bento 'Klantgegevens' on Tab 4:
/// 1. Naam Firma — Full width
/// 2. Straat — Full width address input
/// 3. Nr & Bus — 2-Column Row (1:1)
/// 4. Postcode & Gemeente — 2-Column Row (1:1)
/// 5. Tel — Full width Belgian phone input with permanent +32 prefix
/// 6. Email — Full width email input
/// 7. Ondernemingsnummer (KBO) — Full width Belgian KBO input all the way down
class CompanySection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController streetController;
  final TextEditingController houseNumberController;
  final TextEditingController boxNumberController;
  final TextEditingController postalCodeController;
  final TextEditingController cityController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController kboNumberController;
  final VoidCallback onChanged;

  const CompanySection({
    super.key,
    required this.nameController,
    required this.streetController,
    required this.houseNumberController,
    required this.boxNumberController,
    required this.postalCodeController,
    required this.cityController,
    required this.phoneController,
    required this.emailController,
    required this.kboNumberController,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BentoMainSection(
      title: 'Firma',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Naam Firma — Full width
          FirmaField(
            fieldKey: const ValueKey('company_name'),
            label: AppDictionary.lblCompanyName,
            controller: nameController,
            hint: 'bv. HVAC Solutions BV',
            onChanged: onChanged,
          ),
          const SizedBox(height: 12),

          // 2. Straat — Full width address input
          FirmaField(
            fieldKey: const ValueKey('company_street'),
            label: AppDictionary.lblStreet,
            controller: streetController,
            hint: AppDictionary.hintSearchAddress,
            onChanged: onChanged,
          ),
          const SizedBox(height: 12),

          // 3. Nr & Bus — 2-Column Row (1:1)
          Row(
            children: [
              Expanded(
                child: FirmaField(
                  fieldKey: const ValueKey('company_houseNumber'),
                  label: AppDictionary.lblHouseNumber,
                  controller: houseNumberController,
                  hint: AppDictionary.hintHouseNumber,
                  keyboardType: TextInputType.streetAddress,
                  onChanged: onChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FirmaField(
                  fieldKey: const ValueKey('company_boxNumber'),
                  label: AppDictionary.lblBox,
                  controller: boxNumberController,
                  hint: AppDictionary.hintBox,
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 4. Postcode & Gemeente — 2-Column Row (1:1)
          Row(
            children: [
              Expanded(
                child: FirmaField(
                  fieldKey: const ValueKey('company_postalCode'),
                  label: AppDictionary.lblPostalCode,
                  controller: postalCodeController,
                  hint: AppDictionary.hintPostalCode,
                  keyboardType: TextInputType.number,
                  onChanged: onChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FirmaField(
                  fieldKey: const ValueKey('company_city'),
                  label: AppDictionary.lblCity,
                  controller: cityController,
                  hint: AppDictionary.hintCity,
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 5. Tel — Full width Belgian phone input
          FirmaField(
            fieldKey: const ValueKey('company_phone'),
            label: AppDictionary.lblPhone,
            controller: phoneController,
            prefixText: BelgianFormatters.phonePrefix,
            inputFormatters: BelgianFormatters.phoneFormatters,
            validator: BelgianFormatters.validatePhone,
            hint: AppDictionary.hintPhone,
            keyboardType: TextInputType.phone,
            onChanged: onChanged,
          ),
          const SizedBox(height: 12),

          // 6. Email — Full width email input
          FirmaField(
            fieldKey: const ValueKey('company_email'),
            label: AppDictionary.lblEmail,
            controller: emailController,
            hint: 'info@hvac.be',
            keyboardType: TextInputType.emailAddress,
            onChanged: onChanged,
          ),
          const SizedBox(height: 12),

          // 7. Ondernemingsnummer (KBO) — Full width, all the way down!
          FirmaField(
            fieldKey: const ValueKey('company_kboNumber'),
            label: AppDictionary.lblKBO,
            controller: kboNumberController,
            prefixText: BelgianFormatters.kboPrefix,
            inputFormatters: BelgianFormatters.kboFormatters,
            validator: BelgianFormatters.validateKbo,
            hint: '0123.456.789',
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
