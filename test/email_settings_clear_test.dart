import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/core/database/database_schema.dart';
import 'package:hvac_app/features/email_delivery/data/email_settings_repository.dart';
import 'package:hvac_app/features/email_delivery/data/secure_credential_store.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class FailingDeleteStore extends MemorySecureCredentialStore {
  FailingDeleteStore({super.initialPassword});
  @override
  Future<void> deletePassword() async =>
      throw StateError('Simulated KeyStore failure during delete');
}

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

  Future<void> insertTestProfile({
    String state = 'configured',
    String username = 'tech@firma.be',
    int autoSend = 1,
    int copyTech = 1,
  }) async {
    final now = DateTime.now().toIso8601String();
    await db.insert('technician_profile', {
      'company_name': 'Warmte BV',
      'kbo_number': '0123456789',
      'email': 'statutair@firma.be',
      'phone': '0470123456',
      'technician_first_name': 'Jan',
      'technician_last_name': 'Janssens',
      'smtp_provider': 'gmail',
      'smtp_host': 'smtp.gmail.com',
      'smtp_port': 465,
      'smtp_username': username,
      'smtp_use_ssl': 1,
      'email_auto_send': autoSend,
      'email_copy_technician': copyTech,
      'smtp_state': state,
      'created_at': now,
      'updated_at': now,
    });
  }

  group('EmailSettingsRepository clear & disconnect tests', () {
    test(
        'clearSettings clears SMTP, deletes secrets, preserves profile & queued jobs',
        () async {
      await insertTestProfile(autoSend: 1, copyTech: 1);
      final now = DateTime.now().toIso8601String();
      await db.insert('maintenance_visits', {
        'id': 1,
        'visit_date': '2026-11-17',
        'is_draft': 0,
        'created_at': now,
        'updated_at': now
      });
      await db.insert('email_delivery_jobs', {
        'visit_id': 1,
        'recipient_type': 'customer',
        'recipient_name': 'Klant Test',
        'recipient_email': 'klant@test.be',
        'original_recipient_email': 'klant@test.be',
        'subject': 'Attest',
        'body_text': 'Uw attest',
        'pdf_path': '/attest.pdf',
        'status': 'queued',
        'created_at': now,
        'updated_at': now
      });
      await secureStore.setStagedPassword('staged-123');
      secureStore =
          MemorySecureCredentialStore(initialPassword: 'active-password');
      repo = EmailSettingsRepository(db: db, secureStore: secureStore);

      await repo.clearSettings();

      final settings = await repo.loadSettings();
      expect(settings.smtpState, 'unconfigured');
      expect(settings.isConfigured, isFalse);
      expect(settings.username, '');
      expect(settings.autoSend, isFalse);
      expect(settings.copyTechnician, isTrue);
      expect(await repo.getPassword(), isNull);
      expect(await secureStore.getStagedPassword(), isNull);

      final profile = (await db.query('technician_profile')).first;
      expect(profile['company_name'], 'Warmte BV');
      expect(profile['email'], 'statutair@firma.be');
      expect(profile['technician_first_name'], 'Jan');
      expect(profile['email_copy_technician'], 1);

      final jobs = await db.query('email_delivery_jobs');
      expect(jobs.length, 1);
      expect(jobs.first['status'], 'queued');
    });

    test('startup recovery: interrupted clear in clearing state finalizes',
        () async {
      await insertTestProfile(state: 'clearing');
      secureStore =
          MemorySecureCredentialStore(initialPassword: 'lingering-secret');
      await secureStore.setStagedPassword('lingering-staged');
      repo = EmailSettingsRepository(db: db, secureStore: secureStore);

      final settings = await repo.loadSettings();
      expect(settings.smtpState, 'unconfigured');
      expect(await repo.getPassword(), isNull);
      expect(await secureStore.getStagedPassword(), isNull);
    });

    test(
        'startup recovery: configured state with missing password sets needs_attention',
        () async {
      await insertTestProfile(state: 'configured');
      secureStore = MemorySecureCredentialStore(); // empty
      repo = EmailSettingsRepository(db: db, secureStore: secureStore);

      final settings = await repo.loadSettings();
      expect(settings.smtpState, 'needs_attention');
      expect(settings.needsAttention, isTrue);
    });

    test('secure storage failure during clear leaves clearing state intact',
        () async {
      await insertTestProfile(state: 'configured');
      final failStore = FailingDeleteStore(initialPassword: 'pwd');
      repo = EmailSettingsRepository(db: db, secureStore: failStore);

      await expectLater(
        repo.clearSettings(),
        throwsA(isA<StateError>()),
      );

      final profile = (await db.query('technician_profile')).first;
      expect(profile['smtp_state'], 'clearing');
    });
  });
}
