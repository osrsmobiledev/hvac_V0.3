/// Centralized Single Source of Truth for Dutch (Flemish) UI strings.
/// Ensures compliance with official VEKA terminology.
abstract final class AppDictionary {
  // --- General App Shell & Dashboard ---
  static const String appBrand = 'HVAC';
  static const String appTitle = 'HVAC Field Service';
  static const String dashboardTitle = 'Kies een applet';

  // --- Drawer Menu & Navigation ---
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
  static const String tooltipOpenMenu = 'Menu openen';
  static const String tooltipCloseMenu = 'Menu sluiten';

  // --- Common Actions & Buttons ---
  static const String btnSave = 'Opslaan';
  static const String btnCancel = 'Annuleren';
  static const String btnBack = 'Vorige';
  static const String btnSearch = 'Zoeken';
  static const String btnNew = 'Nieuw';
  static const String btnEdit = 'Bewerken';
  static const String btnDelete = 'Wissen';
  static const String btnOk = 'OK';
  static const String btnBackToDashboard = 'Terug naar dashboard';
  static const String placeholderUnderConstruction =
      'Deze module wordt gebouwd in latere milestones.';

  // --- Telemetry & Data Headers ---
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
    'Eindbeoordeling'
  ];

  // --- Setup / Start Tab ---
  static const String headerActivity = 'Activiteit';
  static const String lblSequenceNumber = 'Volgnummer Attest';
  static const String activityCommissioningShort = 'Keuring';
  static const String captionCommissioning = '* vóór 1e ingebruikname';
  static const String activityMaintenance = 'Onderhoud';

  // --- Firma & Technicus Tab ---
  static const String headerFirma = 'Firma';
  static const String headerTechnicus = 'Technicus';
  static const String lblCompanyName = 'Naam Firma';
  static const String lblKBO = 'Ondernemingsnummer (KBO)';
  static const String lblGV = 'GV-nummer';
  static const String lblTV = 'TV-nummer';
  static const String lblDate = 'Datum onderhoud';
  static const String lblTimeFrom = 'Arbeidsduur van';
  static const String lblTimeTo = 'tot';
  static const String lblSetTime = 'Tijd instellen';
  static const String lblHours = 'UREN';
  static const String lblMinutes = 'MINUTEN';
  static const String hintCompanyName = 'bv. HVAC Solutions BV';
  static const String hintCompanyEmail = 'info@hvac.be';
  static const String hintCompanyKbo = '0123.456.789';
  static const String hintTechFirstName = 'bv. Jan';
  static const String hintTechLastName = 'bv. Janssens';
  static const String hintGvNumber = 'GV01234';
  static const String hintTvNumber = 'TV01234';
  static const String hintDateFormat = 'JJJJ-MM-DD';
  static const String hintTimeStart = '08:00';
  static const String hintTimeEnd = '10:00';

  // --- Klant & Installatieadres Tab ---
  static const String headerCustomerDetails = 'Klantgegevens';
  static const String headerApplianceLocation = 'Locatie Toestel';
  static const String searchCustomerHint = 'Zoek klanten';
  static const String lblSameAsCustomerAddress =
      'Installatieadres is hetzelfde als klantadres';
  static const String lblEffectiveLocation = 'Effectieve installatielocatie';
  static const String lblNoAddressFilled = 'Geen adres ingevuld';
  static const String lblSourceCustomerAddress = 'Bron: Klantadres';
  static const String lblSourceSeparateAddress =
      'Bron: Afzonderlijk installatieadres';
  static const String lblStreetInstallation = 'Straat (Installatie)';
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

  // --- Klant Action Dialogs ---
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

  // --- Stooktoestel Tab (Kenmerken, Toestel, Brander) ---
  static const String headerKenmerken = 'Kenmerken';
  static const String lblCentraal = 'Centraal (*)';
  static const String footnoteCentraal = '* indeling volgens NBN CR 1749';
  static const String suffixOpen = '(open)';
  static const String suffixClosed = '(gesloten)';
  static const String lblConnected = 'aangesloten';
  static const String lblAsTypeB = 'als type B';
  static const String lblAsTypeC = 'als type C';
  static const String hintSubtypeB = '11';
  static const String hintSubtypeC = '13';
  static const String lblHeatingType = 'Type verwarming';
  static const String optIndividual = 'Individueel';
  static const String optCollective = 'Collectief';
  static const String optUnknown = 'Onbekend';
  static const String lblOperation = 'Werking ketel';
  static const String optCondensing = 'Condenserend';
  static const String optNonCondensing = 'Niet-condenserend';
  static const String headerFuel = 'Brandstof';
  static const String fuelGasShort = 'Gasvormig';
  static const String fuelLiquidShort = 'Vloeibaar';
  static const String fuelSolidShort = 'Vast';
  static const String headerGasDetails = 'Gastype & Brandstofdetail';
  static const String gasNatural = 'aardgas';
  static const String gasLpg = 'LPG';
  static const String gasOther = 'Andere gas';
  static const String hintSpecifyGas = 'Specifieer gassoort...';
  static const String headerBurnerTech = 'Brandertechnologie (NBN / VEKA)';
  static const String techNonPremix = 'niet premix (GI)';
  static const String techPremix = 'premix (GI)';
  static const String techFanBurner = 'gasketel met ventilatorbrander (GII)';
  static const String headerSolidSubtype = 'Vaste brandstof subtype';
  static const String solidPellets = 'houtpellets';
  static const String solidLogs = 'houtblokken';
  static const String solidOther = 'Andere biomassa';
  static const String hintSpecifySolid = 'Specifieer vaste brandstof...';
  static const String headerAppliance = 'Toestel';
  static const String headerBurner = 'Brander';
  static const String subBurner = '(enkel CV)';
  static const String optBurnerIntegrated = 'Geïntegreerd';
  static const String optBurnerSeparate = 'Afzonderlijke brander';
  static const String lblBurnerIntegratedBadge = 'Geïntegreerde brander';
  static const String descBurnerIntegrated =
      'De brander maakt integraal deel uit van de ketel. Gegevens worden automatisch overgenomen voor het attest en VEKA.';
  static const String lblBrand = 'Merk';
  static const String lblModel = 'Type / Model';
  static const String lblConstructionYear = 'Bouwjaar';
  static const String lblSerialNumber = 'Fabricatienummer';
  static const String lblNominalPower = 'Nominaal vermogen (kW)';
  static const String lblFlowRate = 'Debiet (kW of kg/h of l/h of m³/h)';
  static const String tooltipScanBarcode = 'Scan barcode';
  static const String barcodeScannerPlaceholder =
      'Barcode scanner wordt later geactiveerd';
  static const String hintBoilerBrand = 'bv. Vaillant, Viessmann, Remeha';
  static const String hintBoilerModel = 'bv. ecoTEC plus VHR';
  static const String hintBoilerYear = 'bv. 2021';
  static const String hintBoilerSerial = 'bv. 2119230010023456';
  static const String hintBoilerPower = 'bv. 24.5';
  static const String hintBurnerBrand = 'bv. Weishaupt, Riello, Elco';
  static const String hintBurnerModel = 'bv. WL5/1-B';
  static const String hintBurnerYear = 'bv. 2019';
  static const String hintBurnerSerial = 'bv. 893475102';
  static const String hintBurnerFlowRate = 'bv. 2.4 kg/h of 28 kW';

  // --- Applet Titles & Placeholders ---
  static const String appletTitleVerbrandingsattest = 'Verbrandingsattest';
  static const String appletTitleReinigingsattest = 'Reinigingsattest';
  static const String appletTitleKeuringsrapport = 'Keuringsrapport';
  static const String appletTitleMeetrapport = 'Meetrapport';
  static const String appletSubtitleVlaanderen = 'Vlaanderen';
  static const String hintScanToestelSerial = 'Scan Toestel Fabricatienummer';
  static const String hintScanBranderSerial = 'Scan Brander Fabricatienummer';
  static const String placeholderQrScannerPending =
      'Eurolyzer QR Scanner wordt geactiveerd in Slice 3.2';
}
