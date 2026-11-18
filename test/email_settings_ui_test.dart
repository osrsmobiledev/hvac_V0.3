import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/localization/email_delivery_dictionary.dart';
import 'package:hvac_app/core/database/database_schema.dart';
import 'package:hvac_app/features/email_delivery/data/email_sender_service.dart';
import 'package:hvac_app/features/email_delivery/data/email_settings_repository.dart';
import 'package:hvac_app/features/email_delivery/data/secure_credential_store.dart';
import 'package:hvac_app/features/email_delivery/ui/email_settings_card.dart';
import 'package:hvac_app/features/email_delivery/ui/email_settings_notifier.dart';
import 'package:hvac_app/features/technician_settings/technician_settings_applet.dart';
import 'package:hvac_app/features/technician_settings/ui/technician_settings_screen.dart';
import 'package:mailer/smtp_server.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late MemorySecureCredentialStore secureStore;
  late EmailSettingsRepository repo;
  late EmailSettingsNotifier notifier;

  Future<void> mockChecker(SmtpServer server, {Duration? timeout}) async {
    // No-op for widget tests
  }

  setUp(() async {
    db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: DatabaseSchema.version,
        onCreate: (db, version) async {
          await DatabaseSchema.createAllTables(db);
        },
      ),
    );
    secureStore = MemorySecureCredentialStore();
    repo = EmailSettingsRepository(db: db, secureStore: secureStore);
    final sender = EmailSenderService(checker: mockChecker);
    notifier = EmailSettingsNotifier(repository: repo, senderService: sender);
    await notifier.init();
  });

  tearDown(() async {
    notifier.dispose();
    await db.close();
  });

  group('EmailSettingsCard & Screen Widget Tests', () {
    testWidgets('renders Bento card with inputs and buttons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: EmailSettingsCard(notifier: notifier),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(EmailDeliveryDictionary.cardTitle), findsOneWidget);
      expect(find.text(EmailDeliveryDictionary.providerGmail), findsOneWidget);
      expect(find.text(EmailDeliveryDictionary.providerCustom), findsOneWidget);
      expect(find.text(EmailDeliveryDictionary.usernameLabel), findsOneWidget);
      expect(find.text(EmailDeliveryDictionary.passwordLabel), findsOneWidget);
      expect(find.text(EmailDeliveryDictionary.testConnectionButton),
          findsOneWidget);
      expect(find.text(EmailDeliveryDictionary.saveSettingsButton),
          findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('toggling password visibility changes obscureText',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: EmailSettingsCard(notifier: notifier),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final iconButton = find.byType(IconButton);
      expect(iconButton, findsOneWidget);
      expect(notifier.isPasswordVisible, isFalse);
      await tester.tap(iconButton);
      await tester.pumpAndSettle();
      expect(notifier.isPasswordVisible, isTrue);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('shows warning banner when smtp_state is needs_attention',
        (tester) async {
      await tester.runAsync(() async {
        notifier.usernameController.text = 'user@gmail.com';
        await repo.saveSettings(
          settings: notifier.settings.copyWith(smtpState: 'needs_attention'),
        );
        await notifier.init();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: EmailSettingsCard(notifier: notifier),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(EmailDeliveryDictionary.needsAttentionWarning),
          findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets(
        'TechnicianSettingsScreen renders card top-aligned with maxWidth 600',
        (tester) async {
      tester.view.physicalSize = const Size(1000, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TechnicianSettingsScreen(notifier: notifier),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(EmailSettingsCard), findsOneWidget);
      expect(find.text(EmailDeliveryDictionary.cardTitle), findsOneWidget);
      final cardTop = tester.getTopLeft(find.byType(EmailSettingsCard)).dy;
      expect(cardTop, equals(12.0));
      final cardWidth = tester.getSize(find.byType(EmailSettingsCard)).width;
      expect(cardWidth, lessThanOrEqualTo(600.0));
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets(
        'TechnicianSettingsApplet renders screen with injected notifier',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TechnicianSettingsApplet(notifier: notifier),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TechnicianSettingsScreen), findsOneWidget);
      expect(find.byType(EmailSettingsCard), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('TechnicianSettingsApplet shows error UI on factory failure',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TechnicianSettingsApplet(
              notifierFactory: () async => throw Exception('DB fault'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
          find.text(EmailDeliveryDictionary.initSettingsError), findsOneWidget);
      expect(find.text(EmailDeliveryDictionary.btnRetryInit), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets(
        'TechnicianSettingsApplet disposes candidate notifier if unmounted while pending',
        (tester) async {
      final candidateNotifier = EmailSettingsNotifier(
        repository: repo,
        senderService: EmailSenderService(checker: mockChecker),
      );
      final completer = Completer<EmailSettingsNotifier>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TechnicianSettingsApplet(
              notifierFactory: () => completer.future,
            ),
          ),
        ),
      );
      await tester.pump();

      // Unmount while async initialization is pending
      await tester.pumpWidget(const SizedBox());

      completer.complete(candidateNotifier);
      await tester.idle();

      // Calling notifyListeners throws FlutterError if notifier was disposed
      expect(() => candidateNotifier.notifyListeners(), throwsFlutterError);
    });
  });
}
