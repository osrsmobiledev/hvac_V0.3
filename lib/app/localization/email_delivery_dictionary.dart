import 'package:hvac_app/features/email_delivery/data/email_settings_model.dart';

/// Centralized Dutch (Flemish) strings for email delivery and configuration.
abstract final class EmailDeliveryDictionary {
  // Section & Card Header
  static const String cardTitle = 'E-mailconfiguratie (SMTP)';
  static const String cardSubtitle =
      'Configureer uitgaande SMTP voor het bezorgen van verbrandingsattesten.';

  // Providers
  static const String providerLabel = 'E-mailprovider';
  static const String providerGmail = 'Gmail (App-wachtwoord)';
  static const String providerCustom = 'Aangepaste SMTP';

  // Fields
  static const String hostLabel = 'SMTP Host';
  static const String hostHint = 'smtp.gmail.com';
  static const String portLabel = 'SMTP Poort';
  static const String usernameLabel = 'Gebruikersnaam / E-mailadres';
  static const String usernameHint = 'uw.bedrijf@gmail.com';
  static const String passwordLabel = 'Wachtwoord / App-wachtwoord';
  static const String passwordHint = '16-cijferig app-wachtwoord';
  static const String passwordSavedPlaceholder = '••••••••••••••••';
  static const String gmailHelpText =
      'Tip: Gebruik een 16-cijferig Google App-wachtwoord (zonder spaties), '
      'niet uw persoonlijke Google-wachtwoord.';

  // Encryption Modes
  static const String encryptionLabel = 'Beveiliging / Versleuteling';
  static const String sslTlsOption = 'SSL/TLS (Poort 465 - Impliciet)';
  static const String startTlsOption = 'STARTTLS (Poort 587 - Expliciet)';

  // Switches
  static const String autoSendLabel = 'Automatisch verzenden';
  static const String autoSendSubtitle =
      'Verstuur attesten direct bij het voltooien van een bezoek';
  static const String copyTechnicianLabel = 'Kopie naar technicus';
  static const String copyTechnicianSubtitle =
      'Vink technicus-kopie standaard aan in de afrondingsdialoog';

  // Actions
  static const String testConnectionButton = 'Verbinding testen';
  static const String testingConnection = 'Verbinding testen...';
  static const String saveSettingsButton = 'Instellingen opslaan';
  static const String savingSettings = 'Opslaan...';

  // Feedback Messages
  static const String testConnectionSuccess =
      'Verbinding en inloggegevens geslaagd (SMTP AUTH OK)';
  static const String saveSettingsSuccess =
      'E-mailinstellingen succesvol opgeslagen';
  static const String saveSettingsError =
      'Er is een fout opgetreden bij het opslaan van de instellingen.';
  static const String clearSettingsButton = 'E-mailinstellingen wissen';
  static const String clearingSettings = 'Bezig met wissen...';
  static const String clearSettingsDialogTitle = 'E-mailinstellingen wissen?';
  static const String clearSettingsDialogMessage =
      'Dit verwijdert de SMTP-verbinding en inloggegevens van dit toestel '
      'en schakelt automatisch verzenden uit. Bedrijfs- en technicusgegevens, '
      'klanten, toestellen, bezoeken, PDF\'s en wachtrij-taken blijven behouden.';
  static const String clearSettingsConfirm = 'Wissen';
  static const String clearSettingsCancel = 'Annuleren';
  static const String clearSettingsSuccess =
      'E-mailinstellingen en inloggegevens gewist';
  static const String clearSettingsError =
      'Fout bij het wissen van de instellingen.';
  static const String authFailed =
      'Authenticatie geweigerd: controleer uw inlognaam en App-wachtwoord.';
  static const String networkTimeout =
      'Time-out bij verbinden met de SMTP-server (geen antwoord).';
  static const String socketError =
      'Kan geen verbinding maken met de SMTP-server. Controleer host, poort en internet.';
  static const String tlsError =
      'Beveiligde TLS/SSL-handshake mislukt bij verbinden met de server.';
  static const String configError =
      'Configuratiefout: controleer host, poort en gebruikersnaam.';
  static const String serverError =
      'De SMTP-server weigerde de verbinding of gaf een fout.';
  static const String validationMissingFields =
      'Vul een geldige gebruikersnaam en wachtwoord in.';
  static const String validationMissingHost =
      'Vul een geldige SMTP-host en poort in.';
  static const String needsAttentionWarning =
      'E-mailinstellingen vereisen aandacht: controleer uw inloggegevens en voer een verbindingstest uit.';
  static const String invalidSenderError =
      'Geen geldig afzender-e-mailadres beschikbaar voor verzending.';
  static const String initSettingsError =
      'Kan e-mailinstellingen niet laden. Controleer de lokale databaseverbinding.';
  static const String btnRetryInit = 'Opnieuw proberen';

