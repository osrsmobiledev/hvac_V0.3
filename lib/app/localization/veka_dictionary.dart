abstract final class VekaDictionary {
  static const title = 'VEKA-melding';
  static const pending = 'Nog niet bevestigd';
  static const reported = 'Manueel gemeld';
  static const current = 'Bekijk meldingsgegevens';
  static const saved = 'Bekijk klaargezette versie';
  static const json = 'Bekijk JSON';
  static const open = 'Open VEKA-portaal';
  static const portalReview = 'Melding klaarzetten voor VEKA';
  static const portalReviewHint =
      'Controleer het installatieadres en de meldingsgegevens. De app bewaart deze versie vóór het portaal opent.';
  static const portalBlocked =
      'Vul de ontbrekende meldingsgegevens in om het portaal te openen.';
  static const jsonPreviewHint =
      'Dit is een lokale preview. Een leeg ID betekent dat er geen registerkoppeling is opgeslagen. De vlaggen voor onbekende IDs worden pas gezet na controle op de officiële kaart.';
  static const reopen = 'Heropen VEKA-portaal';
  static const reserve = 'Bewaar versie en open portaal';
  static const replace = 'Vervang klaargezette versie';
  static const replaceWarning =
      'Bevestig alleen als er voor de klaargezette versie nog geen portaalinvoer bestaat.';
  static const replaceConfirm = 'Er bestaat geen portaalinvoer';
  static const confirm = 'Bevestig indiening';
  static const confirmQuestion =
      'Heb je deze versie ingediend en teruggevonden bij Gemelde activiteiten? Wacht bij een melding door een derde tot ze gevalideerd en ingediend is.';
  static const actor = 'Naam van de bevestiger';
  static const reference = 'Portaalreferentie (optioneel)';
  static const submittedAt = 'Indieningstijdstip (optioneel, JJJJ-MM-DD UU:MM)';
  static const invalidConfirmation =
      'Vul je naam en een geldig, niet-toekomstig tijdstip in.';
  static const later = 'Later bevestigen';
  static const changed = 'Gewijzigd na melding';
  static const stale =
      'De meldingsgegevens zijn gewijzigd. Bekijk de actuele versie opnieuw.';
  static const missing = 'Ontbreekt';
  static const unsupported =
      'Controleer dit bezoek in het VEKA-portaal. De tracker ondersteunt centrale toestellen op aardgas of stookolie.';
  static const customer = 'Sla je wijzigingen bij Klant op of annuleer ze.';
  static const broken = 'Meldingsbewijs kan niet worden gelezen.';
  static const saveError =
      'Meldingsgegevens konden niet worden bewaard of gelezen. Probeer opnieuw.';
  static const launchError =
      'Portaal kon niet worden geopend. Probeer opnieuw.';
  static const mockValidationDetail =
      'De gesimuleerde melding wijst de activiteitsdatum af.';
  static const mockReceiptRemark =
      'Gesimuleerde waarschuwing voor deze testmelding.';
  static String? reviewMessage(bool supported, bool prepare, bool eligible) {
    if (!supported) return unsupported;
    if (!prepare) return null;
    return eligible ? portalReviewHint : portalBlocked;
  }

  static const manualAddress =
      'Zoek dit adres in het portaal. Gebruik Adres niet gevonden? als het adres daar echt ontbreekt.';
  static const retryConformity = 'Conformiteit opnieuw laden';
  static const assessments = 'Conformiteit voor VEKA';
  static const appliance = 'Stooktoestel';
  static const flue = 'Rookgasafvoerkanaal';
  static const room = 'Stookplaats';

  static const tabs = {
    2: 'Start',
    3: 'Firma – Technicus',
    4: 'Klant',
    5: 'Stooktoestel',
    6: 'Meting',
    7: 'Eindbeoordeling'
  };
  static String missingIn(int tab) => 'Controleer ${tabs[tab]}.';
  static const combustionIssue =
      'Vul bij Meting de vereiste waarden en beoordelingen in voor de verbrandingscontrole.';
  static String assessmentIssue(String key) => 'Duid ${fields[key]} aan.';
  static const technicianIssue = {
    'visit_date': 'Uitvoeringsdatum: kies vandaag of een eerdere datum.',
    'kbo_number': 'Ondernemingsnummer: vul een KBO-nummer van 10 cijfers in.',
    'GV':
        'GV-nummer voor aardgas: vul GV in gevolgd door vijf cijfers (bv. GV01234).',
    'TV':
        'TV-nummer voor stookolie: vul TV in gevolgd door vijf cijfers (bv. TV01234).',
    'company_name': 'Vul de bedrijfsnaam in.',
    'technician_first_name': 'Vul de voornaam van de technicus in.',
    'technician_last_name': 'Vul de achternaam van de technicus in.',
  };
  static const sections = {
    'activity': 'Activiteit',
    'technician': 'Technicus',
    'boiler': 'Stooktoestel',
    'assessment': 'Eindbeoordeling',
    'confirmation': 'Portaalbevestiging',
  };
  static const fields = {
    'activity_type': 'Uitgevoerde activiteit',
    'visit_date': 'Uitvoeringsdatum',
    'attest_number': 'Attestnummer',
    'company_name': 'Onderneming',
    'technician_first_name': 'Voornaam',
    'technician_last_name': 'Achternaam',
    'kbo_number': 'Ondernemingsnummer',
    'recognition_number': 'Erkenningsnummer',
    'centraal_type': 'Toesteltype',
    'fuel_type': 'Brandstof',
    'fuel_subtype': 'Gastype',
    'heating_type': 'Verwarmingstype',
    'boiler_operation': 'Condensatietype',
    'burner_technology': 'Brandertechnologie',
    'boiler_brand': 'Merk',
    'boiler_model': 'Model',
    'boiler_serial_number': 'Fabricatienummer',
    'boiler_construction_year': 'Bouwjaar',
    'boiler_nominal_power_kw': 'Nominaal vermogen (kW)',
    'stooktoestel_conform': appliance,
    'rookgasafvoerkanaal_conform': flue,
    'stookplaats_conform': room,
    'verbrandingscontrole': 'Verbrandingscontrole',
    'toestel_werking_goed': 'Werking',
    'toestel_werking_veilig': 'Veiligheid',
    'confirmed_by': actor,
    'confirmed_at': 'Bevestigd op',
    'portal_reference': 'Portaalreferentie',
    'portal_submitted_at': 'Ingediend op',
  };
  static const values = {
    'onderhoud': 'Onderhoud',
    'eerste_ingebruikname': 'Keuring voor eerste ingebruikname',
    'gas': 'Gas',
    'aardgas': 'Aardgas',
    'vloeibaar': 'Stookolie',
    'vast': 'Vaste brandstof',
    'onbekend': 'Onbekend',
    'NOK': 'Niet OK',
    'individueel': 'Individueel',
    'collectief': 'Collectief',
    'condenserend': 'Condenserend',
    'niet_condenserend': 'Niet-condenserend',
    'niet_premix': 'Niet premix',
    'premix': 'Premix',
    'ventilatorbrander': 'Ventilatorbrander',
  };
}
