import 'measurement_slot_draft.dart';

/// Represents a single flue-gas measurement reading on Tab 1 (Data).
///
/// Contains the localized Dutch parameter name (with units in brackets)
/// and the captured measurement string or null if empty.
class FlueGasField {
  /// The Dutch parameter label (e.g. 'Druk [hPa]', 'O₂ [Vol. %]').
  final String label;

  /// The recorded measurement string or null when not yet captured.
  final String? value;

  const FlueGasField({
    required this.label,
    this.value,
  });

  /// The full ordered list of 21 flue-gas parameters matching the legacy
  /// Eurolyzer instrument data specification and preferred theme screenshots.
  static const List<FlueGasField> defaultFields = [
    FlueGasField(label: 'Brandstof'),
    FlueGasField(label: 'Datum'),
    FlueGasField(label: 'Tijd'),
    FlueGasField(label: 'Druk [hPa]'),
    FlueGasField(label: 'Temperatuur 1 [°C]'),
    FlueGasField(label: 'Temperatuur 2 [°C]'),
    FlueGasField(label: 'Temperatuurverschil [°C]'),
    FlueGasField(label: 'O₂ [Vol. %]'),
    FlueGasField(label: 'CO [ppm]'),
    FlueGasField(label: 'NO [ppm]'),
    FlueGasField(label: 'SO₂ [ppm]'),
    FlueGasField(label: 'CO₂ [Vol. %]'),
    FlueGasField(label: 'Rendement Hi [%]'),
    FlueGasField(label: 'Luchtovermaat'),
    FlueGasField(label: 'Verliezen [%]'),
    FlueGasField(label: 'CO (referentie) [ppm]'),
    FlueGasField(label: 'Dauwpunt [°C]'),
    FlueGasField(label: 'Keteltemperatuur [°C]'),
    FlueGasField(label: 'Druk [Pa]'),
    FlueGasField(label: 'Rendement Hs [%]'),
    FlueGasField(label: 'CO (referentie) [mg/kWh]'),
  ];

  /// Populates the 21 fields using the telemetry in [draft].
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
      const FlueGasField(label: 'Brandstof', value: 'Aardgas'),
      FlueGasField(
        label: 'Datum',
        value: DateTime.now().toIso8601String().substring(0, 10),
      ),
      FlueGasField(
        label: 'Tijd',
        value:
            '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
      ),
      FlueGasField(
        label: 'Druk [hPa]',
        value: draft.fluePressurePa != null
            ? (draft.fluePressurePa! / 100).toStringAsFixed(2)
            : null,
      ),
      FlueGasField(label: 'Temperatuur 1 [°C]', value: fmt(draft.flueTempTg)),
      FlueGasField(
          label: 'Temperatuur 2 [°C]', value: fmt(draft.ambientTempTa)),
      FlueGasField(
        label: 'Temperatuurverschil [°C]',
        value: fmt(draft.effectiveNetTemp),
      ),
      FlueGasField(label: 'O₂ [Vol. %]', value: fmt(draft.o2Percent)),
      FlueGasField(
        label: 'CO [ppm]',
        value: draft.coMgKwh != null
            ? (draft.coMgKwh! / 1.25).toStringAsFixed(0)
            : null,
      ),
      const FlueGasField(label: 'NO [ppm]'),
      const FlueGasField(label: 'SO₂ [ppm]'),
      FlueGasField(label: 'CO₂ [Vol. %]', value: fmt(draft.co2Percent)),
      FlueGasField(label: 'Rendement Hi [%]', value: fmt(draft.efficiencyHi)),
      FlueGasField(label: 'Luchtovermaat', value: lambda),
      FlueGasField(label: 'Verliezen [%]', value: losses),
      FlueGasField(
        label: 'CO (referentie) [ppm]',
        value: draft.coMgKwh != null
            ? (draft.coMgKwh! / 1.25).toStringAsFixed(0)
            : null,
      ),
      const FlueGasField(label: 'Dauwpunt [°C]'),
      const FlueGasField(label: 'Keteltemperatuur [°C]'),
      FlueGasField(label: 'Druk [Pa]', value: fmt(draft.fluePressurePa)),
      FlueGasField(label: 'Rendement Hs [%]', value: fmt(draft.efficiencyHs)),
      FlueGasField(
        label: 'CO (referentie) [mg/kWh]',
        value: fmt(draft.coMgKwh),
      ),
    ];
  }
}
