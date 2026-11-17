abstract final class SavedBoilerDictionary {
  static const open = 'Opgeslagen toestel kiezen';
  static const title = 'Kies een toestel op dit adres';
  static const manual = 'Nieuw toestel invoeren';
  static const none = 'Geen opgeslagen toestellen op dit installatieadres.';
  static const choose = 'Toestel overnemen';
  static const replace =
      'Dit vervangt de toestel- en brandergegevens in dit concept.';
  static const done = 'Opgeslagen toestel overgenomen.';
  static const addressRequired =
      'Kies een installatieadres bij Klant en sla je wijzigingen op.';
  static const visitStarted =
      'Kies het toestel vóór je metingen, beoordeling, handtekeningen of een VEKA-melding vastlegt.';
  static const changed =
      'Het bezoek of adres is gewijzigd. Open de toestellijst opnieuw.';
  static const failed =
      'Het opgeslagen toestel kon niet worden geladen of bewaard.';
  static const unknown = 'Onbekend toestel';

  static String serial(String value) => 'Serienummer: $value';
  static String lastVisit(String value) => 'Laatste bezoek: $value';
}
