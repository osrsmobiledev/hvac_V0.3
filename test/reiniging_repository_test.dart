import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/core/database/database_schema.dart';
import 'package:hvac_app/features/certificate_draft/data/eindbeoordeling_repository.dart';
import 'package:hvac_app/features/certificate_draft/data/reiniging_repository.dart';
import 'package:hvac_app/features/certificate_draft/domain/eindbeoordeling_draft.dart';
import 'package:hvac_app/features/certificate_draft/domain/reiniging_controls_draft.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late ReinigingRepository repo;
  late EindbeoordelingRepository eindRepo;
  late int visitId;

  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: DatabaseSchema.version,
        onConfigure: (d) => d.execute('PRAGMA foreign_keys = ON;'),
        onCreate: (d, _) => DatabaseSchema.createAllTables(d),
      ),
    );
    repo = ReinigingRepository();
    eindRepo = EindbeoordelingRepository();
    final now = DateTime.now().toIso8601String();
    visitId = await db.insert('maintenance_visits', {
      'certificate_type': 'reiniging',
      'visit_date': '2026-11-26',
      'is_draft': 1,
      'created_at': now,
      'updated_at': now,
    });
  });

  tearDown(() async => await db.close());

  group('ReinigingRepository & EindbeoordelingRepository v14 Tests', () {
    test('loadControls returns defaults when no row exists', () async {
      final loaded = await repo.loadControls(visitId, dbOverride: db);
      expect(loaded.hasAnySelected, isFalse);
      expect(loaded.allOtherText, isNull);
    });

    test('saveControls persists all 14 booleans + allOtherText and reloads',
        () async {
      const draft = ReinigingControlsDraft(
        flueSweeping: true,
        flueGoodOperationCheck: true,
        flueBackdraftCheck: true,
        allOtherChecked: true,
        allOtherText: 'Dichtingskoord vervangen',
        allVentilationCheck: true,
        allFlueTightnessCheck: true,
        gasDustRemoval: true,
        gasBurnerBedExchanger: true,
        gasFanBurner: true,
        liquidFilters: true,
        liquidBoiler: true,
        liquidBurner: true,
        solidGeneralCondition: true,
        solidInternalCleaning: true,
      );
      await repo.saveControls(visitId: visitId, draft: draft, dbOverride: db);

      final loaded = await repo.loadControls(visitId, dbOverride: db);
      expect(loaded.hasAnySelected, isTrue);
      expect(loaded.flueSweeping, isTrue);
      expect(loaded.flueBackdraftCheck, isTrue);
      expect(loaded.allOtherChecked, isTrue);
      expect(loaded.allOtherText, 'Dichtingskoord vervangen');
      expect(loaded.gasBurnerBedExchanger, isTrue);
      expect(loaded.liquidBurner, isTrue);
      expect(loaded.solidInternalCleaning, isTrue);
    });

    test('unchecking allOtherChecked prunes all_other_text to NULL in SQLite',
        () async {
      const checked = ReinigingControlsDraft(
        allOtherChecked: true,
        allOtherText: 'Moet gewist worden',
      );
      await repo.saveControls(visitId: visitId, draft: checked, dbOverride: db);

      // Even if a caller passes non-null text with allOtherChecked=false,
      // both the model and repository must prune it to null.
      const unchecked = ReinigingControlsDraft(
        allOtherChecked: false,
        allOtherText: 'Stale buffer',
      );
      expect(unchecked.toMap()['all_other_text'], isNull);

      await repo.saveControls(
          visitId: visitId, draft: unchecked, dbOverride: db);
      final rows = await db.query('reiniging_controls',
          where: 'visit_id = ?', whereArgs: [visitId]);
      expect(rows.single['all_other_checked'], 0);
      expect(rows.single['all_other_text'], isNull);
    });

    test('updateTechnicianRoles persists erkend and schoorsteenveger flags',
        () async {
      await repo.updateTechnicianRoles(
        visitId: visitId,
        isErkendTechnicus: false,
        isSchoorsteenveger: true,
        dbOverride: db,
      );
      final row = (await db.query('maintenance_visits',
              where: 'id = ?', whereArgs: [visitId]))
          .single;
      expect(row['technician_role_erkend'], 0);
      expect(row['technician_role_schoorsteenveger'], 1);
    });

    test(
        'EindbeoordelingRepository roundtrips remedialMeasuresNotes and nextChimneyInspectionDate',
        () async {
      const draft = EindbeoordelingDraft(
        defectsNotes: 'Scheur in rookgaskanaal',
        remedialMeasuresNotes: 'Kanaal laten herstellen',
        generalRemarks: 'Klant verwittigd',
        nextInspectionDate: '26/11/2027',
        nextChimneyInspectionDate: '26/11/2027',
      );
      await eindRepo.updateDraft(
          visitId: visitId, draft: draft, dbOverride: db);

      final loaded = await eindRepo.loadDraft(visitId: visitId, dbOverride: db);
      expect(loaded.remedialMeasuresNotes, 'Kanaal laten herstellen');
      expect(loaded.nextChimneyInspectionDate, '26/11/2027');

      final cleared = loaded.copyWith(
        remedialMeasuresNotes: null,
        nextChimneyInspectionDate: null,
      );
      await eindRepo.updateDraft(
          visitId: visitId, draft: cleared, dbOverride: db);
      final reloaded =
          await eindRepo.loadDraft(visitId: visitId, dbOverride: db);
      expect(reloaded.remedialMeasuresNotes, isNull);
      expect(reloaded.nextChimneyInspectionDate, isNull);
    });
  });
}
