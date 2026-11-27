import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/reiniging_dictionary.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/core/widgets/tactical_check_button.dart';
import 'package:hvac_app/features/certificate_draft/ui/widgets/dark_input_label.dart';

/// Role selector (`Erkend technicus` & `Schoorsteenveger`) for Reinigingsattest
/// and Combined Maintenance workflows in Tab 3 (Firma - Technicus).
class TechnicianRoleSection extends StatelessWidget {
  const TechnicianRoleSection({
    super.key,
    required this.isErkendTechnicus,
    required this.isSchoorsteenveger,
    required this.onToggleErkend,
    required this.onToggleSchoorsteenveger,
  });

  final bool isErkendTechnicus;
  final bool isSchoorsteenveger;
  final VoidCallback onToggleErkend;
  final VoidCallback onToggleSchoorsteenveger;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const DarkInputLabel(ReinigingDictionary.lblTechnicianRoles),
        SizedBox(
          height: 44,
          child: Row(
            children: [
              Expanded(
                child: TacticalCheckButton(
                  key: const ValueKey('role_erkend_technicus'),
                  label: ReinigingDictionary.roleErkendTechnicus,
                  isActive: isErkendTechnicus,
                  activeBackgroundColor: Color.alphaBlend(
                    AppColors.antiqueGold.withValues(alpha: 0.14),
                    const Color(0xFF141414),
                  ),
                  activeBorderColor: AppColors.amberGoldBorder,
                  onTap: onToggleErkend,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TacticalCheckButton(
                  key: const ValueKey('role_schoorsteenveger'),
                  label: ReinigingDictionary.roleSchoorsteenveger,
                  isActive: isSchoorsteenveger,
                  activeBackgroundColor: Color.alphaBlend(
                    AppColors.antiqueGold.withValues(alpha: 0.14),
                    const Color(0xFF141414),
                  ),
                  activeBorderColor: AppColors.amberGoldBorder,
                  onTap: onToggleSchoorsteenveger,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
