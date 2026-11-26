import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/core/database/app_database.dart';
import 'package:hvac_app/core/database/database_schema.dart';
import 'package:hvac_app/core/services/app_warmup_service.dart';
import 'package:hvac_app/features/certificate_draft/data/draft_repository.dart';
import 'package:hvac_app/features/certificate_draft/data/technician_profile_repository.dart';
import 'package:hvac_app/features/certificate_draft/domain/technician_profile.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late DraftRepository draftRepo;

  setUp(() async {
    AppWarmupService.instance.resetForTesting();
    db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: DatabaseSchema.version,
        onConfigure: (d) => d.execute('PRAGMA foreign_keys = ON;'),
        onCreate: (d, _) => DatabaseSchema.createAllTables(d),
      ),
    );
    draftRepo = DraftRepository();
  });

  tearDown(() async {
    AppWarmupService.instance.resetForTesting();
    await db.close();
  });

  group('Certificate-Type Draft Isolation & Warmup Fallback', () {
    test('verbranding, reiniging, and combined active drafts never collide',
        () async {
      final vDraft = await draftRepo.getOrCreateActiveDraft(
          certificateType: 'verbranding', dbOverride: db);
      final rDraft = await draftRepo.getOrCreateActiveDraft(
          certificateType: 'reiniging', dbOverride: db);
      final cDraft = await draftRepo.getOrCreateActiveDraft(
          certificateType: 'combined', dbOverride: db);

      expect(vDraft.id, isNot(rDraft.id));
      expect(rDraft.id, isNot(cDraft.id));
      expect(vDraft.certificateType, 'verbranding');
      expect(rDraft.certificateType, 'reiniging');
      expect(cDraft.certificateType, 'combined');

      // Updating reiniging draft does not affect verbranding or combined.
      await draftRepo.updateStartTabDraft(
        visitId: rDraft.id,
        activityType: 'onderhoud',
        attestNumber: 'R-100',
        dbOverride: db,
      );

      final vReloaded = await draftRepo.getOrCreateActiveDraft(
          certificateType: 'verbranding', dbOverride: db);
      final rReloaded = await draftRepo.getOrCreateActiveDraft(
          certificateType: 'reiniging', dbOverride: db);
      expect(vReloaded.attestNumber, isEmpty);
      expect(rReloaded.attestNumber, 'R-100');
    });

    test('TechnicianProfile persists isErkendTechnicus and isSchoorsteenveger',
        () async {
      final profileRepo = TechnicianProfileRepository();
      const profile = TechnicianProfile(
        companyName: 'Test BV',
        kboNumber: '0123456789',
        isErkendTechnicus: false,
        isSchoorsteenveger: true,
      );
      await profileRepo.saveProfile(profile, dbOverride: db);
      final loaded = await profileRepo.getProfile(dbOverride: db);
      expect(loaded.isErkendTechnicus, isFalse);
      expect(loaded.isSchoorsteenveger, isTrue);
    });

    test(
        'AppWarmupService.activeDraftFor returns null on certificateType mismatch',
        () async {
      AppDatabase.instance.setDatabaseForTesting(db);
      await AppWarmupService.instance.warmup(
        draftRepoOverride: draftRepo,
        profileRepoOverride: TechnicianProfileRepository(),
      );

      expect(
        AppWarmupService.instance.activeDraftFor('verbranding'),
        isNotNull,
      );
      expect(
        AppWarmupService.instance.activeDraftFor('reiniging'),
        isNull,
      );
      expect(
        AppWarmupService.instance.activeDraftFor('combined'),
        isNull,
      );
    });
  });
}
