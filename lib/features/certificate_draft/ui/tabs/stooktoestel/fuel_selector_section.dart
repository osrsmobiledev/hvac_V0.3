import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import '../../widgets/dark_input_label.dart';
import 'fuel_option_tiles.dart';
import 'gas_sub_section.dart';
import 'solid_sub_section.dart';

/// Single authoritative fuel selector with dynamic sub-options.
///
/// Implements Golden Rule #3: Select appliance fuel once, driving
/// subsequent flue-gas measurement rules in Tab 6 without data loss.
class FuelSelectorSection extends StatelessWidget {
  final String selectedCategory; // 'gas', 'vloeibaar', 'vast'
  final String selectedSubtype;
  final String otherText;
  final String burnerTechnology;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onSubtypeChanged;
  final ValueChanged<String> onOtherTextChanged;
  final ValueChanged<String> onBurnerTechChanged;

  const FuelSelectorSection({
    super.key,
    required this.selectedCategory,
    required this.selectedSubtype,
    required this.otherText,
    required this.burnerTechnology,
    required this.onCategoryChanged,
    required this.onSubtypeChanged,
    required this.onOtherTextChanged,
    required this.onBurnerTechChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DarkInputLabel(AppDictionary.headerFuel),
        const SizedBox(height: 6),

        // 1. Unified 3-way sliding fuel category bar
        TacticalFuelCategoryBar(
          selectedCategory: selectedCategory,
          onCategoryChanged: onCategoryChanged,
        ),

        // 2. Dynamic Sub-Panels (Gas and Solid; Liquid requires no sub-inputs)
        if (selectedCategory == 'gas') ...[
          const SizedBox(height: 12),
          GasSubSection(
            selectedSubtype: selectedSubtype,
            otherText: otherText,
            burnerTechnology: burnerTechnology,
            onSubtypeChanged: onSubtypeChanged,
            onOtherTextChanged: onOtherTextChanged,
            onBurnerTechChanged: onBurnerTechChanged,
          ),
        ] else if (selectedCategory == 'vast') ...[
          const SizedBox(height: 12),
          SolidSubSection(
            selectedSubtype: selectedSubtype,
            otherText: otherText,
            onSubtypeChanged: onSubtypeChanged,
            onOtherTextChanged: onOtherTextChanged,
          ),
        ],
      ],
    );
  }
}
