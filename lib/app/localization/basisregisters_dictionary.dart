/// Centralized Dutch strings for Basisregisters Vlaanderen address lookup & verification.
abstract final class BasisregistersDictionary {
  static const String lookupBtnOpenDialog = 'Zoek adres via Basisregisters';
  static const String lookupDialogTitle = 'Adressopzoeking Basisregisters';
  static const String lookupDialogTitleCustomer = 'Klantadres opzoeken';
  static const String lookupDialogTitleInstallation =
      'Installatieadres opzoeken';
  static const String lookupLblStreet = 'Straat';
  static const String lookupLblNumber = 'Nr.';
  static const String lookupLblPostcode = 'Postcode';
  static const String lookupLblBus = 'Bus';
  static const String lookupBtnSearch = 'Zoeken';
  static const String lookupBtnSearchWithoutBus = 'Zoeken zonder busnummer';
  static const String lookupVerificationPending =
      'Installatieadres controleren…';
  static const String lookupBtnConfirm = 'Adres overnemen';
  static const String lookupLblResults = 'Gevonden adressen:';
  static const String lookupResultBus = 'bus';
  static const String lookupValidationStreetAndNumber =
      'Vul minstens een straatnaam en huisnummer in.';
  static const String lookupValidationRequiredFields =
      'Straatnaam, huisnummer en postcode zijn verplicht.';
  static const String lookupTimeoutError =
      'Verzoek duurde te lang (timeout). Controleer uw verbinding.';
  static const String lookupStatusFullMatch = 'Gekoppeld aan Basisregisters';
  static const String lookupStatusPartialMatch =
      'Adres gekoppeld · installatiegegevens onvolledig';
  static const String lookupStatusManual =
      'Handmatig ingevoerd ⚠ (geen Basisregister koppeling)';
  static const String lookupStatusBuildingFoundUnitUnconfirmed =
      'Gebouw gevonden · eenheid niet bevestigd';
  static const String lookupOffline =
      'Geen verbinding. Vul het adres handmatig in.';
  static const String tooltipLookupCustomerAddress = 'Klantadres opzoeken';
  static const String tooltipLookupInstallationAddress =
      'Installatieadres opzoeken';
  static const String lblWaarStaatToestel = 'Waar staat het toestel?';
  static const String optOpKlantadres = 'Op het klantadres';
  static const String optOpAnderAdres = 'Op een ander adres';
  static const String toastSaveFailed = 'Opslaan mislukt. Probeer opnieuw.';
  static const String toastRollbackFailed =
      'Herstellen mislukt. Probeer opnieuw.';
}
