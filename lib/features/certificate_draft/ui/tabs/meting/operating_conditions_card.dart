import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/meting_dictionary.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
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
/// - Clean stacked layout: Parameter label and wider [- inputbox +] stepper in the header line.
/// - Full-range horizontal gliding ribbon with bouncing physics and zero layout jitter.
/// - Dynamically filters inputs based on the installation fuel (Gas vs Oil vs Solid).
/// - Strict fuel-isolated pre-flight check: only visible fields trigger validation errors.
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
    final bool isTypeC = boiler.centraalType == 'C';
    final bool isLpg = boiler.fuelSubtype.toLowerCase() == 'lpg';
    final bool isPremix = boiler.burnerTechnology == 'premix' || isTypeC;
    final bool isCondensing =
        boiler.boilerOperation == 'condenserend' || isTypeC;

    String? req(String? v) => (v == null || v.trim().isEmpty) ? '' : null;

    return BentoMainSection(
      title: MetingDictionary.headerOperatingConditions,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Keteltemperatuur (°C) - Required for all fuels
          WheelInputRow.range(
            label: MetingDictionary.lblBoilerTemp,
            min: 50,
            max: 80,
            controller: boilerTempController,
            preferredInitialItem: isCondensing ? '60' : '70',
            suffix: '°C',
            hintText: '°C',
            validator: req,
            onChanged: onChanged,
          ),
          const SizedBox(height: 12),

          // 2. Gas specific pressures - Validated only when fuel is Gas
          if (isGas) ...[
            WheelInputRow.range(
              label: MetingDictionary.lblGasPressureMeter,
              min: 15,
              max: 37,
              controller: gasMeterController,
              preferredInitialItem: isLpg ? '37' : '21',
              suffix: 'mbar',
              hintText: 'mbar',
              validator: req,
              onChanged: onChanged,
            ),
            const SizedBox(height: 12),
            WheelInputRow.range(
              label: MetingDictionary.lblGasPressureBlock,
              min: 15,
              max: 37,
              controller: gasBlockController,
              preferredInitialItem: isLpg ? '35' : '20',
              suffix: 'mbar',
              hintText: 'mbar',
              validator: req,
              onChanged: onChanged,
            ),
            const SizedBox(height: 12),
            WheelInputRow.range(
              label: MetingDictionary.lblGasPressureBurnerBed,
              min: 0,
              max: 12,
              controller: gasBurnerBedController,
              preferredInitialItem: isPremix ? '0' : '10',
              suffix: 'mbar',
              hintText: 'mbar',
              textInputAction: TextInputAction.done,
              validator: req,
              onChanged: onChanged,
            ),
            const SizedBox(height: 12),
          ],

          // 3. Oil / Liquid specific nozzle and pump fields - Validated only when Liquid
          if (isLiquid) ...[
            const DarkInputLabel(MetingDictionary.lblNozzleBrandType),
            TextFormField(
              controller: nozzleBrandTypeController,
              style: DarkInputBox.inputStyle,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              validator: req,
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
            WheelInputRow(
              label: MetingDictionary.lblNozzleFlowRate,
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
              validator: req,
              onChanged: onChanged,
            ),
            const SizedBox(height: 12),
            WheelInputRow(
              label: MetingDictionary.lblNozzleAngle,
              controller: nozzleAngleController,
              preferredInitialItem: '60',
              items: const ['30', '45', '60', '70', '80', '90'],
              suffix: '°',
              hintText: '°',
              validator: req,
              onChanged: onChanged,
            ),
            const SizedBox(height: 12),
            WheelInputRow.range(
              label: MetingDictionary.lblPumpPressure,
              min: 7,
              max: 16,
              controller: pumpPressureController,
              preferredInitialItem: '10',
              suffix: 'bar',
              hintText: 'bar',
              validator: req,
              onChanged: onChanged,
            ),
            const SizedBox(height: 12),
            const DarkInputLabel(MetingDictionary.lblSmokeIndex),
            const SizedBox(height: 4),
            FormField<String>(
              validator: (_) => (smokeIndexController.text.trim().isEmpty ||
                      smokeIndexOk == null)
                  ? ''
                  : null,
              builder: (fieldState) {
                final hasError = fieldState.hasError &&
                    (smokeIndexController.text.trim().isEmpty ||
                        smokeIndexOk == null);
                return Container(
                  padding: const EdgeInsets.all(2.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: hasError ? AppColors.errorRed : Colors.transparent,
                      width: hasError ? 1.2 : 0.0,
                    ),
                  ),
                  child: BacharachSelector(
                    controller: smokeIndexController,
                    isOk: smokeIndexOk,
                    onOkChanged: (v) {
                      onSmokeIndexOkChanged(v);
                      fieldState.didChange(smokeIndexController.text);
                    },
                    onChanged: () {
                      fieldState.didChange(smokeIndexController.text);
                      onChanged();
                    },
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
