import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/features/certificate_draft/ui/widgets/bento_main_section.dart';
import 'klant_form_controllers.dart';
import 'klant_form_field.dart';
import 'role_tactical_button.dart';

/// Bento card presenting the installation address and the customer's role (Eigenaar / Huurder).
class InstallationLocationCard extends StatelessWidget {
  final KlantFormControllers controllers;
  final String role; // 'owner' or 'tenant'
  final ValueChanged<String> onRoleChanged;
  final bool isSameAsCustomer;
  final ValueChanged<bool> onSameAddressChanged;
  final VoidCallback onChanged;

  const InstallationLocationCard({
    super.key,
    required this.controllers,
    required this.role,
    required this.onRoleChanged,
    required this.isSameAsCustomer,
    required this.onSameAddressChanged,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BentoMainSection(
      title: AppDictionary.headerInstallationAddress,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Subtitle from government PDF standard
          const Text(
            AppDictionary.subInstallationAddress,
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 12),

          // Role selection buttons (Eigenaar / Huurder)
          Row(
            children: [
              Expanded(
                child: RoleTacticalButton(
                  title: AppDictionary.roleOwner,
                  isSelected: role == 'owner',
                  onTap: () => onRoleChanged('owner'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: RoleTacticalButton(
                  title: AppDictionary.roleTenant,
                  isSelected: role == 'tenant',
                  onTap: () => onRoleChanged('tenant'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Same address toggle checkbox container
          Material(
            color: AppColors.charcoalGlass,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                onSameAddressChanged(!isSameAsCustomer);
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSameAsCustomer
                        ? AppColors.antiqueGold.withValues(alpha: 0.5)
                        : AppColors.goldHairline,
                    width: 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: isSameAsCustomer,
                        activeColor: AppColors.antiqueGold,
                        checkColor: AppColors.oledBase,
                        side: const BorderSide(
                          color: AppColors.goldHairline,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        onChanged: (val) {
                          HapticFeedback.selectionClick();
                          onSameAddressChanged(val ?? false);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        AppDictionary.lblSameAsCustomerAddress,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Collapsible separate address fields
          if (!isSameAsCustomer) ...[
            const SizedBox(height: 12),
            KlantFormField(
              fieldKey: const ValueKey('loc_street'),
              controller: controllers.locStreet,
              label: 'Straat installatie',
              hint: 'Adres waar ketel geplaatst is',
              onChanged: onChanged,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: KlantFormField(
                    fieldKey: const ValueKey('loc_houseNumber'),
                    controller: controllers.locHouseNumber,
                    label: 'Nummer',
                    hint: '12',
                    onChanged: onChanged,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: KlantFormField(
                    fieldKey: const ValueKey('loc_boxNumber'),
                    controller: controllers.locBoxNumber,
                    label: 'Bus',
                    hint: 'A',
                    onChanged: onChanged,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: KlantFormField(
                    fieldKey: const ValueKey('loc_postalCode'),
                    controller: controllers.locPostalCode,
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
                    fieldKey: const ValueKey('loc_municipality'),
                    controller: controllers.locMunicipality,
                    label: 'Gemeente',
                    hint: 'Gent',
                    onChanged: onChanged,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
