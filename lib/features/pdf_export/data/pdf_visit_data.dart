import 'dart:typed_data';

/// Complete, immutable snapshot of all visit, profile, customer, boiler, and
/// measurement data required to render the Flemish combustion certificate PDF.
///
/// Every property provides safe fallback defaults so partial or empty drafts
/// never throw null exceptions during preview or test rendering.
class PdfVisitData {
  // --- Header / Start ---
  final String activiteitType;
  final String volgnummerAttest;

  // --- Firma & Technicus ---
  final String firmaNaam;
  final String firmaStraat;
  final String firmaNr;
  final String firmaBus;
  final String firmaPostcode;
  final String firmaGemeente;
  final String firmaTel;
  final String firmaEmail;
  final String firmaKbo;
  final String technicusVoornaam;
  final String technicusAchternaam;
  final String technicusGv;
  final String technicusTv;
  final String datumOnderhoud;
  final String arbeidsduurVan;
  final String arbeidsduurTot;

  // --- Klant & Locatie ---
  final String klantNaam;
  final String klantVoornaam;
  final String klantAchternaam;
  final String klantBedrijf;
  final String klantStraat;
  final String klantNr;
  final String klantBus;
  final String klantPostcode;
  final String klantGemeente;
  final String klantTel;
  final String klantEmail;
  final String locatieStraat;
  final String locatieNr;
  final String locatieBus;
  final String locatiePostcode;
  final String locatieGemeente;

  // --- Toestel Kenmerken & Apparaat ---
  final bool isCentraal;
  final String centraalType; // 'B' or 'C' or ''
  final String typeBText;
  final String typeCText;
  final String brandstofCat; // 'gas', 'vloeibaar', 'vast'
  final String gasType; // 'aardgas', 'LPG', 'Andere'
  final String gasAndereText;
  final String branderTech; // 'premix (GI)', 'niet-premix (GI)', etc.
  final String vastType; // 'houtpellets', 'houtblokken', 'Andere'
  final String vastAndereText;
  final String toestelMerk;
  final String toestelType;
  final String toestelBouwjaar;
  final String toestelFabNummer;
  final String toestelVermogen;
  final String branderMerk;
  final String branderType;
  final String branderBouwjaar;
  final String branderFabNummer;
  final String branderDebiet;

  // --- Metingen (Operating conditions & Combustion) ---
  final String meetToestelNaam;
  final String meetToestelSerienummer;
  final String ketelTemp;
  final String sproeierMerkType;
  final String sproeierDebiet;
  final String sproeierHoek;
  final String pompdrukBar;
  final String gasdrukTellerMbar;
  final String gasdrukGasblokMbar;
  final String gasdrukBranderbedMbar;
  final String rookindexBacharach;
  final String rookindexBeoordelingOk; // 'OK' or 'Niet OK' or ''

  // Flue gas slot: Proef I (Initial)
  final String proef1O2;
  final String proef1Co2;
  final String proef1Co;
  final String proef1CoOk; // 'OK', 'Niet OK', ''
  final String proef1Tg;
  final String proef1Ta;
  final String proef1NettoTemp;
  final String proef1RendementHi;
  final String proef1RendementHiOk; // 'OK', 'Niet OK', ''
  final String proef1RendementHs;

  // Flue gas slot: Proef II (Final Low / High)
  final bool isLaaglastActive;
  final bool isHooglastActive;
  final String proef2LaagO2;
  final String proef2LaagCo2;
  final String proef2LaagCo;
  final String proef2LaagTg;
  final String proef2LaagTa;
  final String proef2LaagNettoTemp;
  final String proef2LaagRendementHi;
  final String proef2LaagRendementHs;
  final String proef2HoogO2;
  final String proef2HoogCo2;
  final String proef2HoogCo;
  final String proef2HoogTg;
  final String proef2HoogTa;
  final String proef2HoogNettoTemp;
  final String proef2HoogRendementHi;
  final String proef2HoogRendementHs;

  // Safety checks
  final String geenOliespoorOk;
  final String geenCondensatieOk;
  final String zeldenHinderlijkeRookOk;
  final String schouwtrekPa;
  final String drukRookgasOk;
  final String verluchtingStooklokaalOk;
  final String dichtheidRookgasafvoerOk;
  final String dichtheidBrandstoftoevoerOk;

