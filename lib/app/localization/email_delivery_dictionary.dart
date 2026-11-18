import 'package:hvac_app/features/email_delivery/data/email_settings_model.dart';

/// Centralized Dutch (Flemish) strings for email delivery and configuration.
///
/// Follows the Flemish terminology and official app dictionary standards.
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

  /// Title shown above the recipient list in the confirmation dialog.
  static const String recipientDialogTitle = 'Ontvangers bevestigen';

  /// Intro text explaining that the certificate will be prepared in the outbox queue.
  static const String recipientDialogIntro =
      'Het verbrandingsattest wordt klaargezet in de e-mailwachtrij als PDF-bijlage.';

  /// Label prefix for the customer recipient row.
  static const String recipientCustomerLabel = 'Klant';

  /// Label prefix for the technician copy row.
  static const String recipientTechnicianLabel = 'Kopie technicus';

  /// Shown when the customer has no email address in the snapshot.
  static const String recipientNoCustomerEmail =
      'Geen e-mailadres beschikbaar voor klant.';

  /// Shown when neither customer nor technician email is available.
  static const String recipientNoneAvailable =
      'Geen e-mailadres beschikbaar om naar te verzenden.';

  /// Confirm button in the recipient dialog.
  static const String recipientDialogConfirm = 'In wachtrij plaatsen';

  /// Cancel button in the recipient dialog.
  static const String recipientDialogCancel = 'Overslaan';

  /// Toast shown after jobs are successfully queued.
  static const String recipientJobsQueued =
      'E-mailtaak klaargezet in de wachtrij.';

  /// Toast shown when jobs were already queued previously (idempotent duplicate).
  static const String recipientJobsAlreadyQueued =
      'E-mailtaak stond reeds in de wachtrij.';

  /// Toast shown when the technician cancels the recipient dialog.
  static const String recipientDialogSkipped =
      'Attest opgeslagen. E-mail overgeslagen.';

  /// Toast shown after PDF archive succeeds.
  static const String archiveSuccess = 'PDF-archief aangemaakt.';

  /// Toast shown when PDF archive fails (but visit is preserved).
  static const String archiveFailure =
      'PDF-archivering mislukt — attest bewaard, e-mail geblokkeerd.';

  /// Toast shown when outbox queue insertion fails while visit & PDF are preserved.
  static const String outboxQueueFailed =
      'Toevoegen aan e-mailwachtrij mislukt.';

  /// Title for dialog when outbox queue insertion fails.
  static const String outboxRetryDialogTitle = 'E-mailwachtrij mislukt';

  /// Message explaining visit & PDF are safe, offering to retry outbox queueing.
  static const String outboxRetryDialogMessage =
      'Het attest en de PDF zijn veilig bewaard, maar het toevoegen aan de '
      'e-mailwachtrij is mislukt. Wilt u het opnieuw proberen?';

  /// Action button to retry outbox queueing.
  static const String outboxRetryAction = 'Opnieuw proberen';

  /// Action button to skip outbox queueing.
  static const String outboxRetryCancel = 'Overslaan';

  /// Toast shown when outbox queueing is skipped after a failure.
  static const String outboxQueueSkippedAfterFailure =
      'Attest bewaard. E-mailwachtrij overgeslagen.';

  // ── PDF database registration retry (Slice 6.2) ─────────────────────────
  static const String pdfRegistrationRetryTitle =
      'Database-registratie mislukt';
  static const String pdfRegistrationRetryMessage =
      'De PDF is aangemaakt, maar de registratie in de database is mislukt. '
      'Bij overslaan wordt het niet-geregistreerde PDF-bestand verwijderd en '
      'heeft het voltooide bezoek geen gearchiveerd PDF-attest.';
  static const String pdfRegistrationRetryAction = 'Opnieuw proberen';
  static const String pdfRegistrationRetryCancel = 'Verwijderen en overslaan';

  // Second confirmation dialog before destructive deletion
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

  /// Email subject line for a certificate.
  ///
  /// [attestNumber] is substituted at runtime. Set [isCopy] to true for the technician copy.
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

  // ─────────────────────────────────────────────────────────────────────────

  /// Maps typed [SmtpConnectionResult] to a user-facing Flemish feedback string.
  static String messageForConnectionResult(SmtpConnectionResult result) {
    switch (result) {
      case SmtpConnectionResult.success:
        return testConnectionSuccess;
      case SmtpConnectionResult.authenticationFailed:
        return authFailed;
      case SmtpConnectionResult.networkTimeout:
        return networkTimeout;
      case SmtpConnectionResult.socketError:
        return socketError;
      case SmtpConnectionResult.tlsHandshakeError:
        return tlsError;
      case SmtpConnectionResult.configurationError:
        return configError;
      case SmtpConnectionResult.serverError:
        return serverError;
    }
  }
}
