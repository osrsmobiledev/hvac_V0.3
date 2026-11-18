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
