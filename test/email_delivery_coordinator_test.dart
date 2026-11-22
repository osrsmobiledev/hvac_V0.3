import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/core/database/database_schema.dart';
import 'package:hvac_app/features/email_delivery/data/email_delivery_coordinator.dart';
import 'package:hvac_app/features/email_delivery/data/email_outbox_repository.dart';
import 'package:hvac_app/features/email_delivery/data/email_sender_service.dart';
import 'package:hvac_app/features/email_delivery/data/email_settings_repository.dart';
import 'package:hvac_app/features/email_delivery/data/secure_credential_store.dart';
import 'package:mailer/mailer.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class _FakeCredStore extends SecureCredentialStore {
  final String? pass;
  _FakeCredStore([this.pass]);
  @override
  Future<String?> getPassword() async => pass;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Directory tempDir;
  late Database db;
  late EmailOutboxRepository outbox;
  late EmailSettingsRepository settingsRepo;
  late File dummyPdf;

  EmailJobSpec makeJob(String email) => EmailJobSpec(
        visitId: 10,
        recipientType: RecipientType.customer,
        recipientName: 'Klant',
        recipientEmail: email,
        subject: 'Attest',
        bodyText: 'B',
        pdfPath: dummyPdf.path,
      );

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('coord_deliv_test_');
    dummyPdf = File(p.join(tempDir.path, 'cert.pdf'))..writeAsBytesSync([1, 2]);
    db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: DatabaseSchema.version,
        onCreate: (db, _) => DatabaseSchema.createAllTables(db),
      ),
    );
    outbox = EmailOutboxRepository(database: () async => db);
    settingsRepo = EmailSettingsRepository(
      db: db,
      secureStore: _FakeCredStore('secret123'),
    );

    await db.insert('technician_profile', {
      'id': 1,
      'company_name': 'Warmte BV',
      'kbo_number': '0123.456.789',
      'email': 'warmte@example.com',
      'smtp_host': 'smtp.example.com',
      'smtp_port': 465,
      'smtp_username': 'warmte@example.com',
      'smtp_provider': 'custom',
      'email_auto_send': 1,
      'smtp_state': 'configured',
      'created_at': '2026-01-01',
      'updated_at': '2026-01-01',
    });
    await db.insert('maintenance_visits', {
      'id': 10,
      'visit_date': '2026-01-01',
      'is_draft': 0,
      'pdf_status': 'ready',
      'pdf_path': dummyPdf.path,
      'created_at': '2026-01-01',
      'updated_at': '2026-01-01',
    });
  });

  tearDown(() async {
    await db.close();
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  group('EmailDeliveryCoordinator Tests', () {
    test('offline preflight leaves jobs in queued with attempt_count = 0',
        () async {
      await outbox.createJobs([makeJob('klant@example.com')]);
      final coordinator = EmailDeliveryCoordinator(
        database: () async => db,
        outboxRepository: outbox,
        settingsRepository: settingsRepo,
        credentialStore: _FakeCredStore('secret123'),
        senderService: EmailSenderService(
          checker: (_, {timeout}) => throw const SocketException('offline'),
        ),
      );
      await coordinator.processOutbox();
      final jobs = await outbox.getJobsForVisit(10);
      expect(jobs.single['status'], equals('queued'));
      expect(jobs.single['attempt_count'], equals(0));
    });

    test('recovers stale sending job to uncertain_timeout', () async {
      await db.insert('email_delivery_jobs', {
        'id': 99,
        'visit_id': 10,
        'recipient_type': 'customer',
        'recipient_name': 'K',
        'recipient_email': 'k@e.com',
        'original_recipient_email': 'k@e.com',
        'subject': 'S',
        'body_text': 'B',
        'pdf_path': dummyPdf.path,
        'status': 'sending',
        'attempt_count': 1,
        'created_at': '2026-01-01',
        'updated_at': '2026-01-01',
      });
      final coordinator = EmailDeliveryCoordinator(
        database: () async => db,
        outboxRepository: outbox,
        settingsRepository: settingsRepo,
        credentialStore: _FakeCredStore('secret123'),
        senderService: EmailSenderService(checker: (_, {timeout}) async {}),
      );
      await coordinator.processOutbox();
      final job =
          (await db.query('email_delivery_jobs', where: 'id = 99')).single;
      expect(job['status'], equals('uncertain_timeout'));
      expect(job['failure_reason'], equals('uncertain_timeout'));
      expect(job['attempt_count'], equals(1));
    });

    test('successful delivery marks job as sent with sent_at', () async {
      await outbox.createJobs([makeJob('klant@example.com')]);
      final coordinator = EmailDeliveryCoordinator(
        database: () async => db,
        outboxRepository: outbox,
        settingsRepository: settingsRepo,
        credentialStore: _FakeCredStore('secret123'),
        senderService: EmailSenderService(
          checker: (_, {timeout}) async {},
          sendFunction: (msg, srv, {timeout}) async =>
              SendReport(msg, DateTime.now(), DateTime.now(), DateTime.now()),
        ),
      );
      await coordinator.processOutbox();
      final jobs = await outbox.getJobsForVisit(10);
      expect(jobs.single['status'], equals('sent'));
      expect(jobs.single['sent_at'], isNotNull);
      expect(jobs.single['attempt_count'], equals(1));
    });

    test('structured recipient validation failure marks recipient_rejected',
        () async {
      await outbox.createJobs([makeJob('bad-email')]);
      final coordinator = EmailDeliveryCoordinator(
        database: () async => db,
        outboxRepository: outbox,
        settingsRepository: settingsRepo,
        credentialStore: _FakeCredStore('secret123'),
        senderService: EmailSenderService(
          checker: (_, {timeout}) async {},
          sendFunction: (msg, srv, {timeout}) async =>
              throw SmtpMessageValidationException(
            'Invalid message',
            [Problem('TO_ADDRESS', 'Invalid recipient format')],
          ),
        ),
      );
      await coordinator.processOutbox();
      final jobs = await outbox.getJobsForVisit(10);
      expect(jobs.single['status'], equals('recipient_rejected'));
      expect(jobs.single['failure_reason'], equals('recipient_rejected'));
    });

    test('in-flight communication failure marks uncertain_timeout', () async {
      await outbox.createJobs([makeJob('k@e.com')]);
      final coordinator = EmailDeliveryCoordinator(
        database: () async => db,
        outboxRepository: outbox,
        settingsRepository: settingsRepo,
        credentialStore: _FakeCredStore('secret123'),
        senderService: EmailSenderService(
          checker: (_, {timeout}) async {},
          sendFunction: (msg, srv, {timeout}) async =>
              throw SmtpClientCommunicationException('Dropped after BDAT'),
        ),
      );
      await coordinator.processOutbox();
      final jobs = await outbox.getJobsForVisit(10);
      expect(jobs.single['status'], equals('uncertain_timeout'));
      expect(jobs.single['failure_reason'], equals('uncertain_timeout'));
    });

    test('auto-send disabled suppresses automatic resume processing', () async {
      await db.update('technician_profile', {'email_auto_send': 0});
      await outbox.createJobs([makeJob('k@e.com')]);
      final coordinator = EmailDeliveryCoordinator(
        database: () async => db,
        outboxRepository: outbox,
        settingsRepository: settingsRepo,
        credentialStore: _FakeCredStore('secret123'),
        senderService: EmailSenderService(
          checker: (_, {timeout}) async {},
          sendFunction: (msg, srv, {timeout}) async =>
              SendReport(msg, DateTime.now(), DateTime.now(), DateTime.now()),
        ),
      );
      await coordinator.processOutbox(forceManual: false);
      expect((await outbox.getJobsForVisit(10)).single['status'],
          equals('queued'));

      await coordinator.processOutbox(forceManual: true);
      expect(
          (await outbox.getJobsForVisit(10)).single['status'], equals('sent'));
    });
  });
}
