/// Centralized Single Source of Truth for Dutch (Flemish) UI strings.
/// Ensures compliance with official VEKA terminology.
abstract final class AppDictionary {
  // --- General App Shell & Dashboard ---
  static const String appTitle = 'HVAC Field Service';
  static const String dashboardTitle = 'Kies een applet';
  static const String themePreviewTitle = 'BO2 Tactical HUD Preview';

  // --- Drawer Menu ---
  static const String menuStart = 'Start';
  static const String menuCombustion = 'Verbrandingsattest Vlaanderen';
  static const String menuCleaning = 'Reinigingsattest Vlaanderen';
  static const String menuInspection = 'Keuringsrapport Vlaanderen';
  static const String menuMeasurement = 'Meetrapport';

  // --- Applet Descriptions (Home Dashboard) ---
  static const String descCombustion =
      'Gasketel & Stookolie periodieke controle conform VEKA normen.';
  static const String descCleaning =
      'Periodiek schoorsteenveeg- en reinigingsattest.';
  static const String descInspection =
      'Keuringsrapport voor eerste ingebruikname van installaties.';
  static const String descMeasurement =
      'Digitale rookgas- en drukmetingen via Eurolyzer bluetooth.';

  // --- Common Actions & Buttons ---
  static const String btnSave = 'Opslaan';
  static const String btnCancel = 'Annuleren';
  static const String btnConfirm = 'Bevestigen';
  static const String btnNext = 'Volgende';
  static const String btnBack = 'Vorige';

  // --- Telemetry & Data Headers ---
  static const String headerMeasurement = 'Meetgegevens Bluetooth';
  static const String headerFluegas = 'Rookgas Analyse';

  // --- Verbrandingsattest Applet Tabs ---
  static const List<String> combustionTabs = [
    'Data',
    'Start',
    'Firma - Technicus',
    'Klant',
    'Stooktoestel',
    'Meting',
    'Eindbeoordeling',
  ];

  // --- Setup / Start Tab ---
  static const String lblSequenceNumber = 'Volgnummer attest';
  static const String activityCommissioning =
      'Keuring voor eerste ingebruikname';
  static const String activityMaintenance = 'Onderhoud';

  // --- Firma & Technicus Tab ---
  static const String lblCompanyName = 'Naam Firma';
  static const String lblKBO = 'Ondernemingsnummer (KBO)';
  static const String lblTechFirstName = 'Voornaam Technicus';
  static const String lblTechLastName = 'Achternaam Technicus';
  static const String lblGV = 'Erkenningsnummer GV';
  static const String lblTV = 'Erkenningsnummer TV';
  static const String lblDate = 'Datum onderhoud';
  static const String lblTimeFrom = 'Arbeidsduur van';
  static const String lblTimeTo = 'tot';

  // --- Klant & Installatieadres Tab ---
  static const String headerCustomerDetails = 'Klantgegevens';
  static const String headerInstallationAddress = 'Installatieadres';
  static const String subInstallationAddress =
      '(indien afwijkend van adres klant)';
  static const String btnChooseCustomer = 'Kies bestaande klant';
  static const String btnNewCustomer = 'Nieuwe klant';
  static const String searchCustomerHint = 'Zoek op naam, bedrijf, stad...';
  static const String roleOwner = 'Eigenaar';
  static const String roleTenant = 'Huurder';
  static const String lblSameAsCustomerAddress =
      'Installatieadres is hetzelfde als klantadres';
}
