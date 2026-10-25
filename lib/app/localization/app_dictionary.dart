/// Centralized Single Source of Truth for Dutch (Flemish) UI strings.
/// Ensures compliance with official VEKA terminology.
abstract final class AppDictionary {
  // --- General App Shell & Dashboard ---
  static const String appBrand = 'HVAC';
  static const String appTitle = 'HVAC Field Service';
  static const String dashboardTitle = 'Kies een applet';
  static const String themePreviewTitle = 'BO2 Tactical HUD Preview';

  // --- Drawer Menu & Section Headers ---
  static const String sectionDashboard = 'DASHBOARD';
  static const String sectionApplets = 'APPLETS';
  static const String sectionManage = 'BEHEER';
  static const String menuStart = 'Start';
  static const String menuCombustion = 'Verbrandingsattest Vlaanderen';
  static const String menuCombustionMultiLine =
      'Verbrandingsattest\nVlaanderen';
  static const String menuCleaning = 'Reinigingsattest Vlaanderen';
  static const String menuCleaningMultiLine = 'Reinigingsattest\nVlaanderen';
  static const String menuInspection = 'Keuringsrapport Vlaanderen';
  static const String menuInspectionMultiLine = 'Keuringsrapport\nVlaanderen';
  static const String menuMeasurement = 'Meetrapport';
  static const String menuTechSettings = 'Instellingen Technicus';
  static const String menuImportExport = 'Import / Export';
  static const String titleCombustionLine1 = 'Verbrandingsattest';
  static const String titleCombustionLine2 = 'Vlaanderen';
  static const String lblActive = 'Actief';
  static const String tooltipOpenMenu = 'Menu openen';
  static const String tooltipCloseMenu = 'Menu sluiten';

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
  static const String btnSearch = 'Zoeken';
  static const String btnNew = 'Nieuw';
  static const String btnEdit = 'Bewerken';
  static const String btnDelete = 'Wissen';
  static const String btnOk = 'OK';
  static const String btnBackToDashboard = 'Terug naar dashboard';

  // --- Placeholders & Construction ---
  static const String placeholderUnderConstruction =
      'Deze module wordt gebouwd in latere milestones.';

  // --- Telemetry & Data Headers ---
  static const String headerMeasurement = 'Meetgegevens Bluetooth';
  static const String headerFluegas = 'Rookgas Analyse';
  static const String headerMeetgegevens = 'Meetgegevens';
  static const String headerRookgassen = 'Rookgassen';
  static const String tooltipScanEurolyzerQr = 'Eurolyzer QR scannen';

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
  static const String headerActivity = 'Activiteit';
  static const String lblSequenceNumber = 'Volgnummer Attest';
  static const String activityCommissioning =
      'Keuring voor eerste ingebruikname';
  static const String activityCommissioningShort = 'Keuring';
  static const String captionCommissioning = '* vóór 1e ingebruikname';
  static const String activityMaintenance = 'Onderhoud';

  // --- Start Tab Info Section ---
  static const String headerActivityInfo = 'Info & Regelgeving';
  static const String infoMaintenanceSubtitle =
      'Periodieke controle & reiniging';
  static const String infoMaintenancePoint1 =
      '2-jaarlijks voor gas (vanaf 20 kW), jaarlijks voor stookolie.';
  static const String infoMaintenancePoint2 =
      'Reiniging ketel & schoorsteen + verbrandingsmeting.';
  static const String infoMaintenancePoint3 =
      'Resulteert in Reinigings- én Verbrandingsattest.';
  static const String infoCommissioningSubtitle =
      'Vóór eerste ingebruikname (VEKA)';
  static const String infoCommissioningPoint1 =
      'Wettelijk verplicht bij nieuwe ketel of ketelvervanging.';
  static const String infoCommissioningPoint2 =
      'Controle van verluchting, rookgasafvoer en normen.';
  static const String infoCommissioningPoint3 =
      'Resulteert in officieel Keuringsrapport vóór opstart.';
  static const String badgeSelected = 'Actief';

