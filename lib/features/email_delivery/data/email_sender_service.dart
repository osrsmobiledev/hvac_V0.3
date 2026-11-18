import 'dart:async';
import 'dart:io';

import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

import '../../../core/utils/email_validator.dart';
import 'email_settings_model.dart';

/// Type definition for the credentials check function to facilitate testing.
typedef CredentialsChecker = Future<void> Function(
  SmtpServer server, {
  Duration? timeout,
});

/// Platform service responsible for SMTP preflight testing via `package:mailer ^7.2.0`.
class EmailSenderService {
  final CredentialsChecker _checker;

  EmailSenderService({CredentialsChecker? checker})
      : _checker = checker ?? checkCredentials;

  /// Validates standard email address syntax format using shared [EmailAddressValidator].
  static bool isFormatValidEmail(String email) {
    return EmailAddressValidator.isValid(email);
  }

  /// Resolves the message sender email address following the app's policy:
  /// - Gmail: uses [settings.username] if format-valid email.
  /// - Custom SMTP: uses [settings.username] if format-valid email;
  ///   otherwise falls back to format-valid [profileEmail].
  /// - Returns `null` if no valid sender address exists (no synthetic addresses).
  static String? resolveSenderEmail({
    required EmailSettings settings,
    required String profileEmail,
  }) {
    final username = settings.username.trim();
    if (settings.provider == SmtpProviderType.gmail) {
      return isFormatValidEmail(username) ? username : null;
    }

    if (isFormatValidEmail(username)) {
      return username;
    }

    if (isFormatValidEmail(profileEmail)) {
      return profileEmail.trim();
    }

    return null;
  }

  /// Tests SMTP connection and credentials via [checkCredentials] without sending an email.
  Future<SmtpConnectionResult> testConnection({
    required EmailSettings settings,
    required String password,
  }) async {
    final host = settings.provider == SmtpProviderType.gmail
        ? 'smtp.gmail.com'
        : settings.host.trim();
    final port =
        settings.provider == SmtpProviderType.gmail ? 465 : settings.port;
    final useSsl =
        settings.provider == SmtpProviderType.gmail ? true : settings.useSsl;

    if (host.isEmpty ||
        settings.username.trim().isEmpty ||
        password.trim().isEmpty ||
        port <= 0) {
      return SmtpConnectionResult.configurationError;
    }

    if (settings.provider == SmtpProviderType.gmail &&
        !isFormatValidEmail(settings.username.trim())) {
      return SmtpConnectionResult.configurationError;
    }

    final SmtpServer server;
    if (settings.provider == SmtpProviderType.gmail) {
      server = gmail(settings.username.trim(), password);
    } else {
      server = SmtpServer(
        host,
        port: port,
        ssl: useSsl,
        allowInsecure: false,
        username: settings.username.trim(),
        password: password,
      );
    }

    try {
      await _checker(
        server,
        timeout: const Duration(seconds: 4),
      );
      return SmtpConnectionResult.success;
    } on SmtpClientAuthenticationException {
      return SmtpConnectionResult.authenticationFailed;
    } on TimeoutException {
      return SmtpConnectionResult.networkTimeout;
    } on SocketException {
      return SmtpConnectionResult.socketError;
    } on HandshakeException {
      return SmtpConnectionResult.tlsHandshakeError;
    } on SmtpClientCommunicationException {
      return SmtpConnectionResult.serverError;
    } catch (_) {
      return SmtpConnectionResult.serverError;
    }
  }
}
