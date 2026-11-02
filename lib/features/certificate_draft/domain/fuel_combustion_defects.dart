// File: lib/features/certificate_draft/domain/fuel_combustion_defects.dart
// Responsibility: Statutory defect presets for burner, emissions, fuel supply, and electronics.
// Ordered strictly from most common to rare. Short, strong, no parentheses.

import 'statutory_defect_preset.dart';

/// Fuel, burner mechanics, emissions, and electronic controls presets.
const List<StatutoryDefectPreset> fuelCombustionDefects = [
  // 1. Branderdichting versleten
  StatutoryDefectPreset(
    id: 'burner_gasket_worn',
    title: 'Branderdichting versleten',
    defectText: 'Branderdichting versleten',
    measureText: 'Branderdichting vervangen',
    category: 'fuel',
    applicableFuels: ['gas', 'vloeibaar'],
  ),

  // 2. Ontstekingselektroden versleten
  StatutoryDefectPreset(
    id: 'gas_electrodes_worn',
    title: 'Elektroden versleten',
    defectText: 'Ontstekingselektroden versleten',
    measureText: 'Elektroden vervangen',
    category: 'fuel',
    applicableFuels: ['gas'],
  ),

  // 3. CO te hoog
  StatutoryDefectPreset(
    id: 'gas_co_exceeded',
    title: 'CO te hoog',
    defectText: 'CO te hoog',
    measureText: 'CO door fabrikant laten afregelen',
    category: 'fuel',
    applicableFuels: ['gas', 'vloeibaar'],
  ),

  // 4. Warmtewisselaar gecorrodeerd
  StatutoryDefectPreset(
    id: 'gas_exchanger_fouled',
    title: 'Warmtewisselaar gecorrodeerd',
    defectText: 'Warmtewisselaar gecorrodeerd',
    measureText: 'Warmtewisselaar reinigen of vervangen',
    category: 'fuel',
    applicableFuels: ['gas'],
  ),

  // 5. NTC-temperatuurvoeler verloopt
  StatutoryDefectPreset(
    id: 'ntc_sensor_defect',
    title: 'NTC-sensor verloopt',
    defectText: 'NTC-temperatuurvoeler verloopt',
    measureText: 'NTC-voeler vervangen',
    category: 'fuel',
  ),

  // 6. Rookgasventilator defect
  StatutoryDefectPreset(
    id: 'flue_fan_defect',
    title: 'Rookgasventilator defect',
    defectText: 'Rookgasventilator defect',
    measureText: 'Ventilator vervangen',
    category: 'fuel',
    applicableBoilerTypes: ['C'],
  ),

  // 7. Verbrandingsrendement te laag
  StatutoryDefectPreset(
    id: 'efficiency_too_low',
    title: 'Rendement te laag',
    defectText: 'Verbrandingsrendement te laag',
    measureText: 'Ketelrevisie of vervanging',
    category: 'fuel',
  ),

  // 8. Gasblok defect
  StatutoryDefectPreset(
    id: 'gas_valve_drift',
    title: 'Gasblok defect',
    defectText: 'Gasblok defect',
    measureText: 'Gasblok vervangen',
    category: 'fuel',
    applicableFuels: ['gas'],
  ),

  // 9. Elektronische printplaat storing
  StatutoryDefectPreset(
    id: 'pcb_control_defect',
    title: 'Printplaat defect',
    defectText: 'Elektronische printplaat defect',
    measureText: 'Printplaat vervangen',
    category: 'fuel',
  ),

  // 10. Toestelgaskraan ontbreekt
  StatutoryDefectPreset(
    id: 'gas_shutoff_valve_defect',
    title: 'Gaskraan ontbreekt',
    defectText: 'Toestelgaskraan ontbreekt',
    measureText: 'Conforme gaskraan plaatsen',
    category: 'fuel',
    applicableFuels: ['gas'],
  ),

  // 11. Roetgetal te hoog (Olie)
  StatutoryDefectPreset(
    id: 'oil_smoke_number_high',
    title: 'Roetgetal te hoog',
    defectText: 'Roetgetal te hoog',
    measureText: 'Branderrevisie uitvoeren',
    category: 'fuel',
    applicableFuels: ['vloeibaar'],
  ),

  // 12. Oliespoor op filter (Olie)
  StatutoryDefectPreset(
    id: 'oil_trace_detected',
    title: 'Oliespoor vastgesteld',
    defectText: 'Oliespoor vastgesteld',
    measureText: 'Branderkop en sproeier herstellen',
    category: 'fuel',
    applicableFuels: ['vloeibaar'],
  ),

  // 13. Brandstofpomp of leiding lekt (Olie)
  StatutoryDefectPreset(
    id: 'oil_leak_trace',
    title: 'Brandstofpomp lekt',
    defectText: 'Brandstofpomp of leiding lekt',
    measureText: 'Brandstoftoevoer herstellen',
    category: 'fuel',
    applicableFuels: ['vloeibaar'],
  ),

  // 14. Stookolietoevoer 2-pijps ombouw (Olie)
  StatutoryDefectPreset(
    id: 'oil_supply_twopipe',
    title: 'Stookolie 2-pijps ombouw',
    defectText: 'Stookolietoevoer 2-pijps',
    measureText: 'Ombouwen naar 1-pijps met ontluchter',
    category: 'fuel',
    applicableFuels: ['vloeibaar'],
  ),

  // 15. Stookolietank niet gekeurd (Olie)
  StatutoryDefectPreset(
    id: 'oil_tank_unapproved',
    title: 'Stookolietank niet gekeurd',
    defectText: 'Stookolietank niet gekeurd',
    measureText: 'Stookolietank laten keuren',
    category: 'fuel',
    applicableFuels: ['vloeibaar'],
  ),

  // 16. Deurdichting versleten (Vast)
  StatutoryDefectPreset(
    id: 'solid_door_gaskets_worn',
    title: 'Deurdichting versleten',
    defectText: 'Deurdichting versleten',
    measureText: 'Dichtingskoord vervangen',
    category: 'fuel',
    applicableFuels: ['vast'],
  ),

  // 17. Teerafzetting in schouw (Vast)
  StatutoryDefectPreset(
    id: 'solid_creosote_flue',
    title: 'Teer in schouw',
    defectText: 'Teerafzetting in schouw',
    measureText: 'Schoorsteen vegen of uitfrezen',
    category: 'fuel',
    applicableFuels: ['vast'],
  ),
];
