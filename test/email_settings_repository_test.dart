import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/core/database/database_schema.dart';
import 'package:hvac_app/features/email_delivery/data/email_settings_model.dart';
import 'package:hvac_app/features/email_delivery/data/email_settings_repository.dart';
import 'package:hvac_app/features/email_delivery/data/secure_credential_store.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  final databaseFactory = databaseFactoryFfi;

  late Database db;
  late MemorySecureCredentialStore secureStore;
  late EmailSettingsRepository repo;

  setUp(() async {
    db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: DatabaseSchema.version,
        onCreate: (db, _) => DatabaseSchema.createAllTables(db),
      ),
    );
    secureStore = MemorySecureCredentialStore();
    repo = EmailSettingsRepository(db: db, secureStore: secureStore);
  });

  tearDown(() async => db.close());

  Map<String, dynamic> createProfileMap({
    String state = 'staging',
    String username = 'test@gmail.com',
    String host = 'smtp.gmail.com',
    int port = 465,
    String provider = 'gmail',
  }) =>
      {
        'company_name': 'Test BV',
        'kbo_number': '0123456789',
        'smtp_provider': provider,
        'smtp_host': host,
        'smtp_port': port,
        'smtp_username': username,
        'smtp_use_ssl': 1,
        'email_auto_send': 1,
        'email_copy_technician': 1,
        'smtp_state': state,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

  group('SQLite v12 Schema & Email Delivery Jobs Table', () {
    test(
        'fresh database contains email_delivery_jobs and technician_profile SMTP columns',
        () async {
      final profileInfo =
          await db.rawQuery('PRAGMA table_info(technician_profile);');
      final profileColumns =
          profileInfo.map((row) => row['name'] as String).toSet();
      for (final col
          in 'smtp_host,smtp_port,smtp_username,smtp_use_ssl,smtp_provider,email_auto_send,email_copy_technician,smtp_state'
              .split(',')) {
        expect(profileColumns, contains(col));
      }

      final jobsInfo =
          await db.rawQuery('PRAGMA table_info(email_delivery_jobs);');
      final jobsColumns = jobsInfo.map((row) => row['name'] as String).toSet();
      for (final col
          in 'id,visit_id,recipient_type,recipient_name,recipient_email,original_recipient_email,status,pdf_path'
              .split(',')) {
        expect(jobsColumns, contains(col));
      }
    });
  });

  group('Staged Credential Protocol & Repository Storage', () {
    test('default settings load unconfigured state when empty', () async {
      final settings = await repo.loadSettings();
      expect(settings.provider, SmtpProviderType.gmail);
      expect(settings.host, 'smtp.gmail.com');
      expect(settings.port, 465);
      expect(settings.useSsl, isTrue);
      expect(settings.autoSend, isTrue);
      expect(settings.copyTechnician, isTrue);
      expect(settings.smtpState, 'unconfigured');
      expect(settings.hasPassword, isFalse);
    });

    test(
        'saveSettings stages, promotes password and marks configured in SQLite',
        () async {
      const newSettings = EmailSettings(username: 'test.technicus@gmail.com');

      await repo.saveSettings(
        settings: newSettings,
        newPassword: 'my-app-password-1234',
      );

      final loaded = await repo.loadSettings();
      expect(loaded.smtpState, 'configured');
      expect(loaded.username, 'test.technicus@gmail.com');
      expect(loaded.hasPassword, isTrue);

      final activePassword = await repo.getPassword();
      expect(activePassword, 'my-app-password-1234');

      final stagedPassword = await secureStore.getStagedPassword();
      expect(stagedPassword, isNull,
          reason: 'Staged key must be deleted after promotion');
    });

    test('non-password update preserves existing password in secure storage',
        () async {
      const initial = EmailSettings(username: 'initial@gmail.com');
      await repo.saveSettings(
          settings: initial, newPassword: 'existing-secret');

      final updated = initial.copyWith(
        username: 'updated@gmail.com',
        autoSend: false,
      );
      await repo.saveSettings(settings: updated);

      final loaded = await repo.loadSettings();
      expect(loaded.username, 'updated@gmail.com');
      expect(loaded.autoSend, isFalse);
      expect(loaded.hasPassword, isTrue);
      expect(await repo.getPassword(), 'existing-secret');
    });

    test(
        'startup recovery: promotes staged password if app was interrupted in staging state',
        () async {
      await secureStore.setStagedPassword('recovered-secret-5678');
      await db.insert('technician_profile',
          createProfileMap(username: 'interrupted@gmail.com'));

      final loaded = await repo.loadSettings();
      expect(loaded.smtpState, 'configured');
      expect(await repo.getPassword(), 'recovered-secret-5678');
      expect(await secureStore.getStagedPassword(), isNull);
    });

    test(
        'startup recovery: promotes staged password but marks unconfigured if SMTP settings are incomplete',
        () async {
      await secureStore.setStagedPassword('recovered-secret-9999');
      await db.insert(
          'technician_profile',
          createProfileMap(
              provider: 'custom', host: '', port: 587, username: ''));

      final loaded = await repo.loadSettings();
      expect(loaded.smtpState, 'unconfigured');
      expect(loaded.isConfigured, isFalse);
      expect(loaded.hasPassword, isTrue);
      expect(await repo.getPassword(), 'recovered-secret-9999');
      expect(await secureStore.getStagedPassword(), isNull);
    });

    test(
        'startup recovery: marks needs_attention if in staging state with missing staged password, even with old active password',
        () async {
      secureStore =
          MemorySecureCredentialStore(initialPassword: 'old-active-pwd');
      repo = EmailSettingsRepository(db: db, secureStore: secureStore);

      await db.insert('technician_profile',
          createProfileMap(username: 'corrupt@gmail.com'));

      final loaded = await repo.loadSettings();
      expect(loaded.smtpState, 'needs_attention');
      expect(loaded.needsAttention, isTrue);
    });

    test(
        'startup recovery: discards orphaned staged credential when SQLite is not in staging',
        () async {
      // Partial failure: staged key written, but process failed before SQLite staging update.
      secureStore =
          MemorySecureCredentialStore(initialPassword: 'active-pwd-1111');
      await secureStore.setStagedPassword('orphaned-staged-secret-2222');
      repo = EmailSettingsRepository(db: db, secureStore: secureStore);

      await db.insert('technician_profile',
          createProfileMap(state: 'configured', username: 'active@gmail.com'));

      final loaded = await repo.loadSettings();

      // Outcome 1: Orphaned staged password is discarded
      expect(await secureStore.getStagedPassword(), isNull);

      // Outcome 2: Active password is unchanged
      expect(await repo.getPassword(), 'active-pwd-1111');

      // Outcome 3: Existing settings & smtp_state in SQLite are unchanged
      expect(loaded.smtpState, 'configured');
      expect(loaded.username, 'active@gmail.com');
    });

    test(
        'startup recovery: discards orphaned staged credential when profile table is empty',
        () async {
      // First-time save failure: staged key written, but failed before profile row was created.
      secureStore = MemorySecureCredentialStore(
          initialPassword: 'active-pwd-before-init');
      await secureStore.setStagedPassword('orphaned-first-save-secret');
      repo = EmailSettingsRepository(db: db, secureStore: secureStore);

      // Verify technician_profile table is completely empty
      final rows =
          await db.rawQuery('SELECT COUNT(*) as cnt FROM technician_profile');
      expect(rows.first['cnt'], 0);

      await repo.recoverCredentialsState();

      // Outcome 1: Orphaned staged password is discarded
      expect(await secureStore.getStagedPassword(), isNull);

      // Outcome 2: Active password is unchanged
      expect(await repo.getPassword(), 'active-pwd-before-init');

      // Outcome 3: Profile table remains empty
      final rowsAfter =
          await db.rawQuery('SELECT COUNT(*) as cnt FROM technician_profile');
      expect(rowsAfter.first['cnt'], 0);
    });

    test('promoteStagedPassword fails when staged value is missing', () async {
      expect(
        () => secureStore.promoteStagedPassword(),
        throwsA(isA<StateError>()),
      );
    });
  });
}
