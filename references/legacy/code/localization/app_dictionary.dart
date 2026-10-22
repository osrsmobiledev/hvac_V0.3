// File: lib/core/localization/app_dictionary.dart
// Line Count: ~25 lines
// Responsibility: Single Source of Truth for UI strings, ensuring VEKA/Flemish legal compliance.

class AppDictionary {
  // TUNE HERE [UI/UX]: General App Shell
  static const String appTitle = 'HVAC Field Service';
  static const String dashboardTitle = 'Kies een applet'; // "Choose your applet"
  
  // TUNE HERE [UI/UX]: Drawer Menu
  static const String menuStart = 'Start';
  static const String menuCombustion = 'Verbrandingsattest Vlaanderen';
  static const String menuCleaning = 'Reinigingsattest Vlaanderen';
  static const String menuInspection = 'Keuringsrapport Vlaanderen';
  static const String menuMeasurement = 'Meetrapport';

  // TUNE HERE [UI/UX]: Common Buttons & Alerts
  static const String btnSave = 'Opslaan';
  static const String btnCancel = 'Annuleren';

  // TUNE HERE [UI/UX]: Telemetry & Data Tab (Official VEKA/Flemish terminology)
  static const String headerMeasurement = 'Meetgegevens Bluetooth';
  static const String headerFluegas = 'Rookgas Analyse';
  
  // Mapped directly from the official Verbrandingsattest template
  static const List<String> fluegasFields = [
    'Brandstof', 'Datum', 'Tijd', 'Druk (Pa)', 'Temperatuur 1', 
    'Temperatuur 2', 'Nettotemperatuur (tg - ta)', 'Zuurstof (O2)', 'Koolstofmonoxide (CO)', 
    'Stikstofmonoxide (NO)', 'Zwaveldioxide (SO2)', 'Koolstofdioxide (CO2)', 
    'Verbrandingsrendement (Hi)', 'Luchtoverschot', 'Verlies', 'CO (gecorrigeerd)', 
    'Dauwpunt', 'Keteltemperatuur', 'Trek', 'Verbrandingsrendement (Hs)'
  ];

  // TUNE HERE [UI/UX]: Applet Tab Navigation (Dutch UI)
  // FAIL-SAFE [SECURITY/RELIABILITY]: Exactly 6 tabs matching combustion_shell_screen PageView index 0..5
  static const List<String> combustionTabs = [
    'Start',
    'Firma',
    'Klant',
    'Toestel',
    'Meting',
    'Besluit',
  ];

  // TUNE HERE [UI/UX]: Setup Tab (VEKA API Strict Compliance)
  static const String lblSequenceNumber = 'Volgnummer attest';
  static const String activityCommissioning = 'Keuring voor eerste ingebruikname';
  static const String activityMaintenance = 'Onderhoud';

  // TUNE HERE [UI/UX]: Firma & Technicus Tab (VEKA Schema)
  static const String lblCompanyName = 'Naam Firma';
  static const String lblKBO = 'Ondernemingsnummer (KBO)';
  static const String lblTechFirstName = 'Voornaam Technicus';
  static const String lblTechLastName = 'Achternaam Technicus';
  static const String lblGV = 'Erkenningsnummer GV';
  static const String lblTV = 'Erkenningsnummer TV';
  static const String lblDate = 'Datum onderhoud';
  static const String lblTimeFrom = 'Arbeidsduur van';
  static const String lblTimeTo = 'tot';
}