  // --- Eindbeoordeling & Handtekeningen (Bottom 20%) ---
  final String toestelWerkingGoed; // 'Goed' or 'Niet goed' or ''
  final String toestelWerkingVeilig; // 'Veilig' or 'Niet veilig' or ''
  final String volgendeControleDatum;
  final String gebrekenOpmerkingen;
  final String andereOpmerkingen;
  final Uint8List? technicusHandtekeningBytes;
  final Uint8List? klantHandtekeningBytes;
  final String klantHandtekeningNaam;
  final String klantHandtekeningUitzondering; // 'weigert', 'afwezig', ''

  const PdfVisitData({
    this.activiteitType = '',
    this.volgnummerAttest = '',
    this.firmaNaam = '',
    this.firmaStraat = '',
    this.firmaNr = '',
    this.firmaBus = '',
    this.firmaPostcode = '',
    this.firmaGemeente = '',
    this.firmaTel = '',
    this.firmaEmail = '',
    this.firmaKbo = '',
    this.technicusVoornaam = '',
    this.technicusAchternaam = '',
    this.technicusGv = '',
    this.technicusTv = '',
    this.datumOnderhoud = '',
    this.arbeidsduurVan = '',
    this.arbeidsduurTot = '',
    this.klantNaam = '',
    this.klantVoornaam = '',
    this.klantAchternaam = '',
    this.klantBedrijf = '',
    this.klantStraat = '',
    this.klantNr = '',
    this.klantBus = '',
    this.klantPostcode = '',
    this.klantGemeente = '',
    this.klantTel = '',
    this.klantEmail = '',
    this.locatieStraat = '',
    this.locatieNr = '',
    this.locatieBus = '',
    this.locatiePostcode = '',
    this.locatieGemeente = '',
    this.isCentraal = false,
    this.centraalType = '',
    this.typeBText = '',
    this.typeCText = '',
    this.brandstofCat = '',
    this.gasType = '',
    this.gasAndereText = '',
    this.branderTech = '',
    this.vastType = '',
    this.vastAndereText = '',
    this.toestelMerk = '',
    this.toestelType = '',
    this.toestelBouwjaar = '',
    this.toestelFabNummer = '',
    this.toestelVermogen = '',
    this.branderMerk = '',
    this.branderType = '',
    this.branderBouwjaar = '',
    this.branderFabNummer = '',
    this.branderDebiet = '',
    this.meetToestelNaam = '',
    this.meetToestelSerienummer = '',
    this.ketelTemp = '',
    this.sproeierMerkType = '',
    this.sproeierDebiet = '',
    this.sproeierHoek = '',
    this.pompdrukBar = '',
    this.gasdrukTellerMbar = '',
    this.gasdrukGasblokMbar = '',
    this.gasdrukBranderbedMbar = '',
    this.rookindexBacharach = '',
    this.rookindexBeoordelingOk = '',
    this.proef1O2 = '',
    this.proef1Co2 = '',
    this.proef1Co = '',
    this.proef1CoOk = '',
    this.proef1Tg = '',
    this.proef1Ta = '',
    this.proef1NettoTemp = '',
    this.proef1RendementHi = '',
    this.proef1RendementHiOk = '',
    this.proef1RendementHs = '',
    this.isLaaglastActive = false,
    this.isHooglastActive = false,
    this.proef2LaagO2 = '',
    this.proef2LaagCo2 = '',
    this.proef2LaagCo = '',
    this.proef2LaagTg = '',
    this.proef2LaagTa = '',
    this.proef2LaagNettoTemp = '',
    this.proef2LaagRendementHi = '',
    this.proef2LaagRendementHs = '',
    this.proef2HoogO2 = '',
    this.proef2HoogCo2 = '',
    this.proef2HoogCo = '',
    this.proef2HoogTg = '',
    this.proef2HoogTa = '',
    this.proef2HoogNettoTemp = '',
    this.proef2HoogRendementHi = '',
    this.proef2HoogRendementHs = '',
    this.geenOliespoorOk = '',
    this.geenCondensatieOk = '',
    this.zeldenHinderlijkeRookOk = '',
    this.schouwtrekPa = '',
    this.drukRookgasOk = '',
    this.verluchtingStooklokaalOk = '',
    this.dichtheidRookgasafvoerOk = '',
    this.dichtheidBrandstoftoevoerOk = '',
    this.toestelWerkingGoed = '',
    this.toestelWerkingVeilig = '',
    this.volgendeControleDatum = '',
    this.gebrekenOpmerkingen = '',
    this.andereOpmerkingen = '',
    this.technicusHandtekeningBytes, this.klantHandtekeningBytes,
    this.klantHandtekeningNaam = '', this.klantHandtekeningUitzondering = '',
  });
}
