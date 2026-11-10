import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import '../../../domain/boiler_draft.dart';
import '../../../domain/combustion_statutory_rules.dart';
import 'net_temperature_display.dart';
import 'numeric_combustion_field.dart';
import 'statutory_combustion_field.dart';

/// Responsive input field layout for combustion test measurements.
///
/// Smart adaptive layout: 1-column on narrow screens (< 380px),
/// 2-column paired grid on wider screens (Pixel 10 Pro / tablets).
/// Combines Data input, Logic indicator, and OK / NOK button in unified fields.
class CombustionFieldsLayout extends StatelessWidget {
  final BoilerDraft boiler;
  final String activeSlot;
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
    this.activeSlot = 'proef1',
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
    final bool isSlotRequired = activeSlot != 'proef2_hooglast';
    String? req(String? v) =>
        (isSlotRequired && (v == null || v.trim().isEmpty)) ? '' : null;

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
      validator: req,
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
      validator: req,
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
                      child: NumericCombustionField(
                          label: MetingDictionary.lblO2,
                          hintText: MetingDictionary.hintO2,
                          unit: '%',
                          controller: o2Controller,
                          textInputAction: TextInputAction.next,
                          required: isSlotRequired,
                          onChanged: onChanged)),
                  const SizedBox(width: 12),
                  Expanded(
                      flex: 5,
                      child: NumericCombustionField(
                          label: MetingDictionary.lblCO2,
                          hintText: MetingDictionary.hintCO2,
                          unit: '%',
                          controller: co2Controller,
                          textInputAction: TextInputAction.next,
                          required: isSlotRequired,
                          onChanged: onChanged)),
                ],
              ),
              const SizedBox(height: 12),
              coField,
              const SizedBox(height: 12),
              NumericCombustionField(
                  label: MetingDictionary.lblFlueTempTg,
                  hintText: MetingDictionary.hintFlueTempTg,
                  unit: '°C',
                  controller: flueTempTgController,
                  textInputAction: TextInputAction.next,
                  required: isSlotRequired,
                  onChanged: onChanged),
              const SizedBox(height: 12),
              NumericCombustionField(
                  label: MetingDictionary.lblAirTempTa,
                  hintText: MetingDictionary.hintAirTempTa,
                  unit: '°C',
                  controller: ambientTempTaController,
                  textInputAction: TextInputAction.next,
                  required: isSlotRequired,
                  onChanged: onChanged),
              const SizedBox(height: 12),
              NetTemperatureDisplay(calculatedNetTemp: calculatedNetTemp),
              const SizedBox(height: 12),
              hiField,
              const SizedBox(height: 12),
              NumericCombustionField(
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
                    child: NumericCombustionField(
                        label: MetingDictionary.lblO2,
                        hintText: MetingDictionary.hintO2,
                        unit: '%',
                        controller: o2Controller,
                        textInputAction: TextInputAction.next,
                        required: isSlotRequired,
                        onChanged: onChanged)),
                const SizedBox(width: 12),
                Expanded(
                    child: NumericCombustionField(
                        label: MetingDictionary.lblCO2,
                        hintText: MetingDictionary.hintCO2,
                        unit: '%',
                        controller: co2Controller,
                        textInputAction: TextInputAction.next,
                        required: isSlotRequired,
                        onChanged: onChanged)),
              ],
            ),
            const SizedBox(height: 14),
            coField,
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                    child: NumericCombustionField(
                        label: MetingDictionary.lblFlueTempTg,
                        hintText: MetingDictionary.hintFlueTempTg,
                        unit: '°C',
                        controller: flueTempTgController,
                        textInputAction: TextInputAction.next,
                        required: isSlotRequired,
                        onChanged: onChanged)),
                const SizedBox(width: 12),
                Expanded(
                    child: NumericCombustionField(
                        label: MetingDictionary.lblAirTempTa,
                        hintText: MetingDictionary.hintAirTempTa,
                        unit: '°C',
                        controller: ambientTempTaController,
                        textInputAction: TextInputAction.next,
                        required: isSlotRequired,
                        onChanged: onChanged)),
              ],
            ),
            const SizedBox(height: 14),
            NetTemperatureDisplay(calculatedNetTemp: calculatedNetTemp),
            const SizedBox(height: 14),
            hiField,
            const SizedBox(height: 14),
            NumericCombustionField(
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
