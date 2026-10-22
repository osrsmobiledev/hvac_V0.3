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
}
