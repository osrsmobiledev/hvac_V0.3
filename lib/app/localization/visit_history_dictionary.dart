abstract final class VisitHistoryDictionary {
  static const title = 'Historiek';
  static const search = 'Zoek op klant, adres of toestel';
  static const upcoming = 'Onderhoud binnen 30 dagen';
  static const overdue = 'Onderhoud over tijd';
  static const noVisits = 'Nog geen voltooide attesten.';
  static const noResults = 'Geen attesten gevonden.';
  static const noReminders = 'Geen onderhoud binnen 30 dagen.';
  static const unreadable = 'Sommige attesten kunnen niet worden gelezen.';
  static const loadError = 'Historiek kon niet worden geladen.';
  static const retry = 'Opnieuw proberen';
  static const customer = 'Onbekende klant';
  static const appliance = 'Onbekend toestel';
  static const archiveError =
      'Het attest kon niet worden bewaard. Probeer opnieuw.';
  static const customerEditing =
      'Sla je wijzigingen bij Klant op of annuleer ze.';
  static const reminder = 'Herinnering delen';
  static const reporting = 'VEKA-melding bekijken';
  static const followUp = 'VEKA op te volgen';
  static const reportPending = 'Attest bewaard · VEKA-melding nog op te volgen';
  static const reportReady = 'Melding starten';
  static const reportResume = 'Melding hervatten';
  static const reportCheck = 'Uitkomst controleren';
  static const reportCorrect = 'Gegevens verbeteren';
  static const reportPortal = 'Portaalmelding opvolgen';
  static const reportUnreadable = 'Meldingsbewijs controleren';
  static const shareFailed = 'Herinnering kon niet worden gedeeld.';
  static const confirmTitle = 'Attest voltooien?';
  static const confirmBody =
      'Dit attest wordt bewaard in Historiek. Daarna kan je een nieuw bezoek starten.';
  static const confirmAction = 'Attest bewaren';

  static String checkTab(String title) =>
      'Controleer de verplichte velden in .';

  static String message(String address, String date) =>
      'Beste, het onderhoud van uw stooktoestel op $address is nodig '
      'tegen $date. Neem gerust contact op om een afspraak te maken.';
}
