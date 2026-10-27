import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/core/widgets/tactical_toggle_button.dart';
import '../../widgets/bento_main_section.dart';
import 'centraal_types_section.dart';
import 'fuel_selector_section.dart';
import 'veka_attributes_section.dart';

/// Bento Card 1: Kenmerken van het stooktoestel.
///
/// Encapsulates:
/// - Centraal (Type B open / Type C gesloten per NBN CR 1749).
/// - VEKA heating type (Individueel / Collectief / Onbekend).
/// - VEKA boiler operation (Condenserend / Niet-condenserend / Onbekend).
/// - Single authoritative fuel selector with dynamic sub-options.
class KenmerkenCard extends StatelessWidget {
  final bool isCentral;
  final String centraalType; // 'B' or 'C'
  final TextEditingController typeBController;
  final TextEditingController typeCController;
  final String heatingType; // 'individueel', 'collectief', 'onbekend'
  final String
      boilerOperation; // 'condenserend', 'niet_condenserend', 'onbekend'
  final String fuelCategory; // 'gas', 'vloeibaar', 'vast'
  final String fuelSubtype;
  final String fuelOtherText;
  final String burnerTechnology;

  final ValueChanged<bool> onCentralChanged;
  final ValueChanged<String> onCentraalTypeChanged;
  final ValueChanged<String> onHeatingTypeChanged;
  final ValueChanged<String> onBoilerOperationChanged;
  final ValueChanged<String> onFuelCategoryChanged;
  final ValueChanged<String> onFuelSubtypeChanged;
  final ValueChanged<String> onFuelOtherTextChanged;
  final ValueChanged<String> onBurnerTechChanged;

  const KenmerkenCard({
    super.key,
    required this.isCentral,
    required this.centraalType,
    required this.typeBController,
    required this.typeCController,
    required this.heatingType,
    required this.boilerOperation,
    required this.fuelCategory,
    required this.fuelSubtype,
    required this.fuelOtherText,
    required this.burnerTechnology,
    required this.onCentralChanged,
    required this.onCentraalTypeChanged,
    required this.onHeatingTypeChanged,
    required this.onBoilerOperationChanged,
    required this.onFuelCategoryChanged,
    required this.onFuelSubtypeChanged,
    required this.onFuelOtherTextChanged,
    required this.onBurnerTechChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BentoMainSection(
      title: AppDictionary.headerKenmerken,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Centraal (*) Row
          TacticalToggleButton(
            label: AppDictionary.lblCentraal,
            subtitle: AppDictionary.footnoteCentraal,
            value: isCentral,
            onChanged: onCentralChanged,
          ),
          const SizedBox(height: 12),

          // 2. Type B / Type C options (Active when isCentral is true)
          CentraalTypesSection(
            isCentral: isCentral,
            centraalType: centraalType,
            typeBController: typeBController,
            typeCController: typeCController,
            onCentraalTypeChanged: onCentraalTypeChanged,
          ),
          const SizedBox(height: 16),

          // Hairline divider
          Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
          const SizedBox(height: 16),

          // 3. VEKA VerwarmingType & Werking
          VekaAttributesSection(
            heatingType: heatingType,
            boilerOperation: boilerOperation,
            onHeatingTypeChanged: onHeatingTypeChanged,
            onBoilerOperationChanged: onBoilerOperationChanged,
          ),
          const SizedBox(height: 16),

          // Hairline divider
          Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
          const SizedBox(height: 16),

          // 4. Single Installation Fuel Selection (Golden Rule #3)
          FuelSelectorSection(
            selectedCategory: fuelCategory,
            selectedSubtype: fuelSubtype,
            otherText: fuelOtherText,
            burnerTechnology: burnerTechnology,
            onCategoryChanged: onFuelCategoryChanged,
            onSubtypeChanged: onFuelSubtypeChanged,
            onOtherTextChanged: onFuelOtherTextChanged,
            onBurnerTechChanged: onBurnerTechChanged,
          ),
        ],
      ),
    );
  }
}
