/// Dutch (Flemish) UI localization dictionary for Tab 6 (Meting).
///
/// Centralizes all section headers, field titles, hints, slot titles,
/// and statutory assessment checks according to official VEKA / NBN terminology.
abstract final class MetingDictionary {
  // --- Section Headers ---
  static const String headerOperatingConditions = 'Goede staat van werking';
  static const String headerCombustionMeasurements = 'Rookgasmetingen';
  static const String headerSafetyChecks = 'Veilige staat van werking';
  static const String headerFuelBanner = 'Installatie Brandstof';

  // --- Measurement Slots (Official VEKA Statutory Terminology) ---
  static const String slotProef1 = 'Proef I';
  static const String slotProef1Sub = 'Initiële meting';
  static const String slotProef2 = 'Proef II';
  static const String slotProef2Sub = 'Eindmeting';
  static const String slotProef2SubLaag = 'Eindmeting (Laaglast)';
  static const String slotProef2SubHoog = 'Eindmeting (Hooglast)';
  static const String subSlotLaaglast = 'Laaglast';
  static const String subSlotLaaglastBadge = 'Standaard';
  static const String subSlotHooglast = 'Hooglast';
  static const String subSlotHooglastBadge = 'Optioneel';

  static const String slotProef1Short = 'Proef I: Initiële meting';
  static const String slotProef2LaagShort = 'Proef II: Laaglast';
  static const String slotProef2HoogShort = 'Proef II: Hooglast';

  // --- Quick Action Buttons & Dialogs ---
  static const String btnCopyFromDataTab = 'Overnemen uit Data';
  static const String btnScanEurolyzer = 'Scan Eurolyzer';
  static const String btnClearSlot = 'Wis meting';
  static const String snackImportSuccess = 'Meetgegevens overgenomen uit Data';
  static const String snackSlotCleared = 'Meting gewist';
  static const String snackNoDataOnTab1 = 'Geen meetgegevens gevonden in Data';
  static const String snackScanSuccess = 'Eurolyzer meting ingeladen in ';
  static const String btnUndo = 'Herstellen';
  static const String dlgConfirmClearTitle = 'Meting wissen';
  static const String dlgConfirmClearDataTab =
      'Weet u zeker dat u de meetgegevens op Tab 1 (Data) wilt wissen?';
  static const String dlgConfirmClearBody =
      'Weet u zeker dat u alle meetwaarden van dit slot wilt wissen?';
  static String dlgConfirmClearBodyWithTitle(String title) =>
      'Weet u zeker dat u alle meetwaarden van $title wilt wissen?';
  static String dlgConfirmOverwriteBodyWithTitle(String title) =>
      '$title bevat al ingevulde waarden.\n\n$dlgConfirmOverwriteBody';
  static String snackSlotClearedWithTitle(String title) => '$title gewist.';
  static const String dlgConfirmOverwriteTitle = 'Meting overschrijven?';
  static const String dlgConfirmOverwriteBody =
      'Er staan al meetwaarden in dit slot. Wilt u deze overschrijven?';
  static const String dlgNoTab1DataTitle = 'Geen meetgegevens in Data';
  static const String dlgNoTab1DataBody =
      'Er zijn nog geen rookgasmetingen opgeslagen in de tab \'Data\'.\n\nWilt u nu rechtstreeks een Eurolyzer QR-code scannen?';
  static const String btnScanDirect = 'Direct QR Scannen';
  static const String btnSimulateEurolyzer = '⚡ Test-meting simuleren';
  static const String titleEurolyzerScanner = 'Eurolyzer QR Scanner';
  static const String slotTitleDataTab = 'Data (Meetgegevens)';
  static const String lblCameraUnavailable =
      'Camera niet beschikbaar.\nGebruik de simulatie-knop hieronder.';

  // --- Operating Conditions (Card 1) ---
  static const String lblBoilerTemp = 'Keteltemperatuur (°C)';
  static const String hintBoilerTemp = 'bv. 65';
  static const String lblGasPressureMeter = 'Gasdruk teller (mbar)';
  static const String hintGasPressureMeter = 'bv. 22.5';
  static const String lblGasPressureBlock = 'Gasdruk gasblok (mbar)';
  static const String hintGasPressureBlock = 'bv. 18.2';
  static const String lblGasPressureBurnerBed = 'Gasdruk branderbed (mbar)';
  static const String hintGasPressureBurnerBed = 'bv. 10.4';
  static const String lblNozzleBrandType = 'Sproeier: merk en type';
  static const String hintNozzleBrandType = 'bv. Danfoss 0.60 60°S';
  static const String lblNozzleFlowRate = 'Sproeier: debiet';
  static const String hintNozzleFlowRate = 'bv. 0.60 USgal/h';
  static const String lblNozzleAngle = 'Sproeier: hoek (graden)';
  static const String hintNozzleAngle = 'bv. 60';
  static const String lblPumpPressure = 'Pompdruk (bar)';
  static const String hintPumpPressure = 'bv. 11.5';
  static const String lblSmokeIndex = 'Rookindex (Bacharach)';
  static const String hintSmokeIndex = '0, 1 of 2';

