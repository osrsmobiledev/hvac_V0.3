/// Centralized Dutch (Flemish) explanations and labels for email failures.
///
/// Provides technician-friendly messages based on failure category and specific reasons,
/// directing technicians to actionable steps (e.g. checking credentials in Instellingen).
abstract final class EmailFailureDictionary {
  /// Shown when the recipient's email address was permanently rejected by the mail server.
  static const String recipientRejectedExplanation =
      'E-mailadres van de ontvanger bestaat niet of werd geweigerd door de mailserver.';

  /// Shown when the mail server rejected delivery due to server policy, spam filter, or quota.
  static const String serverRejectedExplanation =
      'De mailserver weigerde de verzending (mogelijk spamfilter, serverbeleid of quotum).';

  /// Shown when connection was interrupted during send and delivery status is uncertain.
  static const String uncertainTimeoutExplanation =
      'Verbinding onderbroken tijdens verzending. Controleer of de ontvanger het attest al heeft ontvangen.';

  /// Shown when SMTP authentication failed (wrong username or app-password).
  static const String authenticationFailedExplanation =
      'Authenticatie mislukt. Controleer uw SMTP-inloggegevens en app-wachtwoord in Instellingen.';

  /// Shown when the archived PDF file is missing from local device storage.
  static const String missingAttachmentExplanation =
      'Het gearchiveerde PDF-bestand kon niet worden gevonden op dit toestel.';

  /// Neutral fallback for unknown or generic processing failures.
  ///
  /// Does not falsely attribute local or unknown issues to server/connection faults.
  static const String genericExplanation =
      'Verzenden is niet gelukt. Er is een onverwachte fout opgetreden.';

  /// Label for expanding the technical details disclosure.
  static const String showTechnicalDetails = 'Technische details tonen';

  /// Label for collapsing the technical details disclosure.
  static const String hideTechnicalDetails = 'Technische details verbergen';

  /// Returns a concise technician-friendly explanation based on failure category and reason.
  static String failureExplanation(String status, String? reason) {
    if (reason == 'authentication_failed') {
      return authenticationFailedExplanation;
    }
    if (reason == 'missing_attachment') {
      return missingAttachmentExplanation;
    }
    if (status == 'recipient_rejected' || reason == 'recipient_rejected') {
      return recipientRejectedExplanation;
    }
    if (status == 'server_rejected' || reason == 'server_rejected') {
      return serverRejectedExplanation;
    }
    if (status == 'uncertain_timeout' || reason == 'uncertain_timeout') {
      return uncertainTimeoutExplanation;
    }
    return genericExplanation;
  }
}
