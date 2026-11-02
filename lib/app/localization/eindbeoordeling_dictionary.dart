// File: lib/app/localization/eindbeoordeling_dictionary.dart
// Responsibility: Centralized Dutch (Flemish) strings for Tab 7 (Eindbeoordeling & Signatures).

abstract final class EindbeoordelingDictionary {
  // --- Tab & Section Headers ---
  static const String tabTitle = 'Eindbeoordeling';
  static const String subKruisAan = 'Kruis aan wat van toepassing is';
  static const String cardTitleConclusie = 'Staat van werking & Veiligheid';
  static const String headerHetStooktoestelWerkt = 'Het stooktoestel werkt';
  static const String lblVerluchtingRookgasafvoer =
      'Verluchting en rookgasafvoer';

  // --- Dual Assessment Options (VEKA Mandated) ---
  static const String optGoed = 'Goed';
  static const String optNietGoed = 'Niet goed';
  static const String optVeilig = 'Veilig';
  static const String optNietVeilig = 'Niet veilig';

  // --- Smart Advice Hints & Status Badges ---
  static const String badgeCompliantConcluded = 'Installatie conform verklaard';
  static const String badgeNonCompliantConcluded =
      'Niet-conforme installatie: herstel vereist';

  // --- Next Statutory Inspection Date ---
  static const String cardTitleVolgendeControle =
      'Eerstvolgende verbrandingscontrole';
  static const String lblEerstvolgendeControleVoor =
      'Eerstvolgende verbrandingscontrole vóór:';
  static const String chipPlus3Months = '+3 Maanden';
  static const String chipPlus2Years = '+2 Jaar';
  static const String chipPlus1Year = '+1 Jaar';
  static const String badgeStatutory = 'Wettelijk';
  static const String statutoryTermGas =
      'Wettelijke termijn: 2 jaar (gasverwarming)';
  static const String statutoryTermLiquidSolid =
      'Wettelijke termijn: 1 jaar (stookolie / vaste brandstof)';
  static const String chipToday = 'Vandaag';
  static const String tooltipCalendarPicker = 'Kies datum in kalender';
  static const String datePlaceholder = 'DD/MM/YYYY';

  // --- Defects & Remediation (3-Month Rule) ---
  static const String cardTitleGebreken = 'Gebreken en maatregelen';
  static const String bannerRemediation3Months =
      'Wettelijke hersteltermijn: 3 maanden (Vlaams Stooktoestellenbesluit art. 6)';
  static const String lblGebrekenNietWeggewerkt =
      'Gebreken die niet door het onderhoud kunnen worden weggewerkt';
  static const String hintGebreken =
      'Beschrijf eventuele gebreken of te vervangen onderdelen...';
  static const String lblAndereOpmerkingen = 'Andere opmerkingen';
  static const String hintOpmerkingen =
      'Eventuele bijkomende vaststellingen of advies...';

  // --- Quick Statutory Defect Presets ---
  static const String btnSnelselectie = 'Snelselectie';
  static const String tooltipSnelselectie = 'Snelselectie suggesties';
  static const String modalTitleSnelselectie =
      'Gebreken & maatregelen';
  static const String filterCatAll = 'Aanbevolen';
  static const String filterCatFlueVent = 'Rookgas & Verluchting';
  static const String filterCatFuel = 'Brandstof & Brander';
  static const String filterCatHydraulic = 'Veiligheid & Water';
  static const String lblDefectPrefix = 'Gebrek';
  static const String lblMeasurePrefix = 'Maatregel';
  static const String btnToepassen = 'Toepassen';
  static const String feedbackApplied = 'Gebreken en maatregelen toegepast';
  static const String btnDeselectAll = 'Deselecteer alles';

  // --- Clear Text Dialogs ---
  static const String dlgClearDefectsTitle = 'Gebreken wissen';
  static const String dlgClearDefectsBody =
      'Weet u zeker dat u de ingevulde gebreken wilt wissen?';
  static const String dlgClearRemarksTitle = 'Opmerkingen wissen';
  static const String dlgClearRemarksBody =
      'Weet u zeker dat u de ingevulde opmerkingen en maatregelen wilt wissen?';
  static const String feedbackDefectsCleared = 'Gebreken gewist';
  static const String feedbackRemarksCleared = 'Opmerkingen gewist';

  // --- Signatures ---
  static const String cardTitleHandtekeningen = 'Digitale Handtekeningen';
  static const String lblHandtekeningTechnicus = 'handtekening technicus';
  static const String lblHandtekeningKlant =
      'handtekening klant voor kennisname';
  static const String lblKlantNaam = 'Naam ondertekenaar (optioneel)';
  static const String hintKlantNaam = 'bv. J. Janssens';
  static const String btnTikOmTeTekenen = 'Tik om te ondertekenen';
  static const String statusOndertekend = 'Ondertekend';
  static const String statusNietOndertekend = 'Niet ondertekend';
  static const String titleHandtekeningModal = 'Plaats handtekening';
  static const String modalTitleTechnicianSignature = 'Handtekening Technicus';
  static const String modalTitleCustomerSignature =
      'Handtekening Klant (Kennisname)';
  static const String btnWissen = 'Wissen';
  static const String btnAnnuleren = 'Annuleren';
  static const String btnOpslaan = 'Opslaan';
  static const String tooltipClearSignature = 'Wis handtekening';
  static const String dlgClearTechnicianSignatureTitle =
      'Handtekening technicus wissen';
  static const String dlgClearCustomerSignatureTitle =
      'Handtekening klant wissen';
  static const String dlgClearSignatureBody =
      'Weet u zeker dat u deze handtekening wilt wissen?';
  static const String feedbackSignatureCleared = 'Handtekening gewist';

  // --- Actions & Feedback ---
  static const String btnVoltooien = 'Verbrandingsattest Voltooien';
  static const String toastSaved = 'Eindbeoordeling opgeslagen';
  static const String toastValidationMissingConclusions =
      'Duid eerst de beoordeling aan (Goed/Niet goed, Veilig/Niet veilig)';
}
