// File: lib/features/certificate_draft/domain/statutory_defects_catalog.dart
// Responsibility: Combined, frequency-sorted catalog of defects that CANNOT be solved during routine maintenance.

import 'flue_vent_defects.dart';
import 'fuel_combustion_defects.dart';
import 'hydraulic_defects.dart';
import 'statutory_defect_preset.dart';

export 'flue_vent_defects.dart';
export 'fuel_combustion_defects.dart';
export 'hydraulic_defects.dart';

/// Complete curated catalog ordered strictly from most common to rare across all categories.
final List<StatutoryDefectPreset> statutoryDefectsCatalog =
    _buildOrderedCatalog();

List<StatutoryDefectPreset> _buildOrderedCatalog() {
  final Map<String, StatutoryDefectPreset> byId = {
    for (final p in [
      ...hydraulicDefects,
      ...fuelCombustionDefects,
      ...flueVentDefects,
    ])
      p.id: p,
  };

  const priorityOrder = [
    // --- Top Tier: Daily Field Issues (Most Common) ---
    'expansion_vessel_depleted',
    'burner_gasket_worn',
    'safety_valve_leaking',
    'concentric_recirculation_c',
    'gas_electrodes_worn',
    'auto_air_vent_leaking',
    'copper_pipes_corroded',
    'condensate_drain_c',
    'diverter_valve_defect',
    'gas_co_exceeded',
    'condensate_siphon_blocked',
    'gas_exchanger_fouled',
    'plate_exchanger_clogged',
    'ntc_sensor_defect',
    'flue_fan_defect',
    'circulator_pump_defect',
    'efficiency_too_low',
    'gas_valve_drift',
    'pcb_control_defect',

    // --- Atmospheric (Type B) & Gas Supply ---
    'ventilation_type_b',
    'draft_type_b',
    'ttb_safety_defect',
    'extractor_type_b',
    'gas_shutoff_valve_defect',
    'flue_pipe_corrosion_b',

    // --- Fuel Specific: Oil & Solid ---
    'oil_smoke_number_high',
    'oil_trace_detected',
    'oil_leak_trace',
    'oil_supply_twopipe',
    'oil_tank_unapproved',
    'solid_door_gaskets_worn',
    'solid_creosote_flue',

    // --- Rare / Specialized ---
    'missing_test_ports',
  ];

  final List<StatutoryDefectPreset> result = [];
  for (final id in priorityOrder) {
    final preset = byId[id];
    if (preset != null) {
      result.add(preset);
    }
  }
  return List.unmodifiable(result);
}
