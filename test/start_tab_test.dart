import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/core/database/app_database.dart';
import 'package:hvac_app/features/certificate_draft/data/draft_repository.dart';
import 'package:hvac_app/features/certificate_draft/domain/draft_visit.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/start_tab.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late DraftRepository repository;

  setUp(() async {
    db = await AppDatabase.instance.initDatabase(
      customPath: inMemoryDatabasePath,
    );
    AppDatabase.instance.setDatabaseForTesting(db);
    repository = DraftRepository();
  });

  tearDown(() async {
    await AppDatabase.instance.close();
  });

  Widget buildTestWidget() {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(
        body: StartTab(draftRepository: repository),
      ),
    );
  }

  Future<void> pumpStartTab(WidgetTester tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pump();
  }

  group('Slice 2.2 — Tab 2 (Start) UI & SQLite Auto-Save', () {
    testWidgets(
        'Renders Start tab form with activity options and sequence number field',
        (tester) async {
      await pumpStartTab(tester);

      // Verify Main Gold Dropdown Header
      expect(find.text('Start'), findsOneWidget);
      expect(find.text('Type activiteit'), findsOneWidget);

      // Verify Options
      expect(find.text('Onderhoud'), findsOneWidget);
      expect(find.text('Keuring voor eerste ingebruikname'), findsOneWidget);

      // Verify Sequence Number Field
      expect(find.text('Volgnummer Attest:'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets(
        'Tapping commissioning inspection updates selection and persists to SQLite',
        (tester) async {
      await pumpStartTab(tester);

      // Tap 'Keuring voor eerste ingebruikname'
      await tester.tap(find.text('Keuring voor eerste ingebruikname'));
      late DraftVisit draft;
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        draft = await repository.getOrCreateActiveDraft();
      });
      await tester.pump();

      // Verify in SQLite database
      expect(draft.activityType, equals('eerste_ingebruikname'));
    });

    testWidgets(
        'Entering sequence number debounces and persists to SQLite draft',
        (tester) async {
      await pumpStartTab(tester);

      // Enter sequence number
      await tester.enterText(find.byType(TextField), 'ATTEST-2026-999');
      // Wait for debounce timer (300ms) to trigger auto-save
      await tester.pump(const Duration(milliseconds: 350));
      late DraftVisit draft;
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        draft = await repository.getOrCreateActiveDraft();
      });

      // Verify in SQLite database
      expect(draft.attestNumber, equals('ATTEST-2026-999'));
    });

    testWidgets('Reloading Start tab restores entered data from SQLite',
        (tester) async {
      // Pre-populate draft in SQLite
      await tester.runAsync(() async {
        final initialDraft = await repository.getOrCreateActiveDraft();
        await repository.updateStartTabDraft(
          visitId: initialDraft.id,
          activityType: 'eerste_ingebruikname',
          attestNumber: 'SAVED-DRAFT-123',
        );
      });

      // Render fresh widget
      await pumpStartTab(tester);

      // Verify restored in form
      expect(find.text('SAVED-DRAFT-123'), findsOneWidget);
      late DraftVisit draft;
      await tester.runAsync(() async {
        draft = await repository.getOrCreateActiveDraft();
      });
      expect(draft.activityType, equals('eerste_ingebruikname'));
    });
  });
}
