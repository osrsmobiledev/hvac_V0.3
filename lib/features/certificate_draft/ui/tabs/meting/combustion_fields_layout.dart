import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import '../../../domain/boiler_draft.dart';
import '../../../domain/combustion_statutory_rules.dart';
import '../../widgets/dark_text_field.dart';
import 'net_temperature_display.dart';
import 'statutory_combustion_field.dart';

/// Responsive input field layout for combustion test measurements.
///
/// Smart adaptive layout: 1-column on narrow screens (< 380px),
/// 2-column paired grid on wider screens (Pixel 10 Pro / tablets).
/// Combines Data input, Logic indicator, and OK / NOK button in unified fields.
class CombustionFieldsLayout extends StatelessWidget {
  final BoilerDraft boiler;
  final bool? coOk;
  final ValueChanged<bool?>? onCoOkChanged;
  final bool? efficiencyHiOk;
  final ValueChanged<bool?>? onEfficiencyHiOkChanged;
  final TextEditingController o2Controller;
  final TextEditingController co2Controller;
  final TextEditingController coMgKwhController;
  final TextEditingController flueTempTgController;
  final TextEditingController ambientTempTaController;
  final String calculatedNetTemp;
  final TextEditingController efficiencyHiController;
  final TextEditingController efficiencyHsController;
  final VoidCallback onChanged;

  const CombustionFieldsLayout({
    super.key,
    this.boiler = const BoilerDraft(),
    this.coOk,
    this.onCoOkChanged,
    this.efficiencyHiOk,
    this.onEfficiencyHiOkChanged,
    required this.o2Controller,
    required this.co2Controller,
    required this.coMgKwhController,
    required this.flueTempTgController,
    required this.ambientTempTaController,
    required this.calculatedNetTemp,
    required this.efficiencyHiController,
    required this.efficiencyHsController,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final double maxCo = CombustionStatutoryRules.maxCoMgKwh(boiler);
    final double minHi = CombustionStatutoryRules.minEfficiencyHi(boiler);

    final coField = StatutoryCombustionField(
      label: MetingDictionary.lblCO,
      normText:
          MetingDictionary.getCoNormText(fuelCategory: boiler.fuelCategory),
      hintText: MetingDictionary.hintCO,
      controller: coMgKwhController,
      textInputAction: TextInputAction.next,
      onChanged: onChanged,
      isCompliant: (val) => val <= maxCo,
      checkValue: coOk,
      onCheckChanged: onCoOkChanged,
    );

    final hiField = StatutoryCombustionField(
      label: MetingDictionary.lblEfficiencyHi,
      normText: MetingDictionary.getHiNormText(
        fuelCategory: boiler.fuelCategory,
        centraalType: boiler.centraalType,
        typeBText: boiler.typeBText,
      ),
      hintText: MetingDictionary.hintEfficiencyHi,
      controller: efficiencyHiController,
      textInputAction: TextInputAction.done,
      onChanged: onChanged,
      isCompliant: (val) => val >= minHi,
      checkValue: efficiencyHiOk,
      onCheckChanged: onEfficiencyHiOkChanged,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isNarrow = constraints.maxWidth < 420;

        if (isNarrow) {
          // --- 1-Column Stack with Paired O2 & CO2 Row ---
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                      flex: 4,
                      child: _NumericField(
                          label: MetingDictionary.lblO2,
                          hintText: MetingDictionary.hintO2,
                          unit: '%',
                          controller: o2Controller,
                          textInputAction: TextInputAction.next,
                          onChanged: onChanged)),
                  const SizedBox(width: 12),
                  Expanded(
                      flex: 5,
                      child: _NumericField(
                          label: MetingDictionary.lblCO2,
                          hintText: MetingDictionary.hintCO2,
                          unit: '%',
                          controller: co2Controller,
                          textInputAction: TextInputAction.next,
                          onChanged: onChanged)),
                ],
              ),
              const SizedBox(height: 12),
              coField,
              const SizedBox(height: 12),
              _NumericField(
                  label: MetingDictionary.lblFlueTempTg,
                  hintText: MetingDictionary.hintFlueTempTg,
                  unit: '°C',
                  controller: flueTempTgController,
                  textInputAction: TextInputAction.next,
                  onChanged: onChanged),
              const SizedBox(height: 12),
              _NumericField(
                  label: MetingDictionary.lblAirTempTa,
                  hintText: MetingDictionary.hintAirTempTa,
                  unit: '°C',
                  controller: ambientTempTaController,
                  textInputAction: TextInputAction.next,
                  onChanged: onChanged),
              const SizedBox(height: 12),
              NetTemperatureDisplay(calculatedNetTemp: calculatedNetTemp),
              const SizedBox(height: 12),
              hiField,
              const SizedBox(height: 12),
              _NumericField(
                  label: MetingDictionary.lblEfficiencyHs,
                  hintText: MetingDictionary.hintEfficiencyHs,
                  unit: '%',
                  controller: efficiencyHsController,
                  textInputAction: TextInputAction.done,
                  onChanged: onChanged),
            ],
          );
        }

        // --- Wide Screen Layout (Pixel 10 Pro / Tablets) ---
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                    child: _NumericField(
                        label: MetingDictionary.lblO2,
                        hintText: MetingDictionary.hintO2,
                        unit: '%',
                        controller: o2Controller,
                        textInputAction: TextInputAction.next,
                        onChanged: onChanged)),
                const SizedBox(width: 12),
                Expanded(
                    child: _NumericField(
                        label: MetingDictionary.lblCO2,
                        hintText: MetingDictionary.hintCO2,
                        unit: '%',
                        controller: co2Controller,
                        textInputAction: TextInputAction.next,
                        onChanged: onChanged)),
              ],
            ),
            const SizedBox(height: 14),
            coField,
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                    child: _NumericField(
                        label: MetingDictionary.lblFlueTempTg,
                        hintText: MetingDictionary.hintFlueTempTg,
                        unit: '°C',
                        controller: flueTempTgController,
                        textInputAction: TextInputAction.next,
                        onChanged: onChanged)),
                const SizedBox(width: 12),
                Expanded(
                    child: _NumericField(
                        label: MetingDictionary.lblAirTempTa,
                        hintText: MetingDictionary.hintAirTempTa,
                        unit: '°C',
                        controller: ambientTempTaController,
                        textInputAction: TextInputAction.next,
                        onChanged: onChanged)),
              ],
            ),
            const SizedBox(height: 14),
            NetTemperatureDisplay(calculatedNetTemp: calculatedNetTemp),
            const SizedBox(height: 14),
            hiField,
            const SizedBox(height: 14),
            _NumericField(
                label: MetingDictionary.lblEfficiencyHs,
                hintText: MetingDictionary.hintEfficiencyHs,
                unit: '%',
                controller: efficiencyHsController,
                textInputAction: TextInputAction.done,
                onChanged: onChanged),
          ],
        );
      },
    );
  }
}

class _NumericField extends StatelessWidget {
  final String label;
  final String hintText;
  final String? unit;
  final TextEditingController controller;
  final TextInputAction textInputAction;
  final VoidCallback onChanged;

  const _NumericField({
    required this.label,
    required this.hintText,
    this.unit,
    required this.controller,
    required this.textInputAction,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DarkTextField(
      label: label,
      hintText: hintText,
      unit: unit,
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: textInputAction,
      onChanged: onChanged,
    );
  }
}
