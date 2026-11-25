import 'package:mailer/mailer.dart';

import 'email_send_outcome.dart';

/// Classifies SMTP communication exceptions emitted by `package:mailer`.
abstract final class SmtpExceptionClassifier {
  /// Parses the first server reply line to distinguish permanent recipient rejections,
  /// temporary 4xx server issues, policy/relay rejections (5.7.x), bare 550, and unknown errors.
  static EmailSendOutcome classify(SmtpClientCommunicationException e) {
    final msg = e.message;
    if (msg.contains('After sending RCPT TO:')) {
      const marker = 'Response from server:';
      final idx = msg.indexOf(marker);
      if (idx == -1) {
        return _outcome('uncertain_timeout', 'uncertain_timeout', msg);
      }
      final afterMarker = msg.substring(idx + marker.length).trimLeft();
      final newlineIdx = afterMarker.indexOf('\n');
      final firstLine = (newlineIdx == -1
              ? afterMarker
              : afterMarker.substring(0, newlineIdx))
          .trim();

      final match = RegExp(
        r'^(?:<\s*)?(\d{3})(?:[- ]\s*([245]\.\d{1,3}\.\d{1,3}))?',
      ).firstMatch(firstLine);
      if (match == null) {
        return _outcome('uncertain_timeout', 'uncertain_timeout', msg);
      }

      final code = match.group(1)!;
      final enhanced = match.group(2);

      if (code.startsWith('4') ||
          (enhanced != null && enhanced.startsWith('4.'))) {
        return _outcome('server_rejected', 'server_rejected', msg);
      }
      if (code == '554' || (enhanced != null && enhanced.startsWith('5.7.'))) {
        return _outcome('server_rejected', 'server_rejected', msg);
      }
      if ((enhanced != null && enhanced.startsWith('5.1.')) ||
          code == '551' ||
          code == '553') {
        return _outcome('recipient_rejected', 'recipient_rejected', msg);
      }
      if (code.startsWith('5')) {
        return _outcome('server_rejected', 'server_rejected', msg);
      }
      return _outcome('uncertain_timeout', 'uncertain_timeout', msg);
    }
    if (msg.contains('After sending MAIL FROM:')) {
      return _outcome('server_rejected', 'server_rejected', msg);
    }
    return _outcome(
      'uncertain_timeout',
      'uncertain_timeout',
      'Communicatiefout tijdens verzending: $msg',
    );
  }

  static EmailSendOutcome _outcome(
    String status,
    String reason,
    String err,
  ) =>
      EmailSendOutcome(status: status, failureReason: reason, lastError: err);
}
