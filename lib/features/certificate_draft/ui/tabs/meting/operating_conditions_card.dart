import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/meting_dictionary.dart';
import '../../widgets/bento_main_section.dart';
import '../../widgets/dark_input_box.dart';
import '../../widgets/dark_input_label.dart';
import '../../widgets/quick_slider_picker.dart';
import '../../../domain/boiler_draft.dart';
import 'bacharach_selector.dart';
import 'wheel_input_row.dart';

/// Bento Card 1: Goede staat van werking (Operating conditions).
///
/// Features:
/// - Compact side-by-side layout: quick slider chips on the left, centered input box on the right.
/// - Saves over 50px of vertical height per parameter.
/// - Dynamically filters inputs based on the installation fuel (Gas vs Oil vs Solid).
/// - Tactical Bacharach 0-2 selector with automatic regulatory OK/Niet OK logic.
class OperatingConditionsCard extends StatelessWidget {
  final BoilerDraft boiler;
  final TextEditingController boilerTempController;
  final TextEditingController gasMeterController;
  final TextEditingController gasBlockController;
  final TextEditingController gasBurnerBedController;
  final TextEditingController nozzleBrandTypeController;
  final TextEditingController nozzleFlowRateController;
  final TextEditingController nozzleAngleController;
  final TextEditingController pumpPressureController;
  final TextEditingController smokeIndexController;
  final bool? smokeIndexOk;
  final ValueChanged<bool?> onSmokeIndexOkChanged;
  final VoidCallback onChanged;

  const OperatingConditionsCard({
    super.key,
    required this.boiler,
    required this.boilerTempController,
    required this.gasMeterController,
    required this.gasBlockController,
    required this.gasBurnerBedController,
    required this.nozzleBrandTypeController,
    required this.nozzleFlowRateController,
    required this.nozzleAngleController,
    required this.pumpPressureController,
    required this.smokeIndexController,
    required this.smokeIndexOk,
    required this.onSmokeIndexOkChanged,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLiquid = boiler.fuelCategory == 'vloeibaar';
    final bool isGas = boiler.fuelCategory == 'gas';

    return BentoMainSection(
      title: MetingDictionary.headerOperatingConditions,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Keteltemperatuur (°C) with Horizontal 3D Wheel Dial (50 to 80 °C)
          const DarkInputLabel(MetingDictionary.lblBoilerTemp),
          const SizedBox(height: 4),
          WheelInputRow.range(
            min: 50,
            max: 80,
            controller: boilerTempController,
            preferredInitialItem: '55',
            suffix: '°C',
            hintText: '°C',
            onChanged: onChanged,
          ),
          const SizedBox(height: 12),

          // 2. Gas specific pressures with 3D Wheel Dials
          if (isGas) ...[
            const DarkInputLabel(MetingDictionary.lblGasPressureMeter),
            const SizedBox(height: 4),
            WheelInputRow.range(
              min: 15,
              max: 37,
              controller: gasMeterController,
              preferredInitialItem: '21',
              suffix: 'mbar',
              hintText: 'mbar',
              onChanged: onChanged,
            ),
            const SizedBox(height: 12),
            const DarkInputLabel(MetingDictionary.lblGasPressureBlock),
            const SizedBox(height: 4),
            WheelInputRow.range(
              min: 15,
              max: 37,
              controller: gasBlockController,
              preferredInitialItem: '21',
              suffix: 'mbar',
              hintText: 'mbar',
              onChanged: onChanged,
            ),
            const SizedBox(height: 12),
            const DarkInputLabel(MetingDictionary.lblGasPressureBurnerBed),
            const SizedBox(height: 4),
            WheelInputRow.range(
              min: 0,
              max: 12,
              controller: gasBurnerBedController,
              preferredInitialItem: '0',
              suffix: 'mbar',
              hintText: 'mbar',
              textInputAction: TextInputAction.done,
              onChanged: onChanged,
            ),
          ],

          // 3. Oil / Liquid specific nozzle and pump fields
          if (isLiquid) ...[
            const DarkInputLabel(MetingDictionary.lblNozzleBrandType),
            TextFormField(
              controller: nozzleBrandTypeController,
              style: DarkInputBox.inputStyle,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              decoration: DarkInputBox.decoration(
                hintText: MetingDictionary.hintNozzleBrandType,
              ),
              onChanged: (_) => onChanged(),
            ),
            const SizedBox(height: 6),
            QuickSliderPicker.forController(
              controller: nozzleBrandTypeController,
              options: const [
                'Danfoss',
                'Steinen',
                'Delavan',
                'Fluidics',
                'Monarch'
              ],
              onChanged: onChanged,
            ),
            const SizedBox(height: 12),
            const DarkInputLabel(MetingDictionary.lblNozzleFlowRate),
            const SizedBox(height: 4),
            WheelInputRow(
              controller: nozzleFlowRateController,
              preferredInitialItem: '0.60',
              items: const [
                '0.40',
                '0.45',
                '0.50',
                '0.55',
                '0.60',
                '0.65',
                '0.70',
                '0.75',
                '0.80',
                '0.85',
                '1.00',
                '1.10',
                '1.20',
                '1.25'
              ],
              hintText: 'debiet',
              onChanged: onChanged,
            ),
            const SizedBox(height: 12),
            const DarkInputLabel(MetingDictionary.lblNozzleAngle),
            const SizedBox(height: 4),
            WheelInputRow(
              controller: nozzleAngleController,
              preferredInitialItem: '60',
              items: const ['30', '45', '60', '70', '80', '90'],
              suffix: '°',
              hintText: '°',
              onChanged: onChanged,
            ),
            const SizedBox(height: 12),
            const DarkInputLabel(MetingDictionary.lblPumpPressure),
            const SizedBox(height: 4),
            WheelInputRow.range(
              min: 7,
              max: 16,
              controller: pumpPressureController,
              preferredInitialItem: '10',
              suffix: 'bar',
              hintText: 'bar',
              onChanged: onChanged,
            ),
            const SizedBox(height: 12),
            const DarkInputLabel(MetingDictionary.lblSmokeIndex),
            const SizedBox(height: 4),
            BacharachSelector(
              controller: smokeIndexController,
              isOk: smokeIndexOk,
              onOkChanged: onSmokeIndexOkChanged,
              onChanged: onChanged,
            ),
          ],
        ],
      ),
    );
  }
}
