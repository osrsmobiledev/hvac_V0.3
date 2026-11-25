import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/localization/eindbeoordeling_dictionary.dart';
import 'package:hvac_app/app/localization/visit_history_dictionary.dart';
import 'package:hvac_app/app/shell/app_shell_controller.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/core/database/app_database.dart';
import 'package:hvac_app/core/services/app_warmup_service.dart';
import 'package:hvac_app/core/utils/debouncer.dart';
import 'package:hvac_app/features/certificate_draft/ui/draft_save_scope.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/klant/klant_edit_session.dart';
import 'package:hvac_app/features/certificate_draft/ui/verbrandingsattest_screen.dart';
import 'package:hvac_app/features/certificate_draft/ui/visit_finalization.dart';
import 'package:hvac_app/features/email_delivery/ui/email_recipient_dialog.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'verbrandingsattest_klant_unsaved_seed.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late Directory tempDir;
  late String sigPath;

  setUp(() async {
    AppWarmupService.instance.invalidate();
    tempDir = await Directory.systemTemp.createTemp('klant_unsaved_test_');
    sigPath = '${tempDir.path}/tech_sig.png';
    await File(sigPath).writeAsBytes([137, 80, 78, 71]);
    db = await AppDatabase.instance.initDatabase(
      customPath: inMemoryDatabasePath,
    );
    AppDatabase.instance.setDatabaseForTesting(db);
  });

  tearDown(() async {
    AppWarmupService.instance.invalidate();
    await AppDatabase.instance.close();
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  testWidgets(
      'executeWorkflow maps blocked DraftSaveScope to VisitFinalizationException',
      (tester) async {
    final debouncer = Debouncer(duration: const Duration(milliseconds: 100))
      ..saveBlocked = () => true;
    addTearDown(debouncer.dispose);
    late BuildContext ctx;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: Builder(builder: (c) {
        ctx = c;
        return const SizedBox.shrink();
      })),
    ));
    final scope = DraftSaveScope(saves: {debouncer}, child: const SizedBox());
    expect(
      () =>
          VisitFinalization.executeWorkflow(ctx, visitId: 1, saveScope: scope),
      throwsA(
        isA<VisitFinalizationException>().having(
          (e) => e.message,
          'message',
          VisitHistoryDictionary.customerEditing,
        ),
      ),
    );
    expect(find.byType(EmailRecipientDialog), findsNothing);
  });

  testWidgets(
      'VerbrandingsattestScreen teleports to Klant with toast when unsaved, then proceeds after Opslaan',
      (tester) async {
    tester.view.physicalSize = const Size(600, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester
        .runAsync(() => seedValidDraftWithPendingKlantEdit(db, sigPath));
    expect(KlantEditSession.fromJson('{"draftId":1}')?.draftId, 1);

    final controller = AppShellController()
      ..selectApplet(AppletType.combustion);
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(body: VerbrandingsattestScreen(controller: controller)),
    ));
    for (var i = 0; i < 20; i++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 30)));
      await tester.pump();
    }

    // Navigate to Tab 7 (Eindbeoordeling) and tap Voltooien without saving Klant.
    final eindTab = find.text(AppDictionary.combustionTabs[6]);
    await tester.ensureVisible(eindTab);
    await tester.pumpAndSettle();
    await tester.tap(eindTab);
    await tester.pumpAndSettle();
    final voltooien = find.text(EindbeoordelingDictionary.btnVoltooien);
    await tester.ensureVisible(voltooien);
    await tester.tap(voltooien);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(EmailRecipientDialog), findsNothing);
    final snackTexts = tester
        .widgetList<Text>(find.descendant(
          of: find.byType(SnackBar),
          matching: find.byType(Text),
        ))
        .map((t) => t.data)
        .toList();
    expect(snackTexts, contains(VisitHistoryDictionary.customerEditing));
    expect(find.byKey(const ValueKey('btn_save')), findsOneWidget);

    // Save Klant edits, then retry Voltooien.
    await tester.tap(find.byKey(const ValueKey('btn_save')));
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('btn_edit')), findsOneWidget);

    await tester.ensureVisible(eindTab);
    await tester.pumpAndSettle();
    await tester.tap(eindTab);
    await tester.pumpAndSettle();
    await tester.ensureVisible(voltooien);
    await tester.tap(voltooien);
    for (var i = 0; i < 20; i++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 30)));
      await tester.pump();
      if (find.byType(EmailRecipientDialog).evaluate().isNotEmpty) break;
    }

    expect(find.text(VisitHistoryDictionary.customerEditing), findsNothing);
    expect(find.byType(EmailRecipientDialog), findsOneWidget);
  });
}