  // --- Combustion Measurements (Card 2) ---
  static const String lblO2 = 'Zuurstof (O₂)';
  static const String hintO2 = 'bv. 4.8';
  static const String lblCO2 = 'Koolstofdioxide (CO₂)';
  static const String hintCO2 = 'bv. 9.2';
  static const String lblCO = 'Koolstofmonoxide (CO)';
  static const String hintCO = 'bv. 24.5';
  static const String lblUnitMgKwh = 'mg/kWh';
  static const String lblFlueTempTg = 'Rookgastemperatuur (tg)';
  static const String hintFlueTempTg = 'bv. 54.2';
  static const String lblAirTempTa = 'Temperatuur verbrandingslucht (ta)';
  static const String hintAirTempTa = 'bv. 19.8';
  static const String lblNetTemp = 'Nettotemperatuur (tg - ta)';
  static const String lblNetTempAutoBadge = 'Auto berekend';
  static const String lblEfficiencyHi = 'Verbrandingsrendement (Hi)';
  static const String hintEfficiencyHi = 'bv. 98.4';
  static const String lblEfficiencyHs = 'Verbrandingsrendement (Hs)';
  static const String hintEfficiencyHs = 'bv. 88.6';
  static const String headerStatutoryAssessment =
      'Statutaire beoordeling (Eindmeting)';
  static const String lblCoStatutoryCheck = 'CO-norm (≤ 150 mg/kWh)';
  static const String lblHiStatutoryCheck =
      'Rendement Hi norm (≥ 90% std / ≥ 88% B1)';

  /// Returns smart statutory CO-norm label based on fuel category.
  static String getCoNormLabel({required String fuelCategory}) {
    if (fuelCategory == 'vast') {
      return 'CO-norm (conform norm)';
    }
    return 'CO-norm (≤ 150 mg/kWh)';
  }

  /// Compact statutory CO norm text for embedding inside the input box.
  static String getCoNormText({required String fuelCategory}) {
    if (fuelCategory == 'vast') return 'conform';
    return '≤ 150 mg/kWh';
  }

  /// Compact statutory Rendement Hi norm text for embedding inside the input box.
  static String getHiNormText({
    required String fuelCategory,
    required String centraalType,
    String typeBText = '',
  }) {
    if (fuelCategory == 'vloeibaar') return '≥ 90%';
    if (fuelCategory == 'vast') return '≥ 80%';
    if (centraalType == 'B') {
      final sub = typeBText.trim().toUpperCase();
      final bool isB1 =
          sub.isEmpty || sub.startsWith('1') || sub.startsWith('B1');
      if (isB1) return '≥ 88%';
      return '≥ 90%';
    }
    return '≥ 90%';
  }

  /// Returns smart statutory Rendement Hi label based on fuel, appliance type, and operation.
  static String getHiNormLabel({
    required String fuelCategory,
    required String centraalType,
    String typeBText = '',
    String boilerOperation = 'condenserend',
  }) {
    if (fuelCategory == 'vloeibaar') {
      return 'Rendement Hi-norm (≥ 90% - Stookolie)';
    } else if (fuelCategory == 'vast') {
      return 'Rendement Hi-norm (≥ 80% - Vaste brandstof)';
    } else {
      // Gasvormig
      if (centraalType == 'B') {
        final sub = typeBText.trim().toUpperCase();
        final bool isB1 =
            sub.isEmpty || sub.startsWith('1') || sub.startsWith('B1');
        if (isB1) {
          return 'Rendement Hi-norm (≥ 88% - Type B1)';
        }
        return 'Rendement Hi-norm (≥ 90% - Type B2/B23)';
      }
      if (boilerOperation == 'condenserend') {
        return 'Rendement Hi-norm (≥ 90% - Type C condens)';
      }
      return 'Rendement Hi-norm (≥ 90% - Type C)';
    }
  }

  static const String lblStatutoryCompliant = 'Wettelijk conform';
  static const String lblStatutoryNonCompliant = 'Niet conform norm';
  static const String lblStatutoryCheck = 'Wettelijke norm';
  static const String badgeCoLimit = 'Norm: ≤ 150 mg/kWh';
  static const String badgeHiLimit = 'Norm: ≥ 90%';
  static const String badgeProef1Baseline = 'Basislijn vóór onderhoud';
  static const String badgeProef2Compliance = 'Wettelijke norm (Proef II)';
  static const String lblVerbrandingscontrole = 'Verbrandingscontrole';
  static const String badgeVerbrandingscontroleOk = 'Conform (OK)';
  static const String badgeVerbrandingscontroleNok = 'Niet conform (Niet OK)';
  static const String badgeVerbrandingscontrolePending = 'In afwachting';

  // --- Safety & Environmental Checks (Card 3) ---
  static const String lblCheckNoOilTrace =
      'Geen zichtbaar oliespoor bij rookindex';
  static const String lblCheckNoCondensation =
      'Geen ongewenste condensvorming (Type B)';
  static const String lblCheckRarelySmoke =
      'Zelden hinderlijke en milieuverontreinigende rook';
  static const String lblCheckFluePressure = 'Druk rookgasafvoerkanaal (Pa)';
  static const String lblCheckVentilation =
      'Verluchting en ventilatie stooklokaal';
  static const String lblCheckFlueTightness =
      'Dichtheid rookgasafvoer (Type C)';
  static const String lblCheckFuelSupplyTightness =
      'Dichtheid gasmeter tot toestel';
  static const String snackEurolyzerDataLoaded =
      'Eurolyzer meting ingeladen in Data';
  static const String lblOk = 'OK';
  static const String lblNotOk = 'Niet OK';
  static const String lblNok = 'NOK';
}
