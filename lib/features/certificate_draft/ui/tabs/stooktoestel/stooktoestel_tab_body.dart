import 'package:flutter/material.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/core/widgets/workflow_tab_container.dart';
import 'brander_card.dart';
import 'kenmerken_card.dart';
import 'stooktoestel_form_controllers.dart';
import 'toestel_card.dart';

/// Form body for Tab 5 (Stooktoestel & Brander).
/// Centered and constrained to max 600px width for premium tablet presentation.
class StooktoestelTabBody extends StatelessWidget {
  final StooktoestelFormControllers controllers;
  final bool isCentral;
  final String centraalType;
  final String heatingType;
  final String boilerOperation;
  final String fuelCategory;
  final String fuelSubtype;
  final String fuelOtherText;
  final String burnerTechnology;
  final String burnerType;
  final bool serialUnknown;
  final bool yearUnknown;
  final bool burnerSerialUnknown;
  final bool burnerYearUnknown;
  final ValueChanged<bool> onCentralChanged;
  final ValueChanged<String> onCentraalTypeChanged;
  final ValueChanged<String> onHeatingTypeChanged;
  final ValueChanged<String> onBoilerOperationChanged;
  final ValueChanged<String> onFuelCategoryChanged;
  final ValueChanged<String> onFuelSubtypeChanged;
  final ValueChanged<String> onFuelOtherTextChanged;
  final ValueChanged<String> onBurnerTechChanged;
  final ValueChanged<String> onBurnerTypeChanged;
  final ValueChanged<String> onTypeBCodeChanged;
  final ValueChanged<String> onTypeCCodeChanged;
  final ValueChanged<bool> onSerialUnknownChanged;
  final ValueChanged<bool> onYearUnknownChanged;
  final ValueChanged<bool> onBurnerSerialUnknownChanged;
  final ValueChanged<bool> onBurnerYearUnknownChanged;
  final VoidCallback onScanToestelBarcode;
  final VoidCallback onScanBranderBarcode;
  final VoidCallback onFormChanged;

  const StooktoestelTabBody({
    super.key,
    required this.controllers,
    required this.isCentral,
    required this.centraalType,
    required this.heatingType,
    required this.boilerOperation,
    required this.fuelCategory,
    required this.fuelSubtype,
    required this.fuelOtherText,
    required this.burnerTechnology,
    required this.burnerType,
    required this.serialUnknown,
    required this.yearUnknown,
    required this.burnerSerialUnknown,
    required this.burnerYearUnknown,
    required this.onCentralChanged,
    required this.onCentraalTypeChanged,
    required this.onHeatingTypeChanged,
    required this.onBoilerOperationChanged,
    required this.onFuelCategoryChanged,
    required this.onFuelSubtypeChanged,
    required this.onFuelOtherTextChanged,
    required this.onBurnerTechChanged,
    required this.onBurnerTypeChanged,
    required this.onTypeBCodeChanged,
    required this.onTypeCCodeChanged,
    required this.onSerialUnknownChanged,
    required this.onYearUnknownChanged,
    required this.onBurnerSerialUnknownChanged,
    required this.onBurnerYearUnknownChanged,
    required this.onScanToestelBarcode,
    required this.onScanBranderBarcode,
    required this.onFormChanged,
  });

  @override
  Widget build(BuildContext context) {
    return WorkflowTabContainer(
      scrollKey: 'stooktoestel_tab_scroll',
      children: [
        // Card 1: Kenmerken
        KenmerkenCard(
          isCentral: isCentral,
          centraalType: centraalType,
          typeBController: controllers.typeB,
          typeCController: controllers.typeC,
          heatingType: heatingType,
          boilerOperation: boilerOperation,
          fuelCategory: fuelCategory,
          fuelSubtype: fuelSubtype,
          fuelOtherText: fuelOtherText,
          burnerTechnology: burnerTechnology,
          onCentralChanged: onCentralChanged,
          onCentraalTypeChanged: onCentraalTypeChanged,
          onHeatingTypeChanged: onHeatingTypeChanged,
          onBoilerOperationChanged: onBoilerOperationChanged,
          onFuelCategoryChanged: onFuelCategoryChanged,
          onFuelSubtypeChanged: onFuelSubtypeChanged,
          onFuelOtherTextChanged: onFuelOtherTextChanged,
          onBurnerTechChanged: onBurnerTechChanged,
          onTypeBCodeChanged: onTypeBCodeChanged,
          onTypeCCodeChanged: onTypeCCodeChanged,
        ),
        const SizedBox(height: AppTheme.bentoCardSpacing),

        // Card 2: Toestel
        ToestelCard(
          brandController: controllers.toestelBrand,
          modelController: controllers.toestelModel,
          yearController: controllers.toestelYear,
          serialController: controllers.toestelSerial,
          powerController: controllers.toestelPower,
          serialUnknown: serialUnknown,
          yearUnknown: yearUnknown,
          onSerialUnknownChanged: onSerialUnknownChanged,
          onYearUnknownChanged: onYearUnknownChanged,
          onScanBarcode: onScanToestelBarcode,
          onChanged: onFormChanged,
        ),
        const SizedBox(height: AppTheme.bentoCardSpacing),

        // Card 3: Brander (Smart Toggle)
        BranderCard(
          burnerType: burnerType,
          onBurnerTypeChanged: onBurnerTypeChanged,
          brandController: controllers.branderBrand,
          modelController: controllers.branderModel,
          yearController: controllers.branderYear,
          serialController: controllers.branderSerial,
          flowRateController: controllers.branderFlowRate,
          yearUnknown: burnerYearUnknown,
          serialUnknown: burnerSerialUnknown,
          onYearUnknownChanged: onBurnerYearUnknownChanged,
          onSerialUnknownChanged: onBurnerSerialUnknownChanged,
          onScanBarcode: onScanBranderBarcode,
          onChanged: onFormChanged,
        ),
      ],
    );
  }
}
