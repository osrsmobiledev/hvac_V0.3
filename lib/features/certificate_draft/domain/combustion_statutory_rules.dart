import 'boiler_draft.dart';

/// Flemish statutory combustion emission and efficiency rules.
///
/// Implements statutory evaluation rules according to:
/// - Flemish Government Decree of 8 December 2006 (Stooktoestellenbesluit)
/// - VLAREM II (Art. 5.43.2.1 & 5.43.3.1)
/// - VEKA Meldingen API ("verbrandingscontrole": "OK" / "NOK")
///
/// Statutory Limits:
/// 1. Carbon Monoxide (CO):
///    - Gas: <= 150 mg/kWh (undiluted at 0% O2 reference)
///    - Liquid fuel (stookolie): <= 150 mg/kWh
///    - Solid fuel (hout/pellets): <= 500 mg/m3 / NBN EN 303-5
///
/// 2. Net Efficiency Hi (Verbrandingsrendement Hi):
///    - Liquid fuel (stookolie): >= 90.0%
///    - Gas - Type B1 (atmospheric open flued with draft hood): >= 88.0%
///    - Gas - Type C (room-sealed) & Type B2 (fan-assisted): >= 90.0%
///    - Solid fuel: >= 80.0%
abstract final class CombustionStatutoryRules {
  /// Maximum legal CO limit in mg/kWh for the given boiler configuration.
  static double maxCoMgKwh(BoilerDraft boiler) {
    if (boiler.fuelCategory == 'vast') {
      return 500.0;
    }
    return 150.0;
  }

  /// Minimum legal combustion efficiency Hi percentage for the given boiler configuration.
  static double minEfficiencyHi(BoilerDraft boiler) {
    if (boiler.fuelCategory == 'vloeibaar') {
      return 90.0;
    }
    if (boiler.fuelCategory == 'vast') {
      return 80.0;
    }
    // Gas: Under VLAREM II, only B1 appliances (with draft hood / natural draft)
    // require min 88%. Non-B1 appliances (Type C, and Type B2 like B22/B23/B23P
    // with mechanical fan and no draft hood) must meet min 90%.
    if (boiler.centraalType == 'B') {
      final sub = boiler.typeBText.trim().toUpperCase();
      final bool isB1 =
          sub.isEmpty || sub.startsWith('1') || sub.startsWith('B1');
      if (isB1) {
        return 88.0;
      }
      return 90.0;
    }
    return 90.0;
  }

  /// Evaluates whether a CO measurement (mg/kWh) complies with the statutory norm.
  /// Returns null if [coMgKwh] is null.
  static bool? evaluateCo(double? coMgKwh, BoilerDraft boiler) {
    if (coMgKwh == null) return null;
    return coMgKwh <= maxCoMgKwh(boiler);
  }

  /// Evaluates whether an efficiency Hi measurement (%) complies with the statutory norm.
  /// Returns null if [efficiencyHi] is null.
  static bool? evaluateEfficiencyHi(double? efficiencyHi, BoilerDraft boiler) {
    if (efficiencyHi == null) return null;
    return efficiencyHi >= minEfficiencyHi(boiler);
  }

  /// Helper to safely parse a Dutch or international numeric string,
  /// stripping any trailing unit symbols (e.g. `%`, `°C`, `mg/kWh`).
  static double? parseNumeric(String? text) {
    if (text == null) return null;
    final cleaned =
        text.replaceAll(RegExp(r'[^0-9.,\-]'), '').replaceAll(',', '.').trim();
    return double.tryParse(cleaned);
  }
}
