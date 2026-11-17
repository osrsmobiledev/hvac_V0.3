abstract final class VekaApiDictionary {
  static const simulation = 'VEKA-testmodus · geen echte indiening';
  static const start = 'Bekijk testmelding';
  static const corrected = 'Bekijk gecorrigeerde testmelding';
  static const correctDate = 'Uitvoeringsdatum verbeteren';
  static const correctDateHint =
      'Kies de werkelijke uitvoeringsdatum voor deze VEKA-melding. Het bewaarde attest behoudt zijn oorspronkelijke datum.';
  static const archivedCorrectionHint =
      'De gecorrigeerde datum geldt voor deze VEKA-melding. Het bewaarde attest behoudt zijn oorspronkelijke datum.';
  static const unsupportedArchivedCorrection =
      'Voor deze afwijzing is in de app geen correctie beschikbaar. Controleer de veldfout bij het dossier voordat je verdergaat.';
  static const review = 'Controleer de testmelding';
  static const reviewHint =
      'Controleer het installatieadres en de exacte JSON. De app bewaart deze versie en referentie vóór de gesimuleerde verzending.';
  static const submit = 'Verstuur testmelding';
  static const outcome = 'Simuleer uitkomst';
  static const acceptOutcome = 'Aanvaard met ontvangstbewijs';
  static const rejectOutcome = 'Afgewezen met veldfouten';
  static const technicalOutcome = 'Technische fout';
  static const uncertainOutcome = 'Onzeker na time-out';

  static const sending = 'Testmelding wordt verstuurd';
  static const accepted = 'Testmelding aanvaard';
  static const rejected = 'Testmelding afgewezen';
  static const technical = 'Technische fout bij testmelding';
  static const uncertain = 'Uitkomst testmelding onzeker';
  static const rejectedHint =
      'Bekijk de veldfouten, pas de meldingsgegevens aan en controleer de nieuwe versie vóór je ze verstuurt.';
  static const unchangedRejected =
      'De afgewezen versie is nog niet gewijzigd. Corrigeer de gemelde velden en open de testmelding opnieuw.';
  static const technicalHint =
      'De toegang werd geweigerd. Je attest en meldingsgegevens zijn bewaard. Probeer opnieuw zodra de toegang is hersteld, of ga verder via het VEKA-portaal.';
  static const accessRetry = 'Opnieuw proberen na herstel';
  static const accessRetryHint =
      'Simuleer dat de toegang hersteld is. De app gebruikt opnieuw dezelfde meldingsgegevens en referentie.';
  static const accessRetryChanged =
      'De meldingsgegevens zijn gewijzigd. Gebruik het VEKA-portaal om de actuele gegevens te melden.';
  static const uncertainHint =
      'Controleer de melding bij VEKA. Verstuur ondertussen niets opnieuw en gebruik het portaal niet voor een tweede melding.';
  static const manualOpen =
      'Deze versie is al klaargezet voor het portaal. Ga verder via Heropen VEKA-portaal.';
  static const manualConfirmed =
      'Er is al een bevestigde portaalmelding voor dit bezoek.';
  static const addressBlocked =
      'De testmelding vereist een volledig gekoppeld installatieadres. Gebruik het portaal als het adres niet volledig gekoppeld is.';
  static const fieldsBlocked =
      'Controleer de ontbrekende of ongeldige meldingsgegevens.';
  static const statusError =
      'De meldingsstatus kon niet worden gelezen. Laad de status opnieuw vóór je verdergaat.';
  static const attemptError =
      'De actie kon niet worden afgerond. Controleer de opgeslagen testpogingen vóór je verdergaat.';
  static const reload = 'Laad meldingsstatus opnieuw';

  static const details = 'Bekijk testpogingen';
  static const verify = 'Controleer testmelding';
  static const verificationHint =
      'Simuleer een controle voor deze referentie. Kies gevonden testbewijs als de poging teruggevonden is. Herhaal alleen als er geen melding bestaat en herhalen is toegestaan.';
  static const retryReview = 'Controleer de herhaling';
  static const retryHint =
      'Herhaal alleen nadat je hebt vastgesteld dat de oorspronkelijke testmelding ontbreekt. Dezelfde referentie en exacte JSON worden opnieuw gebruikt.';
  static const retry = 'Bevestig afwezigheid en herhaal test';
  static const reconcile = 'Bevestig gevonden testbewijs';

  static const address = 'Installatieadres';
  static const reference = 'Externe referentie';
  static const version = 'Contractversie';
  static const exactJson = 'Exacte aanvraag-JSON';
  static const responseJson = 'Opgeslagen antwoord';
  static const responseCode = 'HTTP-status';
  static const receipt = 'Testmeldingsnummer';
  static const date = 'Poging bewaard op';
  static const sent = 'Verzending gestart op';
  static const resolved = 'Uitkomst bewaard op';
  static const reconciled = 'Ontvangstbewijs gevonden bij controle';
  static const result = 'Beoordeling voor de melding';
  static String dispatch(int number) => 'Verzending $number';
  static String fieldError(String field, String detail) => '$field: $detail';
  static String fieldLabel(String field) {
    final key = field.split(RegExp(r'[./]')).last;
    return switch (key) {
      'datumActiviteit' => 'Uitvoeringsdatum',
      'erkenningsnummer' => 'Erkenningsnummer',
      'ondernemingsnummer' => 'Ondernemingsnummer',
      _ => field,
    };
  }
}
