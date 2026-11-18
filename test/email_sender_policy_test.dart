import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/localization/email_delivery_dictionary.dart';
import 'package:hvac_app/core/database/database_schema.dart';
import 'package:hvac_app/features/email_delivery/data/email_sender_service.dart';
import 'package:hvac_app/features/email_delivery/data/email_settings_model.dart';
import 'package:hvac_app/features/email_delivery/data/email_settings_repository.dart';
import 'package:hvac_app/features/email_delivery/data/secure_credential_store.dart';
import 'package:hvac_app/features/email_delivery/ui/email_settings_notifier.dart';
import 'package:mailer/smtp_server.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late MemorySecureCredentialStore secureStore;
  late EmailSettingsRepository repo;
  late EmailSettingsNotifier notifier;
  bool mockShouldSucceed = true;

  Future<void> mockChecker(SmtpServer server, {Duration? timeout}) async {
    if (!mockShouldSucceed) {
      throw const SocketException('Simulated offline / unreachable host');
    }
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
    mockShouldSucceed = true;
  });

  tearDown(() async {
    notifier.dispose();
    await db.close();
  });

  group('Sender Address Selection Policy Tests', () {
    test('Gmail uses format-valid username directly', () {
      const settings = EmailSettings(
        provider: SmtpProviderType.gmail,
        username: 'technician@company.be',
      );
      final sender = EmailSenderService.resolveSenderEmail(
        settings: settings,
        profileEmail: 'profile@company.be',
      );
      expect(sender, 'technician@company.be');
    });

    test('Gmail returns null when username is not a valid email', () {
      const settings = EmailSettings(
        provider: SmtpProviderType.gmail,
        username: 'just_a_username',
      );
      final sender = EmailSenderService.resolveSenderEmail(
        settings: settings,
        profileEmail: 'profile@company.be',
      );
      expect(sender, isNull);
    });

    test('Custom SMTP uses username when format-valid email', () {
      const settings = EmailSettings(
        provider: SmtpProviderType.custom,
        username: 'smtp_sender@custom-domain.com',
      );
      final sender = EmailSenderService.resolveSenderEmail(
        settings: settings,
        profileEmail: 'fallback@company.be',
      );
      expect(sender, 'smtp_sender@custom-domain.com');
    });

    test('Custom SMTP falls back to valid profile email when username is ID',
        () {
      const settings = EmailSettings(
        provider: SmtpProviderType.custom,
        username: 'account-id-12345',
      );
      final sender = EmailSenderService.resolveSenderEmail(
        settings: settings,
        profileEmail: 'technician@company.be',
      );
      expect(sender, 'technician@company.be');
    });

    test('Custom SMTP returns null when both username and profile are invalid',
        () {
      const settings = EmailSettings(
        provider: SmtpProviderType.custom,
        username: 'account-id-12345',
      );
      final sender = EmailSenderService.resolveSenderEmail(
        settings: settings,
        profileEmail: 'invalid-email',
      );
      expect(sender, isNull);
    });
  });

  group('EmailSettingsNotifier Unit Tests', () {
    test('switching to custom provider updates host and port defaults', () {
      expect(notifier.settings.provider, SmtpProviderType.gmail);
      notifier.setProvider(SmtpProviderType.custom);
      expect(notifier.settings.provider, SmtpProviderType.custom);
      expect(notifier.settings.port, 587);
      expect(notifier.settings.useSsl, isFalse);

      notifier.setUseSsl(true);
      expect(notifier.settings.useSsl, isTrue);
      expect(notifier.settings.port, 465);
      expect(notifier.portController.text, '465');
    });

    test('testConnection fails when username or password is missing', () async {
      notifier.usernameController.clear();
      notifier.passwordController.clear();

      final success = await notifier.testConnection();
      expect(success, isFalse);
      expect(notifier.lastTestResult, SmtpConnectionResult.configurationError);
      expect(notifier.testResultMessage, EmailDeliveryDictionary.configError);
    });

    test('testConnection succeeds with valid credentials when checker passes',
        () async {
      notifier.usernameController.text = 'valid.user@gmail.com';
      notifier.passwordController.text = 'secret-app-pwd-16';
      mockShouldSucceed = true;

      final success = await notifier.testConnection();
      expect(success, isTrue);
      expect(notifier.lastTestResult, SmtpConnectionResult.success);
      expect(notifier.testResultMessage,
          EmailDeliveryDictionary.testConnectionSuccess);
    });

    test('testConnection reports error when checker throws exception',
        () async {
      notifier.usernameController.text = 'valid.user@gmail.com';
      notifier.passwordController.text = 'wrong-password';
      mockShouldSucceed = false;

      final success = await notifier.testConnection();
      expect(success, isFalse);
      expect(notifier.lastTestResult, SmtpConnectionResult.socketError);
      expect(notifier.testResultMessage, EmailDeliveryDictionary.socketError);
    });

    test('saveSettings stores settings and updates configured status',
        () async {
      notifier.usernameController.text = 'tech@company.be';
      notifier.passwordController.text = 'password123';
      notifier.setAutoSend(false);
      notifier.setCopyTechnician(true);

      final success = await notifier.saveSettings();
      expect(success, isTrue);
      expect(notifier.settings.isConfigured, isTrue);
      expect(notifier.settings.autoSend, isFalse);
      expect(await repo.getPassword(), 'password123');
    });

    test(
        'saveSettings rejects configuration when no format-valid sender exists',
        () async {
      notifier.setProvider(SmtpProviderType.custom);
      notifier.hostController.text = 'mail.my-server.com';
      notifier.usernameController.text = 'account-id-only';
      notifier.passwordController.text = 'password123';

      final success = await notifier.saveSettings();
      expect(success, isFalse);
      expect(notifier.saveErrorMessage,
          EmailDeliveryDictionary.invalidSenderError);
      expect(notifier.settings.isConfigured, isFalse);
    });
  });
}