  // --- Firma & Technicus Tab ---
  static const String lblCompanyName = 'Naam Firma';
  static const String lblKBO = 'Ondernemingsnummer (KBO)';
  static const String lblTechFirstName = 'Voornaam';
  static const String lblTechLastName = 'Achternaam';
  static const String lblGV = 'GV-nummer';
  static const String lblTV = 'TV-nummer';
  static const String lblDate = 'Datum onderhoud';
  static const String lblTimeFrom = 'Arbeidsduur van';
  static const String lblTimeTo = 'tot';
  static const String lblSetTime = 'Tijd instellen';
  static const String lblHours = 'UREN';
  static const String lblMinutes = 'MINUTEN';

  // --- Klant & Installatieadres Tab ---
  static const String headerCustomerDetails = 'Klantgegevens';
  static const String headerInstallationAddress = 'Locatie Toestel';
  static const String headerApplianceLocation = 'Locatie Toestel';
  static const String subInstallationAddress =
      '(indien afwijkend van adres klant)';
  static const String btnChooseCustomer = 'Kies bestaande klant';
  static const String btnNewCustomer = 'Nieuwe klant';
  static const String searchCustomerHint = 'Zoek klanten';
  static const String roleOwner = 'Eigenaar';
  static const String roleTenant = 'Huurder';
  static const String lblSameAsCustomerAddress =
      'Installatieadres is hetzelfde als klantadres';
  static const String lblEffectiveLocation = 'Effectieve installatielocatie';
  static const String lblNoAddressFilled = 'Geen adres ingevuld';
  static const String lblSourceCustomerAddress = 'Bron: Klantadres';
  static const String lblSourceSeparateAddress =
      'Bron: Afzonderlijk installatieadres';
  static const String lblStreetInstallation = 'Straat (Installatie)';

  // --- Klant Field Labels & Hints ---
  static const String lblCompanyOrCustomerOptional =
      'Bedrijfsnaam / Klant (Optioneel)';
  static const String hintCompany = 'Bv. VME Apollo';
  static const String lblFirstName = 'Voornaam';
  static const String hintFirstName = 'bv. Jan';
  static const String lblLastName = 'Achternaam';
  static const String hintLastName = 'bv. Janssens';
  static const String lblStreet = 'Straat';
  static const String hintSearchAddress = 'Zoek adres (bv. Veldstraat 14)';
  static const String lblHouseNumber = 'Nr';
  static const String hintHouseNumber = '17B';
  static const String lblBox = 'Bus';
  static const String hintBox = '0201';
  static const String lblPostalCode = 'Postcode';
  static const String hintPostalCode = '9000';
  static const String lblCity = 'Gemeente';
  static const String hintCity = 'Gent';
  static const String lblPhone = 'Tel';
  static const String hintPhone = '470 12 34 56';
  static const String lblEmail = 'Email';
  static const String hintEmail = 'klant@mail.be';

  // --- Klant Action Dialogs (Preferred Theme) ---
  static const String dlgNewCustomerTitle = 'Nieuw';
  static const String dlgNewCustomerContent =
      'Wilt u een nieuwe klant aanmaken?';
  static const String dlgEditCustomerTitle = 'Bewerken';
  static const String dlgEditCustomerContent =
      'Wilt u de geselecteerde klant bewerken?';
  static const String dlgCancelEditTitle = 'Herstellen';
  static const String dlgCancelEditContent =
      'Wilt u de wijzigingen ongedaan maken?';
  static const String dlgDeleteCustomerTitle = 'Klant Wissen';
  static const String dlgDeleteCustomerContent =
      'Weet u zeker dat u deze klantengegevens volledig wilt wissen van dit attest?';
  static const String dlgDeleteConfirm = 'Ja, Wissen';
  static const String dlgYes = 'Ja';
  static const String dlgNo = 'Nee';
  static const String dlgClose = 'Sluiten';
  static const String dlgSearchCustomerTitle = 'Kies bestaande klant';
  static const String dlgDeleteFromDbTitle = 'Klant Verwijderen';
  static const String dlgDeleteFromDbContent =
      'Weet u zeker dat u deze klant definitief wilt verwijderen uit de database?';
  static const String dlgDeleteFromDbConfirm = 'Verwijderen';
  static const String toastCustomerSaved = 'Klant Opgeslagen';
  static const String toastCustomerDeleted = 'Klant verwijderd uit database';
  static const String lblNoCustomersInDb =
      'Geen opgeslagen klanten in de database.';
  static const String lblNoCustomersMatching = 'Geen klanten gevonden voor';
  static const String lblExistingCustomers = 'Bestaande klanten';
}
