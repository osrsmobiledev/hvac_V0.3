import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/localization/reiniging_dictionary.dart';
import 'package:hvac_app/app/shell/app_shell_controller.dart';
import 'package:hvac_app/app/shell/app_shell_screen.dart';
import 'package:hvac_app/core/database/app_database.dart';
import 'package:hvac_app/core/services/app_warmup_service.dart';
import 'package:hvac_app/features/certificate_draft/data/draft_repository.dart';
import 'package:hvac_app/features/certificate_draft/domain/draft_visit.dart';
import 'package:hvac_app/features/certificate_draft/ui/reinigingsattest_screen.dart';
import 'package:hvac_app/features/email_delivery/data/email_delivery_coordinator.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class _NoopDeliveryCoordinator extends EmailDeliveryCoordinator {
  @override
  Future<OutboxDispatchResult> processOutbox({bool forceManual = false}) async {
    return OutboxDispatchResult.success;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;

  setUp(() async {
    AppWarmupService.instance.resetForTesting();
    db = await AppDatabase.instance
        .initDatabase(customPath: inMemoryDatabasePath);
    AppDatabase.instance.setDatabaseForTesting(db);
    await AppWarmupService.instance.warmup();
  });

  tearDown(() async {
    AppWarmupService.instance.resetForTesting();
    await AppDatabase.instance.close();
  });

  Future<void> flushDb(WidgetTester tester) async {
    for (var i = 0; i < 8; i++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }

  testWidgets(
      'ReinigingsattestScreen renders all 7 tabs and isolates draft from verbranding',
      (tester) async {
    // Seed visit #1 ('verbranding') with empty activityType and a distinct attest number.
    await tester.runAsync(() async {
      final vSeed = await DraftRepository()
          .getOrCreateActiveDraft(certificateType: 'verbranding');
      await DraftRepository().updateStartTabDraft(
        visitId: vSeed.id,
        activityType: '',
        attestNumber: 'V-001',
      );
    });

    final controller = AppShellController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ReinigingsattestScreen(controller: controller)),
      ),
    );
    await flushDb(tester);

    for (final title in ReinigingDictionary.reinigingTabs) {
      expect(find.text(title), findsOneWidget);
    }

    // Tap Tab 5 (Reiniging en controle) and verify its checklist card renders.
    await tester.ensureVisible(find.text('Reiniging en controle'));
    await tester.tap(find.text('Reiniging en controle'));
    await flushDb(tester);
    expect(find.text(ReinigingDictionary.headerFlue), findsOneWidget);
    expect(find.text(ReinigingDictionary.subFlue), findsOneWidget);
    expect(find.text(AppDictionary.headerRookgassen), findsNothing);

    // Verify both verbranding (from warmup) and reiniging drafts exist separately,
    // and that opening ReinigingsattestScreen never mutated visit #1.
    late DraftVisit vDraft;
    late DraftVisit rDraft;
    await tester.runAsync(() async {
      vDraft = await DraftRepository()
          .getOrCreateActiveDraft(certificateType: 'verbranding');
      rDraft = await DraftRepository()
          .getOrCreateActiveDraft(certificateType: 'reiniging');
    });
    expect(vDraft.id, isNot(rDraft.id));
    expect(vDraft.activityType, isEmpty);
    expect(vDraft.attestNumber, 'V-001');
    controller.dispose();
  });

  testWidgets('AppShellScreen opens ReinigingsattestScreen from Dashboard',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AppShellScreen(
          deliveryCoordinator: _NoopDeliveryCoordinator(),
        ),
      ),
    );
    await flushDb(tester);

    await tester.tap(find.text(AppDictionary.appletTitleReinigingsattest));
    await flushDb(tester);

    expect(find.byType(ReinigingsattestScreen), findsOneWidget);
    expect(find.text('Reiniging en controle'), findsOneWidget);
  });
}
