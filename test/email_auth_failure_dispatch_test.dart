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

  EmailJobSpec makeJob(
    int visitId,
    String email, {
    RecipientType type = RecipientType.customer,
  }) =>
      EmailJobSpec(
        visitId: visitId,
        recipientType: type,
        recipientName: type == RecipientType.customer ? 'Klant' : 'Technicus',
        recipientEmail: email,
        subject: 'Attest',
        bodyText: 'Body',
        pdfPath: dummyPdf.path,
      );

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('auth_fail_test_');
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

  group('SMTP Auth Failure During Send Tests', () {
    test(
        'authentication failure during sending returns needsAttention, not success',
        () async {
      await outbox.createJobs([makeJob(10, 'klant1@example.com')]);

      final coordinator = EmailDeliveryCoordinator(
        database: () async => db,
        outboxRepository: outbox,
        settingsRepository: settingsRepo,
        credentialStore: _FakeCredStore('secret123'),
        senderService: EmailSenderService(
          checker: (_, {timeout}) async {},
          sendFunction: (msg, srv, {timeout}) async =>
              throw SmtpClientAuthenticationException('Invalid credentials'),
        ),
      );

      final result = await coordinator.processOutbox();

      expect(result, equals(OutboxDispatchResult.needsAttention));
      expect(result, isNot(equals(OutboxDispatchResult.success)));

      final jobs = await outbox.getJobsForVisit(10);
      expect(jobs.length, 1);
      expect(jobs.first['status'], equals('server_rejected'));
      expect(jobs.first['failure_reason'], equals('authentication_failed'));
      expect(jobs.first['last_error'], equals('Invalid credentials'));

      final profile = (await db.query('technician_profile')).first;
      expect(profile['smtp_state'], equals('needs_attention'));
    });

    test(
        'authentication failure short-circuits: later queued jobs are not attempted',
        () async {
      await outbox.createJobs([
        makeJob(10, 'job1@example.com', type: RecipientType.customer),
        makeJob(10, 'job2@example.com', type: RecipientType.technician),
      ]);

      int sendAttempts = 0;
      final coordinator = EmailDeliveryCoordinator(
        database: () async => db,
        outboxRepository: outbox,
        settingsRepository: settingsRepo,
        credentialStore: _FakeCredStore('secret123'),
        senderService: EmailSenderService(
          checker: (_, {timeout}) async {},
          sendFunction: (msg, srv, {timeout}) async {
            sendAttempts++;
            throw SmtpClientAuthenticationException('Auth rejected');
          },
        ),
      );

      final result = await coordinator.processOutbox();

      expect(result, equals(OutboxDispatchResult.needsAttention));
      expect(sendAttempts, equals(1));

      final jobs = await outbox.getJobsForVisit(10);
      expect(jobs.length, 2);

      final job1 =
          jobs.firstWhere((j) => j['recipient_email'] == 'job1@example.com');
      final job2 =
          jobs.firstWhere((j) => j['recipient_email'] == 'job2@example.com');

      expect(job1['status'], equals('server_rejected'));
      expect(job1['failure_reason'], equals('authentication_failed'));

      expect(job2['status'], equals('queued'));
      expect(job2['attempt_count'], equals(0));
    });
  });
}
