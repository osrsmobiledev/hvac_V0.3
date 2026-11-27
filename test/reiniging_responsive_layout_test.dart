import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/core/database/app_database.dart';
import 'package:hvac_app/core/services/app_warmup_service.dart';
import 'package:hvac_app/features/certificate_draft/data/draft_repository.dart';
import 'package:hvac_app/features/certificate_draft/domain/draft_visit.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/eindbeoordeling_tab.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/firma_technicus_tab.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/reiniging_controle_tab.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/start_tab.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'helpers/responsive_layout_guard.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late int reinigingVisitId;

  Future<void> flushDb(WidgetTester tester) async {
    for (var i = 0; i < 8; i++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }

  setUp(() async {
    AppWarmupService.instance.resetForTesting();
    db = await AppDatabase.instance
        .initDatabase(customPath: inMemoryDatabasePath);
    AppDatabase.instance.setDatabaseForTesting(db);
    final DraftVisit draft = await DraftRepository()
        .getOrCreateActiveDraft(certificateType: 'reiniging');
    reinigingVisitId = draft.id;
  });

  tearDown(() async {
    AppWarmupService.instance.resetForTesting();
    await AppDatabase.instance.close();
  });

  testWidgets(
      'Tab 1 (StartTab) has no overflow or shrunk labels on 360px/768px',
      (tester) async {
    await expectNoOverflowOrShrunkLabels(
      tester,
      MaterialApp(
        home: Scaffold(
          body:
              StartTab(visitId: reinigingVisitId, certificateType: 'reiniging'),
        ),
      ),
      afterPump: flushDb,
    );
  });

  testWidgets(
      'Tab 2 (FirmaTechnicusTab) has no overflow or shrunk labels on 360px/768px',
      (tester) async {
    await expectNoOverflowOrShrunkLabels(
      tester,
      MaterialApp(
        home: Scaffold(
          body: FirmaTechnicusTab(
            visitId: reinigingVisitId,
            certificateType: 'reiniging',
          ),
        ),
      ),
      afterPump: flushDb,
    );
  });

  testWidgets(
      'Tab 5 (ReinigingControleTab) has no overflow or shrunk labels on 360px/768px',
      (tester) async {
    await expectNoOverflowOrShrunkLabels(
      tester,
      MaterialApp(
        home: Scaffold(
          body: ReinigingControleTab(visitId: reinigingVisitId),
        ),
      ),
      afterPump: flushDb,
    );
  });

  testWidgets(
      'Tab 6 (EindbeoordelingTab) has no overflow or shrunk labels on 360px/768px',
      (tester) async {
    await expectNoOverflowOrShrunkLabels(
      tester,
      MaterialApp(
        home: Scaffold(
          body: EindbeoordelingTab(
            visitId: reinigingVisitId,
            certificateType: 'reiniging',
          ),
        ),
      ),
      afterPump: flushDb,
    );
  });
}
