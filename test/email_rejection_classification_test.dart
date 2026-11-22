import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/features/email_delivery/data/email_sender_service.dart';
import 'package:mailer/mailer.dart';

void main() {
  group('Rejection Classification Tests', () {
    test('permanent 550 5.1.1 RCPT TO classifies as recipient_rejected', () {
      const msg =
          'After sending RCPT TO:<bad@example.com>, response did not start with any of: [2].\n'
          'Response from server: < 550 5.1.1 User unknown';
      final outcome = EmailSenderService.classifyCommunicationException(
        SmtpClientCommunicationException(msg),
      );
      expect(outcome.status, equals('recipient_rejected'));
      expect(outcome.failureReason, equals('recipient_rejected'));
      expect(outcome.lastError, equals(msg));
    });

    test('recipient-specific 551 on RCPT TO classifies as recipient_rejected',
        () {
      const msg =
          'After sending RCPT TO:<bad@example.com>, response did not start with any of: [2].\n'
          'Response from server: < 551 User not local';
      final outcome = EmailSenderService.classifyCommunicationException(
        SmtpClientCommunicationException(msg),
      );
      expect(outcome.status, equals('recipient_rejected'));
      expect(outcome.failureReason, equals('recipient_rejected'));
      expect(outcome.lastError, equals(msg));
    });

    test('ambiguous bare 550 on RCPT TO classifies as server_rejected', () {
      const msg =
          'After sending RCPT TO:<user@example.com>, response did not start with any of: [2].\n'
          'Response from server: < 550 Requested action not taken: mailbox unavailable';
      final outcome = EmailSenderService.classifyCommunicationException(
        SmtpClientCommunicationException(msg),
      );
      expect(outcome.status, equals('server_rejected'));
      expect(outcome.failureReason, equals('server_rejected'));
      expect(outcome.lastError, equals(msg));
    });

    test(
        'multi-line with bare 550 first line and later 5.1.1 is server_rejected',
        () {
      const msg =
          'After sending RCPT TO:<user@example.com>, response did not start with any of: [2].\n'
          'Response from server: < 550 Requested action not taken\n'
          '< 550 Diagnostic code: see rule 5.1.1\n'
          '< 550 Mailbox unavailable';
      final outcome = EmailSenderService.classifyCommunicationException(
        SmtpClientCommunicationException(msg),
      );
      expect(outcome.status, equals('server_rejected'));
      expect(outcome.failureReason, equals('server_rejected'));
    });

    test(
        'multi-line with bare 550 first line and later 551/553 is server_rejected',
        () {
      const msg =
          'After sending RCPT TO:<user@example.com>, response did not start with any of: [2].\n'
          'Response from server: < 550 Requested action not taken\n'
          '< 550 Referral: contact host at 551 or 553\n'
          '< 550 End of diagnostic';
      final outcome = EmailSenderService.classifyCommunicationException(
        SmtpClientCommunicationException(msg),
      );
      expect(outcome.status, equals('server_rejected'));
      expect(outcome.failureReason, equals('server_rejected'));
    });

    test('multi-line with 550 5.1.1 on first line is recipient_rejected', () {
      const msg =
          'After sending RCPT TO:<bad@example.com>, response did not start with any of: [2].\n'
          'Response from server: < 550 5.1.1 User unknown\n'
          '< 550 Additional diagnostic information';
      final outcome = EmailSenderService.classifyCommunicationException(
        SmtpClientCommunicationException(msg),
      );
      expect(outcome.status, equals('recipient_rejected'));
      expect(outcome.failureReason, equals('recipient_rejected'));
    });

    test('temporary 4xx response on RCPT TO classifies as server_rejected', () {
      const msg =
          'After sending RCPT TO:<busy@example.com>, response did not start with any of: [2].\n'
          'Response from server: < 450 4.2.1 Mailbox busy, try again later';
      final outcome = EmailSenderService.classifyCommunicationException(
        SmtpClientCommunicationException(msg),
      );
      expect(outcome.status, equals('server_rejected'));
      expect(outcome.failureReason, equals('server_rejected'));
      expect(outcome.lastError, equals(msg));
    });

    test('policy 550 5.7.1 on RCPT TO classifies as server_rejected', () {
      const msg =
          'After sending RCPT TO:<relay@example.com>, response did not start with any of: [2].\n'
          'Response from server: < 550 5.7.1 Relaying denied';
      final outcome = EmailSenderService.classifyCommunicationException(
        SmtpClientCommunicationException(msg),
      );
      expect(outcome.status, equals('server_rejected'));
      expect(outcome.failureReason, equals('server_rejected'));
      expect(outcome.lastError, equals(msg));
    });

    test('policy 554 on RCPT TO classifies as server_rejected', () {
      const msg =
          'After sending RCPT TO:<block@example.com>, response did not start with any of: [2].\n'
          'Response from server: < 554 5.7.1 Service unavailable; Client host blocked';
      final outcome = EmailSenderService.classifyCommunicationException(
        SmtpClientCommunicationException(msg),
      );
      expect(outcome.status, equals('server_rejected'));
      expect(outcome.failureReason, equals('server_rejected'));
      expect(outcome.lastError, equals(msg));
    });

    test('malformed or missing server response on RCPT TO is uncertain_timeout',
        () {
      const msg = 'After sending RCPT TO:<bad@example.com>, truncated failure';
      final outcome = EmailSenderService.classifyCommunicationException(
        SmtpClientCommunicationException(msg),
      );
      expect(outcome.status, equals('uncertain_timeout'));
      expect(outcome.failureReason, equals('uncertain_timeout'));
      expect(outcome.lastError, equals(msg));
    });

    test('ambiguous unrecognized response on RCPT TO is uncertain_timeout', () {
      const msg =
          'After sending RCPT TO:<bad@example.com>, response did not start with any of: [2].\n'
          'Response from server: unexpected non-standard text';
      final outcome = EmailSenderService.classifyCommunicationException(
        SmtpClientCommunicationException(msg),
      );
      expect(outcome.status, equals('uncertain_timeout'));
      expect(outcome.failureReason, equals('uncertain_timeout'));
      expect(outcome.lastError, equals(msg));
    });

    test('remote MAIL FROM rejection classifies as server_rejected', () {
      const msg =
          'After sending MAIL FROM:<bad@example.com>, response did not start with any of: [2].\n'
          'Response from server: < 550 5.7.1 Sender address rejected';
      final outcome = EmailSenderService.classifyCommunicationException(
        SmtpClientCommunicationException(msg),
      );
      expect(outcome.status, equals('server_rejected'));
      expect(outcome.failureReason, equals('server_rejected'));
      expect(outcome.lastError, equals(msg));
    });

    test('unknown communication failure classifies as uncertain_timeout', () {
      const msg = 'Socket was closed even though a response was expected.';
      final outcome = EmailSenderService.classifyCommunicationException(
        SmtpClientCommunicationException(msg),
      );
      expect(outcome.status, equals('uncertain_timeout'));
      expect(outcome.failureReason, equals('uncertain_timeout'));
      expect(outcome.lastError, contains(msg));
    });
  });
}
