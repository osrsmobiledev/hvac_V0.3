// File: lib/features/certificate_draft/domain/flue_vent_defects.dart
// Responsibility: Statutory defect presets for boiler room, ventilation, flue gas, and chimney.
// Ordered strictly from most common to rare. Short, strong, no parentheses.

import 'statutory_defect_preset.dart';

/// Flue gas, chimney, and boiler room ventilation presets.
const List<StatutoryDefectPreset> flueVentDefects = [
  // 1. Concentrische rookgasbuis lekt
  StatutoryDefectPreset(
    id: 'concentric_recirculation_c',
    title: 'Concentrische buis lekt',
    defectText: 'Concentrische rookgasbuis lekt',
    measureText: 'Rookgasafvoer herstellen',
    category: 'flue_vent',
    applicableBoilerTypes: ['C'],
  ),

  // 2. Condensafvoer lekt of ontbreekt
  StatutoryDefectPreset(
    id: 'condensate_drain_c',
    title: 'Condensafvoer lekt',
    defectText: 'Condensafvoer lekt of ontbreekt',
    measureText: 'Condensafvoer herstellen',
    category: 'flue_vent',
    applicableBoilerTypes: ['C'],
  ),

  // 3. Condenssifon verstopt of lekt
  StatutoryDefectPreset(
    id: 'condensate_siphon_blocked',
    title: 'Condenssifon verstopt',
    defectText: 'Condenssifon verstopt of lekt',
    measureText: 'Condenssifon reinigen of vervangen',
    category: 'flue_vent',
    applicableBoilerTypes: ['C'],
  ),

  // 4. Stookplaats verluchting ontbreekt
  StatutoryDefectPreset(
    id: 'ventilation_type_b',
    title: 'Verluchting ontbreekt',
    defectText: 'Verluchting stookplaats ontbreekt',
    measureText: 'Boven- en onderverluchting plaatsen',
    category: 'flue_vent',
    applicableBoilerTypes: ['B'],
  ),

  // 5. Schouwtrek onvoldoende
  StatutoryDefectPreset(
    id: 'draft_type_b',
    title: 'Schouwtrek onvoldoende',
    defectText: 'Schouwtrek onvoldoende',
    measureText: 'Schoorsteen vegen of herstellen',
    category: 'flue_vent',
    applicableBoilerTypes: ['B'],
  ),

  // 6. Thermische terugslagbeveiliging defect
  StatutoryDefectPreset(
    id: 'ttb_safety_defect',
    title: 'TTB defect',
    defectText: 'Thermische terugslagbeveiliging defect',
    measureText: 'TTB-beveiliging herstellen',
    category: 'flue_vent',
    applicableBoilerTypes: ['B'],
  ),

  // 7. Afzuigkap in stookplaats
  StatutoryDefectPreset(
    id: 'extractor_type_b',
    title: 'Afzuigkap in stookplaats',
    defectText: 'Afzuigkap in stookplaats',
    measureText: 'Afzuigkap vergrendelen met ketel',
    category: 'flue_vent',
    applicableBoilerTypes: ['B'],
  ),

  // 8. Rookgasbuis beschadigd of los
  StatutoryDefectPreset(
    id: 'flue_pipe_corrosion_b',
    title: 'Rookgasbuis beschadigd',
    defectText: 'Rookgasbuis beschadigd of los',
    measureText: 'Rookgasbuis vervangen',
    category: 'flue_vent',
    applicableBoilerTypes: ['B'],
  ),

  // 9. Meetopeningen ontbreken
  StatutoryDefectPreset(
    id: 'missing_test_ports',
    title: 'Meetopeningen ontbreken',
    defectText: 'Meetopeningen ontbreken',
    measureText: 'Meetopeningen plaatsen',
    category: 'flue_vent',
  ),
];
