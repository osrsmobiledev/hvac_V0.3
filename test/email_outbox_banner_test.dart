import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/localization/email_delivery_dictionary.dart';
import 'package:hvac_app/core/database/database_schema.dart';
import 'package:hvac_app/features/email_delivery/data/email_delivery_coordinator.dart';
import 'package:hvac_app/features/email_delivery/data/email_outbox_repository.dart';
import 'package:hvac_app/features/email_delivery/ui/email_delivery_card.dart';
import 'package:hvac_app/features/email_delivery/ui/email_outbox_banner.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'email_delivery_mock_coordinator.dart';

class _TransitioningAuthCoordinator extends MockEmailDeliveryCoordinator {
  _TransitioningAuthCoordinator(Database db) : super(db: db);

  @override
  Future<OutboxDispatchResult> processOutbox({bool forceManual = false}) async {
    manualProcessCalls++;
    await db!.update(
      'technician_profile',
      {'smtp_state': 'needs_attention'},
    );
    return OutboxDispatchResult.needsAttention;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  testWidgets('needsAttention takes precedence over !isConfigured',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: EmailOutboxBanner(
          isConfigured: false,
          needsAttention: true,
          isOffline: false,
        ),
      ),
    ));

    expect(find.text(EmailDeliveryDictionary.outboxNeedsAttentionNotice),
        findsOneWidget);
    expect(find.text(EmailDeliveryDictionary.outboxUnconfiguredNotice),
        findsNothing);
  });

  testWidgets('unconfigured shows unconfigured notice when not needsAttention',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: EmailOutboxBanner(
          isConfigured: false,
          needsAttention: false,
          isOffline: false,
        ),
      ),
    ));

    expect(find.text(EmailDeliveryDictionary.outboxUnconfiguredNotice),
        findsOneWidget);
    expect(find.text(EmailDeliveryDictionary.outboxNeedsAttentionNotice),
        findsNothing);
  });

  testWidgets('configured and offline shows offline notice', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: EmailOutboxBanner(
          isConfigured: true,
          needsAttention: false,
          isOffline: true,
        ),
      ),
    ));

    expect(
        find.text(EmailDeliveryDictionary.outboxOfflineNotice), findsOneWidget);
  });

  group('EmailDeliveryCard live needsAttention transition', () {
    late Directory tempDir;
    late Database db;
    late EmailOutboxRepository outbox;
    late File dummyPdf;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('banner_card_test_');
      dummyPdf = File(p.join(tempDir.path, 'cert.pdf'))
        ..writeAsBytesSync([1, 2, 3]);
      db = await databaseFactoryFfi.openDatabase(
        p.join(tempDir.path, 'test.db'),
        options: OpenDatabaseOptions(
          version: DatabaseSchema.version,
          onCreate: (d, _) => DatabaseSchema.createAllTables(d),
        ),
      );
      outbox = EmailOutboxRepository(database: () async => db);
      await db.insert('technician_profile', <String, Object?>{
        'id': 1,
        'company_name': 'Warmte BV',
        'kbo_number': '0123.456.789',
        'email': 'warmte@example.com',
        'smtp_state': 'configured',
        'created_at': '2026-02-01',
        'updated_at': '2026-02-01',
      });
      await db.insert('maintenance_visits', <String, Object?>{
        'id': 42,
        'visit_date': '2026-02-01',
        'is_draft': 0,
        'pdf_status': 'ready',
        'pdf_path': dummyPdf.path,
        'created_at': '2026-02-01',
        'updated_at': '2026-02-01',
      });
      await db.insert('email_delivery_jobs', <String, Object?>{
        'id': 1,
        'visit_id': 42,
        'recipient_type': 'customer',
        'recipient_name': 'Jan',
        'recipient_email': 'jan@example.com',
        'original_recipient_email': 'jan@example.com',
        'subject': 'Attest',
        'body_text': 'Body',
        'pdf_path': dummyPdf.path,
        'status': 'queued',
        'attempt_count': 0,
        'created_at': '2026-02-01',
        'updated_at': '2026-02-01',
      });
    });

    tearDown(() async {
      if (db.isOpen) await db.close();
      try {
        if (await tempDir.exists()) await tempDir.delete(recursive: true);
      } catch (_) {}
    });

    Future<void> pumpCard(WidgetTester tester) async {
      for (int i = 0; i < 6; i++) {
        await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 20)));
        await tester.pump(const Duration(milliseconds: 20));
      }
    }

    testWidgets(
        'Nu verzenden auth failure immediately shows persistent needsAttention banner',
        (tester) async {
      final coord = _TransitioningAuthCoordinator(db);
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: EmailDeliveryCard(
              visitId: 42,
              outboxRepository: outbox,
              coordinator: coord,
            ),
          ),
        ),
      ));
      await pumpCard(tester);

      expect(find.text(EmailDeliveryDictionary.outboxNeedsAttentionNotice),
          findsNothing);
      expect(find.text(EmailDeliveryDictionary.outboxUnconfiguredNotice),
          findsNothing);

      await tester.tap(find.text(EmailDeliveryDictionary.actionSendNow));
      await pumpCard(tester);

      expect(coord.manualProcessCalls, 1);
      // Both the persistent banner and snackbar may display outboxNeedsAttentionNotice;
      // critically, the persistent banner must NOT fall back to outboxUnconfiguredNotice.
      expect(find.text(EmailDeliveryDictionary.outboxNeedsAttentionNotice),
          findsAtLeastNWidgets(1));
      expect(find.text(EmailDeliveryDictionary.outboxUnconfiguredNotice),
          findsNothing);
      expect(find.byIcon(Icons.lock_reset), findsOneWidget);
    });
  });
}
