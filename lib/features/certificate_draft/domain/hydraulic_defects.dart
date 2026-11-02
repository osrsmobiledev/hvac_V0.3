// File: lib/features/certificate_draft/domain/hydraulic_defects.dart
// Responsibility: Statutory defect presets for hydraulic components, safety, and domestic hot water.
// Ordered strictly from most common to rare. Short, strong, no parentheses.

import 'statutory_defect_preset.dart';

/// Hydraulic and water circuit presets.
const List<StatutoryDefectPreset> hydraulicDefects = [
  // 1. Expansievat defect
  StatutoryDefectPreset(
    id: 'expansion_vessel_depleted',
    title: 'Expansievat defect',
    defectText: 'Expansievat membraan gescheurd',
    measureText: 'Expansievat vervangen',
    category: 'hydraulic',
  ),

  // 2. Veiligheidsklep 3 bar lekt
  StatutoryDefectPreset(
    id: 'safety_valve_leaking',
    title: 'Veiligheidsklep lekt',
    defectText: 'Veiligheidsklep 3 bar lekt',
    measureText: 'Veiligheidsklep vervangen',
    category: 'hydraulic',
  ),

  // 3. Automatische ontluchter lekt
  StatutoryDefectPreset(
    id: 'auto_air_vent_leaking',
    title: 'Ontluchter lekt',
    defectText: 'Automatische ontluchter lekt',
    measureText: 'Ontluchter vervangen',
    category: 'hydraulic',
  ),

  // 4. Koperleidingen gecorrodeerd door interne lekkage
  StatutoryDefectPreset(
    id: 'copper_pipes_corroded',
    title: 'Koper gecorrodeerd',
    defectText: 'Koperleidingen gecorrodeerd',
    measureText: 'Lek dichten en leiding vervangen',
    category: 'hydraulic',
  ),

  // 4. Driewegklep defect of lekt
  StatutoryDefectPreset(
    id: 'diverter_valve_defect',
    title: 'Driewegklep defect',
    defectText: 'Driewegklep defect of lekt',
    measureText: 'Driewegklep herstellen of vervangen',
    category: 'hydraulic',
  ),

  // 5. Platenwarmtewisselaar verkalkt
  StatutoryDefectPreset(
    id: 'plate_exchanger_clogged',
    title: 'Platenwisselaar verkalkt',
    defectText: 'Platenwisselaar verkalkt',
    measureText: 'Platenwisselaar ontkalken of vervangen',
    category: 'hydraulic',
  ),

  // 6. Circulatiepomp defect
  StatutoryDefectPreset(
    id: 'circulator_pump_defect',
    title: 'Circulatiepomp defect',
    defectText: 'Circulatiepomp defect',
    measureText: 'Circulatiepomp vervangen',
    category: 'hydraulic',
  ),
];
