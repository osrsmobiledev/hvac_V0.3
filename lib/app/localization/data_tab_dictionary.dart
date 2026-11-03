// File: lib/app/localization/data_tab_dictionary.dart
// Responsibility: Official Flemish regulatory names for Tab 1 (Data) flue-gas telemetry fields.

/// Centralized statutory parameter names for Tab 1 (Data) flue gas measurements
/// matching the official Flemish Combustion Certificate (Verbrandingsattest Vlaanderen).
abstract final class DataTabDictionary {
  static const String lblBrandstof = 'Brandstof';
  static const String lblDrukHpa = 'Druk [hPa]';
  static const String lblFlueTempTg = 'Rookgastemperatuur (tg) [°C]';
  static const String lblAirTempTa = 'Temperatuur verbrandingslucht (ta) [°C]';
  static const String lblNetTemp = 'Nettotemperatuur (tg - ta) [°C]';
  static const String lblO2 = 'Zuurstof (O₂) [Vol. %]';
  static const String lblCoPpm = 'Koolstofmonoxide (CO) [ppm]';
  static const String lblNoPpm = 'Stikstofmonoxide (NO) [ppm]';
  static const String lblSo2Ppm = 'Zwaveldioxide (SO₂) [ppm]';
  static const String lblCo2 = 'Koolstofdioxide (CO₂) [Vol. %]';
  static const String lblEfficiencyHi = 'Verbrandingsrendement (Hi) [%]';
  static const String lblExcessAirLambda = 'Luchtovermaat (λ)';
  static const String lblLossesQa = 'Verbrandingsverliezen (qA) [%]';
  static const String lblCoRefPpm = 'Koolstofmonoxide (CO ref 0% O₂) [ppm]';
  static const String lblDewPoint = 'Dauwpunt temperatuur [°C]';
  static const String lblBoilerTemp = 'Keteltemperatuur [°C]';
  static const String lblFluePressurePa = 'Druk rookgasafvoerkanaal [Pa]';
  static const String lblEfficiencyHs = 'Verbrandingsrendement (Hs) [%]';
  static const String lblCoMgKwh = 'Koolstofmonoxide (CO) [mg/kWh]';
}
