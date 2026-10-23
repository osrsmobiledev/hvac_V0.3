import 'package:flutter/material.dart';
import 'package:hvac_app/core/utils/belgian_formatters.dart';
import '../../widgets/bento_main_section.dart';
import 'firma_field.dart';

/// Company details section on Tab 3 (Firma - Technicus).
class CompanySection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController streetController;
  final TextEditingController houseNumberController;
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
          FirmaField(
            label: 'Naam:',
            controller: nameController,
            hint: 'bv. HVAC Solutions BV',
            onChanged: onChanged,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: FirmaField(
                  label: 'Straat:',
                  controller: streetController,
                  hint: 'Kerkstraat',
                  onChanged: onChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: FirmaField(
                  label: 'Nr:',
                  controller: houseNumberController,
                  hint: '42',
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: FirmaField(
                  label: 'Postnummer:',
                  controller: postalCodeController,
                  hint: '9000',
                  keyboardType: TextInputType.number,
                  onChanged: onChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FirmaField(
                  label: 'Gemeente:',
                  controller: cityController,
                  hint: 'Gent',
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FirmaField(
                  label: 'Tel:',
                  controller: phoneController,
                  prefixText: BelgianFormatters.phonePrefix,
                  inputFormatters: BelgianFormatters.phoneFormatters,
                  validator: BelgianFormatters.validatePhone,
                  hint: '470 12 34 56',
                  keyboardType: TextInputType.phone,
                  onChanged: onChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FirmaField(
                  label: 'Ondernemingsnummer:',
                  controller: kboNumberController,
                  prefixText: BelgianFormatters.kboPrefix,
                  inputFormatters: BelgianFormatters.kboFormatters,
                  validator: BelgianFormatters.validateKbo,
                  hint: '0123.456.789',
                  keyboardType: TextInputType.number,
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          FirmaField(
            label: 'Email:',
            controller: emailController,
            hint: 'info@hvac.be',
            keyboardType: TextInputType.emailAddress,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
