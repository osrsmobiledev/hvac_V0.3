// File: lib/features/certificate_draft/domain/statutory_defect_preset.dart
// Responsibility: Domain model for statutory defect and remediation measure presets.

import 'statutory_defects_catalog.dart';

/// Preset defect and statutory remediation measure under Flemish decree (BVR Stooktoestellen Art. 6).
class StatutoryDefectPreset {
  final String id;
  final String title;
  final String defectText;
  final String measureText;
  final String category; // 'flue_vent', 'fuel', 'hydraulic'
  final List<String>
      applicableFuels; // 'gas', 'vloeibaar', 'vast', or empty for all
  final List<String> applicableBoilerTypes; // 'B', 'C', or empty for all

  const StatutoryDefectPreset({
    required this.id,
    required this.title,
    required this.defectText,
    required this.measureText,
    required this.category,
    this.applicableFuels = const [],
    this.applicableBoilerTypes = const [],
  });

  /// Evaluates whether this preset applies to the given fuel category and boiler type (B/C).
  bool appliesTo({required String fuel, required String boilerType}) {
    final cleanFuel = fuel.trim().toLowerCase();
    final cleanType = boilerType.trim().toUpperCase();

    if (applicableFuels.isNotEmpty && !applicableFuels.contains(cleanFuel)) {
      return false;
    }
    if (applicableBoilerTypes.isNotEmpty &&
        !applicableBoilerTypes.contains(cleanType)) {
      return false;
    }
    return true;
  }

  /// Filters presets matching the given fuel, boiler type, and optional category.
  static List<StatutoryDefectPreset> filter({
    required String fuel,
    required String boilerType,
    String? categoryFilter,
  }) {
    return statutoryDefectsCatalog.where((item) {
      if (!item.appliesTo(fuel: fuel, boilerType: boilerType)) {
        return false;
      }
      if (categoryFilter != null &&
          categoryFilter != 'all' &&
          item.category != categoryFilter) {
        return false;
      }
      return true;
    }).toList();
  }
}
