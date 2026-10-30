import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/meting_dictionary.dart';
import '../../widgets/bento_main_section.dart';
import '../../widgets/dark_input_label.dart';
import '../../../domain/boiler_draft.dart';
import '../../../domain/operating_conditions_draft.dart';
import 'tactical_binary_check.dart';

/// Bento Card 3: Veilige staat van werking (Safety & environmental checks).
///
/// Features:
/// - Statutorily required checks according to Flemish VEKA / NBN CR 1749 guidelines.
/// - Dynamic applicability filtering:
///   - Type B: Unwanted flue condensation check.
///   - Type C: Flue discharge tightness check.
///   - Liquid: No visible oil trace check.
///   - Gas: Fuel-supply line tightness (gas meter to boiler).
///   - Common: Boiler-room ventilation and flue draft pressure.
class SafetyChecksCard extends StatelessWidget {
  final BoilerDraft boiler;
  final OperatingConditionsDraft draft;
  final ValueChanged<OperatingConditionsDraft> onDraftChanged;

  const SafetyChecksCard({
    super.key,
    required this.boiler,
    required this.draft,
    required this.onDraftChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool isGas = boiler.fuelCategory == 'gas';
    final bool isLiquid = boiler.fuelCategory == 'vloeibaar';
    final bool isSolid = boiler.fuelCategory == 'vast';
    final bool isTypeB = boiler.centraalType == 'B';
    final bool isTypeC = boiler.centraalType == 'C';

    return BentoMainSection(
      title: MetingDictionary.headerSafetyChecks,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Druk rookgaskanaal (Pa) - Applicable to all
          _CheckRow(
            label: MetingDictionary.lblCheckFluePressure,
            value: draft.fluePressureOk,
            onChanged: (val) {
              onDraftChanged(draft.copyWith(fluePressureOk: val));
            },
          ),
          const SizedBox(height: 14),

          // 2. Verluchting & ventilatie stooklokaal - Applicable to all
          _CheckRow(
            label: MetingDictionary.lblCheckVentilation,
            value: draft.ventilationOk,
            onChanged: (val) {
              onDraftChanged(draft.copyWith(ventilationOk: val));
            },
          ),
          const SizedBox(height: 14),

          // 3. Dichtheid brandstoftoevoerleiding (gasmeter tot ketel) - Gas only
          if (isGas) ...[
            _CheckRow(
              label: MetingDictionary.lblCheckFuelSupplyTightness,
              value: draft.fuelSupplyTightnessOk,
              onChanged: (val) {
                onDraftChanged(draft.copyWith(fuelSupplyTightnessOk: val));
              },
            ),
            const SizedBox(height: 14),
          ],

          // 4. Dichtheid rookgasafvoer (Type C) - Type C only
          if (isTypeC) ...[
            _CheckRow(
              label: MetingDictionary.lblCheckFlueTightness,
              value: draft.flueTightnessOk,
              onChanged: (val) {
                onDraftChanged(draft.copyWith(flueTightnessOk: val));
              },
            ),
            const SizedBox(height: 14),
          ],

          // 5. Geen ongewenste condensvorming (Type B) - Type B only
          if (isTypeB) ...[
            _CheckRow(
              label: MetingDictionary.lblCheckNoCondensation,
              value: draft.noUnwantedCondensationOk,
              onChanged: (val) {
                onDraftChanged(draft.copyWith(noUnwantedCondensationOk: val));
              },
            ),
            const SizedBox(height: 14),
          ],

          // 6. Geen zichtbaar oliespoor - Liquid only
          if (isLiquid) ...[
            _CheckRow(
              label: MetingDictionary.lblCheckNoOilTrace,
              value: draft.noOilTraceOk,
              onChanged: (val) {
                onDraftChanged(draft.copyWith(noOilTraceOk: val));
              },
            ),
            const SizedBox(height: 14),
          ],

          // 7. Zelden hinderlijke en milieuverontreinigende rook - Solid only
          if (isSolid) ...[
            _CheckRow(
              label: MetingDictionary.lblCheckRarelySmoke,
              value: draft.rarelyPollutingSmokeOk,
              onChanged: (val) {
                onDraftChanged(draft.copyWith(rarelyPollutingSmokeOk: val));
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  final String label;
  final bool? value;
  final ValueChanged<bool?> onChanged;

  const _CheckRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DarkInputLabel(label),
        const SizedBox(height: 4),
        TacticalBinaryCheck(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
