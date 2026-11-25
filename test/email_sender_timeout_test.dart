import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/features/email_delivery/data/email_sender_service.dart';
import 'package:hvac_app/features/email_delivery/data/email_settings_model.dart';
import 'package:mailer/mailer.dart';

class _ThrowingFile implements File {
  @override
  final String path;

  _ThrowingFile(this.path);

  @override
  Future<bool> exists() async =>
      throw FileSystemException('Permission denied', path);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  const settings = EmailSettings(
    provider: SmtpProviderType.custom,
    host: 'smtp.example.com',
    port: 465,
    useSsl: true,
    username: 'tech@example.com',
    hasPassword: true,
    autoSend: true,
    copyTechnician: true,
    smtpState: 'ready',
  );

  group('EmailSenderService timeout & I/O hardening', () {
    test(
        'testConnection returns networkTimeout when checker hangs past outer timeout',
        () async {
      final service = EmailSenderService(
        checkTimeout: const Duration(milliseconds: 50),
        checker: (server, {timeout}) => Completer<void>().future,
      );

      final result = await service.testConnection(
        settings: settings,
        password: 'secret',
      );

      expect(result, SmtpConnectionResult.networkTimeout);
    });

    test(
        'sendCertificateEmail returns uncertain_timeout when sendFunction hangs past outer timeout',
        () async {
      final tempDir = await Directory.systemTemp.createTemp('email_timeout_');
      addTearDown(() => tempDir.delete(recursive: true));
      final pdfFile = File('${tempDir.path}/attest.pdf');
      await pdfFile.writeAsString('%PDF-1.4');

      final service = EmailSenderService(
        sendTimeout: const Duration(milliseconds: 50),
        sendFunction: (msg, server, {timeout}) =>
            Completer<SendReport>().future,
      );

      final outcome = await service.sendCertificateEmail(
        settings: settings,
        password: 'secret',
        senderEmail: 'tech@example.com',
        senderName: 'Tech',
        recipientEmail: 'customer@example.com',
        subject: 'Attest',
        bodyText: 'Body',
        pdfPath: pdfFile.path,
      );

      expect(outcome.status, 'uncertain_timeout');
      expect(outcome.failureReason, 'uncertain_timeout');
    });

    test(
        'sendCertificateEmail returns failed missing_attachment when File.exists throws FileSystemException',
        () async {
      final service = EmailSenderService(
        sendFunction: (msg, server, {timeout}) async =>
            throw StateError('Should not send when attachment I/O fails'),
      );

      final outcome = await IOOverrides.runZoned(
        () => service.sendCertificateEmail(
          settings: settings,
          password: 'secret',
          senderEmail: 'tech@example.com',
          senderName: 'Tech',
          recipientEmail: 'customer@example.com',
          subject: 'Attest',
          bodyText: 'Body',
          pdfPath: '/unreadable/attest.pdf',
        ),
        createFile: (path) => _ThrowingFile(path),
      );

      expect(outcome.status, 'failed');
      expect(outcome.failureReason, 'missing_attachment');
      expect(outcome.lastError, contains('Permission denied'));
    });
  });
}