  // ── Recipient confirmation dialog (Slice 6.2) ────────────────────────────
  static const String recipientDialogTitle = 'Attest voltooien';
  static const String recipientDialogIntro =
      'Kies hoe u het verbrandingsattest wilt bezorgen:';
  static const String recipientCustomerLabel = 'Klant';
  static const String recipientTechnicianLabel = 'Kopie technicus';
  static const String recipientNoCustomerEmail = 'Geen e-mailadres ingesteld';
  static const String recipientDigitalDeliverySubtitle =
      'Attest digitaal bezorgen via e-mail';
  static const String recipientPaperNotice =
      'Attest wordt bewaard voor afdrukken of postbezorging.';
  static const String recipientNoneAvailable =
      'Geen e-mailadres beschikbaar om naar te verzenden.';
  static const String recipientDialogAbort = 'Annuleren';
  static const String finalizeAndEmailAction = 'Voltooien & E-mailen';
  static const String finalizeTechnicianCopyOnlyAction = 'Kopie naar technicus';
  static const String finalizeOnlySaveAction = 'Alleen bewaren';
  static const String finalizeLaterHint =
      'Tip: U kunt het attest later altijd nog e-mailen of delen via Historiek.';
  static const String finalizationUnconfiguredHint =
      'Attest bewaard. E-mail staat in wachtrij (configureer eerst SMTP in Instellingen).';
  static const String finalizationCancelled =
      'Voltooien geannuleerd — attest blijft als concept.';
  static const String recipientJobsQueued =
      'E-mailtaak klaargezet in de wachtrij.';
  static const String recipientJobsAlreadyQueued =
      'E-mailtaak stond reeds in de wachtrij.';
  static const String recipientDialogSkipped =
      'Attest bewaard in Historiek. E-mail overgeslagen.';
  static const String outboxUnconfiguredNotice =
      'E-mailaccount is nog niet geconfigureerd. Stel eerst uw SMTP-gegevens in via Instellingen.';
  static const String outboxNeedsAttentionNotice =
      'E-mailinstellingen vereisen aandacht. Controleer uw app-wachtwoord in Instellingen.';
  static const String outboxOfflineNotice =
      'Geen internetverbinding bereikbaar. Taken blijven veilig in de wachtrij.';
  static const String outboxSendSuccess = 'E-mail(s) succesvol verzonden.';
  static const String archiveSuccess = 'PDF-archief aangemaakt.';
  static const String archiveFailure =
      'PDF-archivering mislukt — attest bewaard, e-mail geblokkeerd.';
  static const String outboxQueueFailed =
      'Toevoegen aan e-mailwachtrij mislukt.';
  static const String outboxRetryDialogTitle = 'E-mailwachtrij mislukt';
  static const String outboxRetryDialogMessage =
      'Het attest en de PDF zijn veilig bewaard, maar het toevoegen aan de '
      'e-mailwachtrij is mislukt. Wilt u het opnieuw proberen?';
  static const String outboxRetryAction = 'Opnieuw proberen';
  static const String outboxRetryCancel = 'Overslaan';
  static const String outboxQueueSkippedAfterFailure =
      'Attest bewaard. E-mailwachtrij overgeslagen.';

  // ── PDF registration retry (Slice 6.2) ──────────────────────────────────
  static const String pdfRegistrationRetryTitle =
      'Database-registratie mislukt';
  static const String pdfRegistrationRetryMessage =
      'De PDF is aangemaakt, maar de registratie in de database is mislukt. '
      'Bij overslaan wordt het niet-geregistreerde PDF-bestand verwijderd en '
      'heeft het voltooide bezoek geen gearchiveerd PDF-attest.';
  static const String pdfRegistrationRetryAction = 'Opnieuw proberen';
  static const String pdfRegistrationRetryCancel = 'Verwijderen en overslaan';
  static const String pdfRegistrationDeleteConfirmTitle =
      'Niet-geregistreerde PDF verwijderen?';
  static const String pdfRegistrationDeleteConfirmMessage =
      'Weet u zeker dat u wilt overslaan? Het gegenereerde PDF-bestand wordt '
      'definitief verwijderd en het voltooide bezoek heeft dan geen gearchiveerd PDF-attest.';
  static const String pdfRegistrationDeleteConfirmAction =
      'Definitief verwijderen';
  static const String pdfRegistrationDeleteConfirmCancel = 'Terug';
  static const String pdfRegistrationFailed =
      'PDF-archivering mislukt: registratie in database niet voltooid.';
  static const String pdfDeleteFailedError =
      'Niet-geregistreerde PDF kon niet worden verwijderd van het toestel.';
  static const String pdfFileNotFoundError =
      'Gearchiveerd PDF-bestand niet gevonden op het toestel.';

