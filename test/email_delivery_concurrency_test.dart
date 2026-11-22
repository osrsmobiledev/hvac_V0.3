import 'dart:async';
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

  EmailJobSpec makeJob(String email, {int visitId = 10}) => EmailJobSpec(
        visitId: visitId,
        recipientType: RecipientType.customer,
        recipientName: 'Klant',
        recipientEmail: email,
        subject: 'Attest',
        bodyText: 'B',
        pdfPath: dummyPdf.path,
      );

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('coord_extra_test_');
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

  group('Serialized Outbox & Stale Recovery Tests', () {
    test(
        'overlapping resume processing during live send does not convert active job to uncertain_timeout',
        () async {
      await outbox.createJobs([makeJob('live@example.com')]);
      final job = (await outbox.getJobsForVisit(10)).single;
      final jobId = job['id'] as int;

      final sendCompleter = Completer<void>();
      final coordinator1 = EmailDeliveryCoordinator(
        database: () async => db,
        outboxRepository: outbox,
        settingsRepository: settingsRepo,
        credentialStore: _FakeCredStore('secret123'),
        senderService: EmailSenderService(
          checker: (_, {timeout}) async {},
          sendFunction: (msg, srv, {timeout}) async {
            sendCompleter.complete();
            await Future<void>.delayed(const Duration(milliseconds: 50));
            return SendReport(
                msg, DateTime.now(), DateTime.now(), DateTime.now());
          },
        ),
      );

      final coordinator2 = EmailDeliveryCoordinator(
        database: () async => db,
        outboxRepository: outbox,
        settingsRepository: settingsRepo,
        credentialStore: _FakeCredStore('secret123'),
        senderService: EmailSenderService(checker: (_, {timeout}) async {}),
      );

      final future1 = coordinator1.processOutbox(forceManual: true);

      await sendCompleter.future;
      final sendingJob = (await db.query('email_delivery_jobs',
              where: 'id = ?', whereArgs: [jobId]))
          .single;
      expect(sendingJob['status'], equals('sending'));

      final future2 = coordinator2.processOutbox(forceManual: false);
      await Future.wait([future1, future2]);

      final finalJob = (await db.query('email_delivery_jobs',
              where: 'id = ?', whereArgs: [jobId]))
          .single;
      expect(finalJob['status'], equals('sent'));
      expect(finalJob['failure_reason'], isNull);
    });
  });

  group('Conditional Updates & Duplicate Prevention Tests', () {
    test('stale correction or retry cannot change a sent or resolved job',
        () async {
      await outbox.createJobs([makeJob('sent@example.com')]);
      final job = (await outbox.getJobsForVisit(10)).single;
      final jobId = job['id'] as int;

      await outbox.markSent(jobId, sentAt: '2026-01-01T12:00:00');

      final coordinator = EmailDeliveryCoordinator(
        database: () async => db,
        outboxRepository: outbox,
        settingsRepository: settingsRepo,
        credentialStore: _FakeCredStore('secret123'),
        senderService: EmailSenderService(checker: (_, {timeout}) async {}),
      );

      final correctResult =
          await coordinator.correctRecipientEmail(jobId, 'hack@example.com');
      expect(correctResult, isFalse);

      var checkJob = (await db.query('email_delivery_jobs',
              where: 'id = ?', whereArgs: [jobId]))
          .single;
      expect(checkJob['status'], equals('sent'));
      expect(checkJob['recipient_email'], equals('sent@example.com'));

      final retryResult = await coordinator.retryJob(jobId);
      expect(retryResult, isFalse);

      checkJob = (await db.query('email_delivery_jobs',
              where: 'id = ?', whereArgs: [jobId]))
          .single;
      expect(checkJob['status'], equals('sent'));

      await db.update(
        'email_delivery_jobs',
        {
          'status': 'resolved_manually',
          'resolved_at': '2026-01-01',
          'resolution_notes': 'Fixed'
        },
        where: 'id = ?',
        whereArgs: [jobId],
      );

      expect(
          await coordinator.correctRecipientEmail(jobId, 'hack2@example.com'),
          isFalse);
      expect(await coordinator.retryJob(jobId), isFalse);

      checkJob = (await db.query('email_delivery_jobs',
              where: 'id = ?', whereArgs: [jobId]))
          .single;
      expect(checkJob['status'], equals('resolved_manually'));
    });

    test('manual resolution requires non-empty explanation', () async {
      await outbox.createJobs([makeJob('fail@example.com')]);
      final job = (await outbox.getJobsForVisit(10)).single;
      final jobId = job['id'] as int;
      await outbox.markFailed(jobId,
          status: 'uncertain_timeout', failureReason: 'timeout');

      final coordinator = EmailDeliveryCoordinator(
        database: () async => db,
        outboxRepository: outbox,
        settingsRepository: settingsRepo,
        credentialStore: _FakeCredStore('secret123'),
      );

      expect(await coordinator.resolveJobManually(jobId, notes: ''), isFalse);
      expect(
          await coordinator.resolveJobManually(jobId, notes: '   '), isFalse);

      expect(
          await coordinator.resolveJobManually(jobId,
              notes: 'Op papier bezorgd'),
          isTrue);
      final resolved = (await db.query('email_delivery_jobs',
              where: 'id = ?', whereArgs: [jobId]))
          .single;
      expect(resolved['status'], equals('resolved_manually'));
      expect(resolved['resolution_notes'], equals('Op papier bezorgd'));
    });
  });
}
