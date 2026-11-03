// File: lib/features/certificate_draft/domain/flue_gas_field.dart
// Responsibility: 19 flue-gas parameter domain models ordered according to the official Flemish certificate.

import 'package:hvac_app/app/localization/data_tab_dictionary.dart';
import 'measurement_slot_draft.dart';

/// Represents a single flue-gas measurement reading on Tab 1 (Data).
///
/// Contains the statutory Flemish regulatory parameter name (with units in brackets)
/// and the captured measurement string or null if empty.
class FlueGasField {
  /// The official Dutch parameter label (e.g. 'Druk [hPa]', 'Zuurstof (O₂) [Vol. %]').
  final String label;

  /// The recorded measurement string or null when not yet captured.
  final String? value;

  const FlueGasField({
    required this.label,
    this.value,
  });

  /// The full ordered list of 19 flue-gas parameters matching the official
  /// Flemish Combustion Certificate table sequence, followed by telemetry diagnostics.
  static const List<FlueGasField> defaultFields = [
    // --- 1. Algemene meetgegevens (Brandstof) ---
    FlueGasField(label: DataTabDictionary.lblBrandstof),

    // --- 2. Statutaire Vlaamse attesteisen (Volgorde officieel attest) ---
    FlueGasField(label: DataTabDictionary.lblBoilerTemp),
    FlueGasField(label: DataTabDictionary.lblO2),
    FlueGasField(label: DataTabDictionary.lblCo2),
    FlueGasField(label: DataTabDictionary.lblCoMgKwh),
    FlueGasField(label: DataTabDictionary.lblFlueTempTg),
    FlueGasField(label: DataTabDictionary.lblAirTempTa),
    FlueGasField(label: DataTabDictionary.lblNetTemp),
    FlueGasField(label: DataTabDictionary.lblEfficiencyHi),
    FlueGasField(label: DataTabDictionary.lblEfficiencyHs),
    FlueGasField(label: DataTabDictionary.lblFluePressurePa),

    // --- 3. Telemetrie & branderdiagnose ---
    FlueGasField(label: DataTabDictionary.lblDrukHpa),
    FlueGasField(label: DataTabDictionary.lblCoPpm),
    FlueGasField(label: DataTabDictionary.lblCoRefPpm),
    FlueGasField(label: DataTabDictionary.lblExcessAirLambda),
    FlueGasField(label: DataTabDictionary.lblLossesQa),
    FlueGasField(label: DataTabDictionary.lblDewPoint),
    FlueGasField(label: DataTabDictionary.lblNoPpm),
    FlueGasField(label: DataTabDictionary.lblSo2Ppm),
  ];

  /// Populates the 19 fields using the telemetry in [draft].
  static List<FlueGasField> fromMeasurement(MeasurementSlotDraft? draft) {
    if (draft == null) return defaultFields;

    String? fmt(num? val) => val?.toString();

    // Derived lambda (excess air)
    String? lambda;
    if (draft.o2Percent != null && draft.o2Percent! < 20.9) {
      lambda = (20.9 / (20.9 - draft.o2Percent!)).toStringAsFixed(2);
    }

    // Derived losses
    String? losses;
    if (draft.efficiencyHi != null) {
      losses = (100.0 - draft.efficiencyHi!).toStringAsFixed(1);
    }

    return [
      // --- 1. Algemene meetgegevens (Brandstof) ---
      const FlueGasField(
          label: DataTabDictionary.lblBrandstof, value: 'Aardgas'),

      // --- 2. Statutaire Vlaamse attesteisen (Volgorde officieel attest) ---
      const FlueGasField(label: DataTabDictionary.lblBoilerTemp),
      FlueGasField(
        label: DataTabDictionary.lblO2,
        value: fmt(draft.o2Percent),
      ),
      FlueGasField(
        label: DataTabDictionary.lblCo2,
        value: fmt(draft.co2Percent),
      ),
      FlueGasField(
        label: DataTabDictionary.lblCoMgKwh,
        value: fmt(draft.coMgKwh),
      ),
      FlueGasField(
        label: DataTabDictionary.lblFlueTempTg,
        value: fmt(draft.flueTempTg),
      ),
      FlueGasField(
        label: DataTabDictionary.lblAirTempTa,
        value: fmt(draft.ambientTempTa),
      ),
      FlueGasField(
        label: DataTabDictionary.lblNetTemp,
        value: fmt(draft.effectiveNetTemp),
      ),
      FlueGasField(
        label: DataTabDictionary.lblEfficiencyHi,
        value: fmt(draft.efficiencyHi),
      ),
      FlueGasField(
        label: DataTabDictionary.lblEfficiencyHs,
        value: fmt(draft.efficiencyHs),
      ),
      FlueGasField(
        label: DataTabDictionary.lblFluePressurePa,
        value: fmt(draft.fluePressurePa),
      ),

      // --- 3. Telemetrie & branderdiagnose ---
      FlueGasField(
        label: DataTabDictionary.lblDrukHpa,
        value: draft.fluePressurePa != null
            ? (draft.fluePressurePa! / 100).toStringAsFixed(2)
            : null,
      ),
      FlueGasField(
        label: DataTabDictionary.lblCoPpm,
        value: draft.coMgKwh != null
            ? (draft.coMgKwh! / 1.25).toStringAsFixed(0)
            : null,
      ),
      FlueGasField(
        label: DataTabDictionary.lblCoRefPpm,
        value: draft.coMgKwh != null
            ? (draft.coMgKwh! / 1.25).toStringAsFixed(0)
            : null,
      ),
      FlueGasField(label: DataTabDictionary.lblExcessAirLambda, value: lambda),
      FlueGasField(label: DataTabDictionary.lblLossesQa, value: losses),
      const FlueGasField(label: DataTabDictionary.lblDewPoint),
      const FlueGasField(label: DataTabDictionary.lblNoPpm),
      const FlueGasField(label: DataTabDictionary.lblSo2Ppm),
    ];
  }
}