  // ── Historiek email tracker & recovery (Slice 6.3) ──────────────────────
  static const String trackerDialogTitle = 'E-mailbezorging';
  static const String trackerNoJobs = 'Geen e-mailtaken voor dit attest.';
  static const String trackerEmptyExplanation =
      'Dit attest is bewaard zonder e-mail. U kunt het alsnog bezorgen:';
  static const String actionSendEmailLater = 'Alsnog e-mailen';
  static const String badgeQueued = 'In wachtrij';
  static const String badgeSending = 'Verzenden...';
  static const String badgeSent = 'Verzonden';
  static const String badgeRecipientRejected = 'Adres geweigerd';
  static const String badgeServerRejected = 'Server geweigerd';
  static const String badgeUncertainTimeout = 'Onzekere aflevering';
  static const String badgeResolvedManually = 'Handmatig opgelost';
  static const String actionSendNow = 'Nu verzenden';
  static const String actionSharePdf = 'Attest delen';
  static const String actionCorrectEmail = 'E-mailadres aanpassen';
  static const String actionRetry = 'Opnieuw proberen';
  static const String actionRetryArchive = 'PDF opnieuw archiveren';
  static const String actionResolveManually = 'Markeren als handmatig opgelost';
  static const String actionClose = 'Sluiten';
  static const String labelOriginalEmail = 'Oorspronkelijk:';
  static const String labelSentAt = 'Verzonden op:';
  static const String labelResolvedAt = 'Opgelost op:';
  static const String labelResolutionNotes = 'Toelichting:';
  static const String labelLastError = 'Foutmelding:';
  static const String correctEmailTitle = 'E-mailadres aanpassen';
  static const String correctEmailPrompt =
      'Voer het gecorrigeerde e-mailadres in om de taak opnieuw klaar te zetten:';
  static const String correctEmailFieldLabel = 'Nieuw e-mailadres';
  static const String correctEmailInvalid = 'Ongeldig e-mailadres';
  static const String correctEmailConfirm = 'Aanpassen en verzenden';
  static const String correctEmailCancel = 'Annuleren';
  static const String uncertainRetryTitle = 'Mogelijk reeds ontvangen';
  static const String uncertainRetryMessage =
      'De vorige verzending werd onderbroken na verzending. De ontvanger heeft '
      'het attest mogelijk al ontvangen. Wilt u het attest toch opnieuw verzenden?';
  static const String uncertainRetryConfirm = 'Toch opnieuw verzenden';
  static const String uncertainRetryCancel = 'Annuleren';
  static const String manualResolveTitle = 'Handmatig oplossen';
  static const String manualResolveMessage =
      'Bevestig dat dit attest handmatig is bezorgd (bv. afgeprint of getoond).';
  static const String manualResolveNotesLabel =
      'Toelichting (bv. print meegegeven)';
  static const String manualResolveConfirm = 'Bevestigen';
  static const String manualResolveCancel = 'Annuleren';
  static const String sharePdfError =
      'Gearchiveerd PDF-bestand niet gevonden om te delen.';

  /// Email subject line for a certificate.
  static String emailSubject(String attestNumber, {bool isCopy = false}) {
    final clean = attestNumber.trim();
    final base =
        clean.isNotEmpty ? 'Verbrandingsattest $clean' : 'Verbrandingsattest';
    return isCopy ? '$base (kopie)' : base;
  }

  /// Email body for the customer recipient.
  static String emailBodyCustomer(String attestNumber) {
    final clean = attestNumber.trim();
    final nrSuffix = clean.isNotEmpty ? ' (nr. $clean)' : '';
    return 'Geachte,\n\n'
        'In bijlage vindt u het verbrandingsattest van uw stooktoestel$nrSuffix.\n\n'
        'Met vriendelijke groeten';
  }

  /// Email body for the technician copy.
  static const String emailBodyTechnician =
      'Kopie verbrandingsattest — intern exemplaar.';

  /// Maps typed [SmtpConnectionResult] to a user-facing Flemish feedback string.
  static String messageForConnectionResult(SmtpConnectionResult result) =>
      switch (result) {
        SmtpConnectionResult.success => testConnectionSuccess,
        SmtpConnectionResult.authenticationFailed => authFailed,
        SmtpConnectionResult.networkTimeout => networkTimeout,
        SmtpConnectionResult.socketError => socketError,
        SmtpConnectionResult.tlsHandshakeError => tlsError,
        SmtpConnectionResult.configurationError => configError,
        SmtpConnectionResult.serverError => serverError,
      };
}
