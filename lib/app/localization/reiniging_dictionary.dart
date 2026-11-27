/// Dutch (Flemish) UI dictionary for Tab 5 (Reiniging en controle).
///
/// Centralizes all user-facing card titles, subgroup headers, 14 cleaning/control
/// checklist labels, conditional input labels, and validation messages.
abstract final class ReinigingDictionary {
  // --- Card Headers ---
  static const String headerFlue = 'Rookgasafvoerkanaal';
  static const String subFlue =
      'Reiniging en controle (erkend technicus of schoorsteenveger)';
  static const String headerBoiler = 'Stooktoestel';

  // --- Subgroup Headers ---
  static const String subAll = 'Alle toestellen:';
  static const String subGas = 'Gasvormige brandstof: (erkend technicus)';
  static const String subLiquid = 'Vloeibare brandstof: (erkend technicus)';
  static const String subSolid = 'Vaste brandstof: (geschoold vakman)';
  static const String badgeActiveFuel = 'Actieve brandstof';
  static const String hintSelectFuelForBoiler =
      "Kies een brandstof op tab 'Stooktoestel' om de brandstofspecifieke reinigingspunten te tonen.";

  // --- Card 1: Flue (3 items) ---
  static const String itemFlueSweeping =
      'vegen van het rookgasafvoerkanaal en verbindingsstukken';
  static const String itemFlueGoodOperation = 'nazicht van de goede werking';
  static const String itemFlueBackdraft =
      'controle van de terugslag door middel van een terugslagmelder';

  // --- Card 2, Subgroup A: Alle toestellen (3 items) ---
  static const String itemAllOther = 'andere, namelijk:';
  static const String itemAllVentilation =
      'controle van de verluchting van het stooklokaal';
  static const String itemAllFlueTightness =
      'controle van de rookgaszijdige dichtheid';

  // --- Card 2, Subgroup B: Gasvormige brandstof (3 items) ---
  static const String itemGasDustRemoval = 'ontstoffing';
  static const String itemGasBurnerBedExchanger =
      'reiniging van branderbedden en warmtewisselaar (GI) of reinigen van de ketel (GII)';
  static const String itemGasFanBurner =
      'reiniging van de ventilator en brander';

  // --- Card 2, Subgroup C: Vloeibare brandstof (3 items) ---
  static const String itemLiquidFilters = 'reiniging van de filters';
  static const String itemLiquidBoiler = 'reiniging van de ketel';
  static const String itemLiquidBurner = 'reiniging van de brander';

  // --- Card 2, Subgroup D: Vaste brandstof (2 items) ---
  static const String itemSolidGeneralCondition = 'nazicht algemene staat';
  static const String itemSolidInternalCleaning =
      'reiniging inwendige delen warmtebron';

  // --- Conditional Input & Validation ---
  static const String lblOtherText = 'Omschrijving andere werkzaamheden';
  static const String hintOtherText =
      'Bv. dichtingskoord vervangen, sifon gereinigd...';
  static const String errOtherTextRequired =
      'Vul een omschrijving in voor "andere, namelijk:".';
  static const String errSelectAtLeastOne =
      'Duid minstens 1 controle- of reinigingspunt aan.';

  // --- Workflow Tabs & Start / Firma Deltas (Slice 7.3) ---
  static const List<String> reinigingTabs = [
    'Data',
    'Start',
    'Firma - Technicus',
    'Klant',
    'Stooktoestel',
    'Reiniging en controle',
    'Eindbeoordeling',
  ];

  static const String headerStartReiniging = 'Reinigingsattest';
  static const String activityOnderhoudStooktoestel =
      'Onderhoud centraal stooktoestel';
  static const String lblTechnicianRoles = 'Hoedanigheid';
  static const String roleErkendTechnicus = 'Erkend technicus';
  static const String roleSchoorsteenveger = 'Schoorsteenveger';
  static const String lblDateReiniging = 'Datum reiniging:';
  static const String toastPdfNotYetAvailable =
      'Reinigingsattest PDF-export en afronding volgen in Slice 7.4–7.5. Uw concept is veilig opgeslagen.';
}
