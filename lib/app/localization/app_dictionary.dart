export 'basisregisters_dictionary.dart';
export 'data_tab_dictionary.dart';
export 'meting_dictionary.dart';

/// Centralized Single Source of Truth for Dutch (Flemish) UI strings.
/// Ensures compliance with official VEKA terminology.
abstract final class AppDictionary {
  // --- General App Shell & Dashboard ---
  static const String appBrand = 'HVAC';
  static const String appTitle = 'HVAC Field Service';
  static const String dashboardTitle = 'Kies een applet';
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
  static const String menuTechSettings = 'Instellingen';
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
      'Module wordt gebouwd in latere milestones.';
  // --- Telemetry & Data Headers ---
  static const String headerMeetgegevens = 'Meetgegevens';
  static const String headerRookgassen = 'Rookgassen';
  static const String tooltipScanEurolyzerQr = 'Eurolyzer QR scannen';

  // --- Verbrandingsattest Applet Tabs ---
  static const String tabEindbeoordeling = 'Eindbeoordeling';
  static const List<String> combustionTabs = [
    'Data',
    'Start',
    'Firma - Technicus',
    'Klant',
    'Stooktoestel',
    'Meting',
    tabEindbeoordeling
  ];

  // --- Setup / Start Tab ---
  static const String headerActivity = 'Activiteit';
  static const String lblSequenceNumber = 'Volgnummer Attest';
  static const String hintSequenceNumber = 'bv. 2026-001';
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
  static const String lblAnalyzerBrand = 'Type / merk meettoestel';
  static const String lblAnalyzerSerial = 'Serienummer meettoestel';
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
  static const String hintAnalyzerBrand = 'bv. Eurolyzer S1, Testo 300';
  static const String hintAnalyzerSerial = 'bv. 06-52-01055';
  static const String hintDateFormat = 'JJJJ-MM-DD';
  static const String hintTimeStart = '08:00';
  static const String hintTimeEnd = '10:00';

  // --- Klant & Installatieadres Tab ---
  static const String headerCustomerDetails = 'Klantgegevens';
  static const String headerApplianceLocation = 'Locatie Toestel';
  static const String searchCustomerHint = 'Zoek klanten';
  static const String lblSameAsCustomerAddress = 'Zelfde als klantadres';
  static const String lblSeparateInstallationAddress =
      'Afwijkend installatieadres';
  static const String subSeparateInstallationAddress =
      'Ketel staat op ander adres dan klantadres';
  static const String descSameAsCustomerEmpty =
      'Overgenomen van klantgegevens hierboven.';
  static const String lblEffectiveLocation = 'Effectieve installatielocatie';
  static const String lblNoAddressFilled = 'Geen adres ingevuld';
  static const String lblSourceCustomerAddress = 'Bron: Klantadres';
  static const String lblSourceSeparateAddress = 'Bron: Afzonderlijk adres';
  static const String lblStreetInstallation = 'Straat (Installatie)';
  static const String lblCompanyOrCustomerOptional =
      'Bedrijf / Klant (Optioneel)';
  static const String hintCompany = 'Bv. VME Apollo';
  static const String lblFirstName = 'Voornaam';
  static const String hintFirstName = 'bv. Jan';
  static const String lblLastName = 'Achternaam';
  static const String hintLastName = 'bv. Peeters';
  static const String lblStreet = 'Straat';
  static const String hintStreet = 'bv. Kerkstraat';
  static const String hintSearchAddress = 'Zoek adres (bv. Veldstraat 14)';
  static const String lblHouseNumber = 'Nr.';
  static const String hintHouseNumber = '10';
  static const String lblBox = 'Bus';
  static const String hintBox = '2B';
  static const String lblPostalCode = 'Postcode';
  static const String hintPostalCode = '9000';
  static const String lblCity = 'Gemeente';
  static const String hintCity = 'Gent';
  static const String lblPhone = 'Telefoon';
  static const String hintPhone = '0470 12 34 56';
  static const String lblEmail = 'E-mail';
  static const String hintEmail = 'klant@voorbeeld.be';
  static const String lblRole = 'Rol klant';
  static const String roleOwner = 'Eigenaar';
  static const String roleTenant = 'Huurder';
  static const String valLastNameOrCompanyRequired =
      'Vul een achternaam of bedrijfsnaam in.';
  static const String valInvalidEmail = 'Ongeldig e-mailadres';
  static const String valInvalidPostalCode = 'Postcode moet 4 cijfers zijn';
  static const String dlgNewCustomerTitle = 'Nieuwe Klant Aanmaken';
  static const String dlgNewCustomerContent =
      'Formulier leegmaken voor nieuwe klant?';
  static const String dlgNewCustomerConfirm = 'Nieuw Formulier';
  static const String dlgEditCustomerTitle = 'Klant Bewerken';
  static const String dlgEditCustomerContent = 'Klantgegevens aanpassen?';
  static const String dlgEditCustomerConfirm = 'Bewerken';
  static const String dlgCancelEditTitle = 'Bewerking Annuleren';
  static const String dlgCancelEditContent =
      'Niet-opgeslagen wijzigingen gaan verloren. Doorgaan?';
  static const String dlgCancelEditConfirm = 'Ja, Annuleren';
  static const String dlgDeleteCustomerTitle = 'Klant Ontkoppelen';
  static const String dlgDeleteCustomerContent =
      'Klant ontkoppelen van deze werkbon?';
  static const String dlgDeleteConfirm = 'Ja, Wissen';
  static const String dlgYes = 'Ja';
  static const String dlgNo = 'Nee';
  static const String dlgClose = 'Sluiten';
  static const String dlgSearchCustomerTitle = 'Kies bestaande klant';
  static const String dlgDeleteFromDbTitle = 'Klant Verwijderen';
  static const String dlgDeleteFromDbContent =
      'Klant definitief verwijderen uit de database?';
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
  static const String lblOperation = 'Condensatietype';
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
  static const String headerBurnerTech = 'Brandertechnologie';
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
  static const String lblSeparateBurner = 'Afzonderlijke brander';
  static const String subSeparateBurner = 'Apart toestel (bv. stookolie)';
  static const String lblBurnerIntegratedBadge = 'Geïntegreerde brander';
  static const String descBurnerIntegrated =
      'Ketel en brander vormen één geheel.';
  static const String lblBrand = 'Merk';
  static const String lblModel = 'Type / Model';
  static const String lblConstructionYear = 'Bouwjaar';
  static const String lblSerialNumber = 'Fabricatienummer';
  static const String lblNominalPower = 'Nominaal vermogen (kW)';
  static const String lblFlowRate = 'Debiet (kW of kg/h of l/h of m³/h)';
  static const String tooltipScanBarcode = 'Scan barcode';
  static const String barcodeScannerPlaceholder =
      'Scanner wordt later geactiveerd';
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
      'QR Scanner wordt later actief';
  static const String nbnModalTitlePrefix = 'Aansluiting Type';
  static const String nbnModalClosed = 'Gesloten';
  static const String nbnModalOpen = 'Open';
  static const String hintCustomNbnCode = 'Ander getal (bv. 63 of 83)...';
  static const String scannerCameraUnavailable = 'Camera niet beschikbaar.';
  static const String scannerInstruction = 'Plaats code in het kader.';
  static const String loadingAppletTitle = 'Werkbon initialiseren...';
  static const String loadingAppletSubtitle =
      'Formulieren en metingen voorbereiden';
}
