import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/localization/email_delivery_dictionary.dart';
import 'package:hvac_app/core/database/database_schema.dart';
import 'package:hvac_app/features/email_delivery/data/email_outbox_repository.dart';
import 'package:hvac_app/features/email_delivery/ui/email_delivery_card.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'email_delivery_mock_coordinator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Directory tempDir;
  late Database db;
  late EmailOutboxRepository outbox;
  late File dummyPdf;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('card_test_');
    dummyPdf = File(p.join(tempDir.path, 'test_cert.pdf'))
      ..writeAsBytesSync([1, 2, 3, 4]);
    db = await databaseFactoryFfi.openDatabase(
      p.join(tempDir.path, 'test.db'),
      options: OpenDatabaseOptions(
        version: DatabaseSchema.version,
        onCreate: (db, _) => DatabaseSchema.createAllTables(db),
      ),
    );
    outbox = EmailOutboxRepository(database: () async => db);
    await db.insert('technician_profile', <String, Object?>{
      'id': 1,
      'company_name': 'Warmte BV',
      'kbo_number': '0123.456.789',
      'email': 'warmte@example.com',
      'smtp_host': 'smtp.example.com',
      'smtp_port': 465,
      'smtp_username': 'warmte@example.com',
      'smtp_provider': 'custom',
      'smtp_state': 'configured',
      'created_at': '2026-02-01',
      'updated_at': '2026-02-01'
    });
    await db.insert('maintenance_visits', <String, Object?>{
      'id': 42,
      'visit_date': '2026-02-01',
      'is_draft': 0,
      'pdf_status': 'ready',
      'pdf_path': dummyPdf.path,
      'created_at': '2026-02-01',
      'updated_at': '2026-02-01'
    });
  });

  tearDown(() async {
    await db.close();
    try {
      if (await tempDir.exists()) await tempDir.delete(recursive: true);
    } catch (_) {}
  });

  Future<void> insertJob(
    WidgetTester tester, {
    required int id,
    required String status,
    String? originalEmail,
    String? lastError,
    String? failureReason,
    String? pdfPathOverride,
  }) =>
      tester.runAsync(() => db.insert('email_delivery_jobs', <String, Object?>{
            'id': id,
            'visit_id': 42,
            'recipient_type': 'customer',
            'recipient_name': 'Jan',
            'recipient_email': 'jan@example.com',
            'original_recipient_email': originalEmail ?? 'jan@example.com',
            'subject': 'Attest',
            'body_text': 'Body',
            'pdf_path': pdfPathOverride ?? dummyPdf.path,
            'status': status,
            'failure_reason': failureReason,
            'last_error': lastError,
            'attempt_count': 0,
            'created_at': '2026-02-01',
            'updated_at': '2026-02-01'
          }));

  Future<void> pumpCard(WidgetTester tester) async {
    for (int i = 0; i < 6; i++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pump(const Duration(milliseconds: 20));
    }
  }

  testWidgets('Renders empty message when visit has no jobs', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
          body: EmailDeliveryCard(visitId: 42, outboxRepository: outbox)),
    ));
    await pumpCard(tester);
    expect(find.text(EmailDeliveryDictionary.trackerNoJobs), findsOneWidget);
    expect(find.text(EmailDeliveryDictionary.actionSendEmailLater),
        findsOneWidget);
    expect(find.text(EmailDeliveryDictionary.actionSharePdf), findsOneWidget);
  });

  testWidgets('Queued job renders and triggers manual send', (tester) async {
    await insertJob(tester, id: 1, status: 'queued');
    final coord = MockEmailDeliveryCoordinator();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: EmailDeliveryCard(
            visitId: 42, outboxRepository: outbox, coordinator: coord),
      ),
    ));
    await pumpCard(tester);

    expect(find.text(EmailDeliveryDictionary.badgeQueued), findsOneWidget);
    await tester.tap(find.text(EmailDeliveryDictionary.actionSendNow));
    await pumpCard(tester);
    expect(coord.manualProcessCalls, 1);
  });

  testWidgets('Unconfigured SMTP greys out send button and shows notice',
      (tester) async {
    await tester.runAsync(
        () => db.update('technician_profile', {'smtp_state': 'unconfigured'}));
    await insertJob(tester, id: 5, status: 'queued');
    final coord = MockEmailDeliveryCoordinator(db: db);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: EmailDeliveryCard(
            visitId: 42, outboxRepository: outbox, coordinator: coord),
      ),
    ));
    await pumpCard(tester);

    expect(find.text(EmailDeliveryDictionary.outboxUnconfiguredNotice),
        findsOneWidget);
    final btn = tester.widget<FilledButton>(find.widgetWithText(
      FilledButton,
      EmailDeliveryDictionary.actionSendNow,
    ));
    expect(btn.onPressed, isNull);
  });

  testWidgets('Recipient rejected triggers address correction dialog and flow',
      (tester) async {
    await insertJob(tester,
        id: 2,
        status: 'recipient_rejected',
        lastError: 'Mailbox not found',
        failureReason: 'recipient_rejected');
    final coord = MockEmailDeliveryCoordinator();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: EmailDeliveryCard(
            visitId: 42, outboxRepository: outbox, coordinator: coord),
      ),
    ));
    await pumpCard(tester);

    expect(find.text(EmailDeliveryDictionary.badgeRecipientRejected),
        findsOneWidget);
    await tester.tap(find.text(EmailDeliveryDictionary.actionCorrectEmail));
    await pumpCard(tester);

    await tester.enterText(find.byType(TextField), 'nieuw@example.com');
    await tester.tap(find.text(EmailDeliveryDictionary.correctEmailConfirm));
    await pumpCard(tester);

    expect(coord.lastCorrectJobId, 2);
    expect(coord.lastCorrectEmail, 'nieuw@example.com');
  });

  testWidgets(
      'Uncertain timeout offers retry with confirmation and manual resolution',
      (tester) async {
    await insertJob(tester,
        id: 3, status: 'uncertain_timeout', lastError: 'Socket timeout');
    final coord = MockEmailDeliveryCoordinator();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: EmailDeliveryCard(
            visitId: 42, outboxRepository: outbox, coordinator: coord),
      ),
    ));
    await pumpCard(tester);

    expect(find.text(EmailDeliveryDictionary.badgeUncertainTimeout),
        findsOneWidget);

    // 1. Retry with duplicate warning
    await tester.tap(find.text(EmailDeliveryDictionary.actionRetry));
    await pumpCard(tester);
    expect(
        find.text(EmailDeliveryDictionary.uncertainRetryTitle), findsOneWidget);
    await tester.tap(find.text(EmailDeliveryDictionary.uncertainRetryConfirm));
    await pumpCard(tester);
    expect(coord.lastRetryJobId, 3);

    // 2. Manual resolution
    await tester.tap(find.text(EmailDeliveryDictionary.actionResolveManually));
    await pumpCard(tester);
    expect(
        find.text(EmailDeliveryDictionary.manualResolveTitle), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Attest uitgeprint');
    await tester.pump();
    await tester.tap(find.text(EmailDeliveryDictionary.manualResolveConfirm));
    await pumpCard(tester);

    expect(coord.lastResolveJobId, 3);
    expect(coord.lastResolveNotes, 'Attest uitgeprint');
  });
}
