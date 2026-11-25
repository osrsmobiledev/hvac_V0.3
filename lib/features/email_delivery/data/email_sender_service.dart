import 'dart:async';
import 'dart:io';

import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

import '../../../core/utils/email_validator.dart';
import 'email_send_outcome.dart';
import 'email_settings_model.dart';
import 'smtp_exception_classifier.dart';

/// Type definition for the credentials check function to facilitate testing.
typedef CredentialsChecker = Future<void> Function(
  SmtpServer server, {
  Duration? timeout,
});

/// Type definition for the message send function to facilitate testing.
typedef SendFunction = Future<SendReport> Function(
  Message message,
  SmtpServer server, {
  Duration? timeout,
});

/// Platform service responsible for SMTP preflight testing and email delivery via `package:mailer ^7.2.0`.
class EmailSenderService {
  final CredentialsChecker _checker;
  final SendFunction _sendFunction;
  final Duration _checkTimeout;
  final Duration _sendTimeout;

  EmailSenderService({
    CredentialsChecker? checker,
    SendFunction? sendFunction,
    Duration checkTimeout = const Duration(seconds: 6),
    Duration sendTimeout = const Duration(seconds: 35),
  })  : _checker = checker ?? checkCredentials,
        _sendFunction = sendFunction ?? send,
        _checkTimeout = checkTimeout,
        _sendTimeout = sendTimeout;

  /// Validates standard email address syntax format using shared [EmailAddressValidator].
  static bool isFormatValidEmail(String email) =>
      EmailAddressValidator.isValid(email);

  /// Resolves the message sender email address following the app's policy.
  static String? resolveSenderEmail({
    required EmailSettings settings,
    required String profileEmail,
  }) {
    final username = settings.username.trim();
    if (settings.provider == SmtpProviderType.gmail) {
      return isFormatValidEmail(username) ? username : null;
    }
    if (isFormatValidEmail(username)) return username;
    if (isFormatValidEmail(profileEmail)) return profileEmail.trim();
    return null;
  }

  SmtpServer _buildServer(EmailSettings settings, String password) {
    if (settings.provider == SmtpProviderType.gmail) {
      return gmail(settings.username.trim(), password);
    }
    return SmtpServer(
      settings.host.trim(),
      port: settings.port,
      ssl: settings.useSsl,
      allowInsecure: false,
      username: settings.username.trim(),
      password: password,
    );
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

    final invalidGmail = settings.provider == SmtpProviderType.gmail &&
        !isFormatValidEmail(settings.username.trim());
    if (host.isEmpty ||
        settings.username.trim().isEmpty ||
        password.trim().isEmpty ||
        port <= 0 ||
        invalidGmail) {
      return SmtpConnectionResult.configurationError;
    }

    final server = _buildServer(settings, password);
    try {
      // Outer Dart timeout guards against a hung mailer Future holding the outbox lock.
      await _checker(server, timeout: const Duration(seconds: 4))
          .timeout(_checkTimeout);
      return SmtpConnectionResult.success;
    } on SmtpClientAuthenticationException {
      return SmtpConnectionResult.authenticationFailed;
    } on TimeoutException {
      return SmtpConnectionResult.networkTimeout;
    } on SocketException {
      return SmtpConnectionResult.socketError;
    } on HandshakeException {
      return SmtpConnectionResult.tlsHandshakeError;
    } catch (_) {
      return SmtpConnectionResult.serverError;
    }
  }

  /// Delivers a signed certificate PDF email with structured outcome classification.
  Future<EmailSendOutcome> sendCertificateEmail({
    required EmailSettings settings,
    required String password,
    required String senderEmail,
    required String senderName,
    required String recipientEmail,
    required String subject,
    required String bodyText,
    required String pdfPath,
  }) async {
    final file = File(pdfPath);
    try {
      if (!await file.exists()) {
        return const EmailSendOutcome(
          status: 'failed',
          failureReason: 'missing_attachment',
          lastError: 'Gearchiveerd PDF-bestand niet gevonden op het toestel',
        );
      }
    } catch (e) {
      return EmailSendOutcome(
        status: 'failed',
        failureReason: 'missing_attachment',
        lastError: 'Kan PDF-bijlage niet lezen: $e',
      );
    }

    final server = _buildServer(settings, password);
    final message = Message()
      ..from = Address(senderEmail, senderName)
      ..recipients.add(recipientEmail.trim())
      ..subject = subject
      ..text = bodyText
      ..attachments.add(FileAttachment(file));

    try {
      // Outer Dart timeout guards against a hung mailer Future holding the outbox lock.
      await _sendFunction(
        message,
        server,
        timeout: const Duration(seconds: 30),
      ).timeout(_sendTimeout);
      return EmailSendOutcome(
        status: 'sent',
        sentAt: DateTime.now().toIso8601String(),
      );
    } on SmtpMessageValidationException catch (e) {
      final isRecipientProblem = e.problems.any((p) => p.code == 'TO_ADDRESS');
      return EmailSendOutcome(
        status: isRecipientProblem ? 'recipient_rejected' : 'server_rejected',
        failureReason:
            isRecipientProblem ? 'recipient_rejected' : 'validation_failed',
        lastError: e.problems.map((p) => p.msg).join('; '),
      );
    } on SmtpClientAuthenticationException catch (e) {
      return EmailSendOutcome(
        status: 'server_rejected',
        failureReason: 'authentication_failed',
        lastError: e.message,
        isAuthFailure: true,
      );
    } on SmtpNoGreetingException catch (e) {
      return _outcome('server_rejected', 'no_greeting', e.message);
    } on SmtpUnsecureException catch (e) {
      return _outcome('server_rejected', 'unsecure_connection', e.message);
    } on TimeoutException catch (e) {
      return _outcome(
        'uncertain_timeout',
        'uncertain_timeout',
        'Timeout tijdens verzending: ${e.message}',
      );
    } on SocketException catch (e) {
      return _outcome(
        'uncertain_timeout',
        'uncertain_timeout',
        'Netwerkverlies tijdens verzending: ${e.message}',
      );
    } on SmtpClientCommunicationException catch (e) {
      return classifyCommunicationException(e);
    } catch (e) {
      return _outcome(
        'uncertain_timeout',
        'uncertain_timeout',
        'Onbekende fout tijdens verzending: $e',
      );
    }
  }

  static EmailSendOutcome _outcome(
    String status,
    String reason,
    String err,
  ) =>
      EmailSendOutcome(status: status, failureReason: reason, lastError: err);

  /// Classifies communication exceptions emitted by package:mailer ^7.3.0.
  static EmailSendOutcome classifyCommunicationException(
    SmtpClientCommunicationException e,
  ) =>
      SmtpExceptionClassifier.classify(e);
}
