import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/localization/eindbeoordeling_dictionary.dart';
import 'package:hvac_app/app/localization/reiniging_dictionary.dart';
import 'package:hvac_app/core/database/app_database.dart';
import 'package:hvac_app/core/services/app_warmup_service.dart';
import 'package:hvac_app/features/certificate_draft/data/draft_repository.dart';
import 'package:hvac_app/features/certificate_draft/domain/draft_visit.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/eindbeoordeling_tab.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/firma_technicus/technician_section.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/firma_technicus_tab.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/start_tab.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;

  Future<void> pumpAndFlushDb(WidgetTester tester, Widget widget) async {
    await tester.pumpWidget(widget);
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
  });

  tearDown(() async {
    AppWarmupService.instance.resetForTesting();
    await AppDatabase.instance.close();
  });

  group('Tab 1 (StartTab) mode deltas', () {
    testWidgets('verbranding mode shows Onderhoud and Keuring options',
        (tester) async {
      await pumpAndFlushDb(
        tester,
        const MaterialApp(home: Scaffold(body: StartTab())),
      );

      expect(find.text(AppDictionary.headerActivity), findsOneWidget);
      expect(find.text(AppDictionary.activityMaintenance), findsOneWidget);
      expect(
          find.text(AppDictionary.activityCommissioningShort), findsOneWidget);
      expect(find.text(ReinigingDictionary.headerStartReiniging), findsNothing);
    });

    testWidgets('reiniging mode shows Reiniging header and single option',
        (tester) async {
      await pumpAndFlushDb(
        tester,
        const MaterialApp(
          home: Scaffold(body: StartTab(certificateType: 'reiniging')),
        ),
      );

      expect(
          find.text(ReinigingDictionary.headerStartReiniging), findsOneWidget);
      expect(find.text(ReinigingDictionary.activityOnderhoudStooktoestel),
          findsOneWidget);
      expect(find.text(AppDictionary.activityCommissioningShort), findsNothing);
      expect(find.text(AppDictionary.lblSequenceNumber), findsOneWidget);
    });
  });

  group('Tab 2 (FirmaTechnicusTab) mode deltas & GV/TV gating', () {
    testWidgets('verbranding mode shows analyzer fields and requires GV/TV',
        (tester) async {
      GlobalKey<FormState>? formKey;
      await pumpAndFlushDb(
        tester,
        MaterialApp(
          home: Scaffold(
            body: FirmaTechnicusTab(onFormKeyReady: (k) => formKey = k),
          ),
        ),
      );

      expect(find.text(AppDictionary.lblAnalyzerBrand), findsOneWidget);
      expect(find.text(AppDictionary.lblAnalyzerSerial), findsOneWidget);
      expect(find.text(ReinigingDictionary.roleErkendTechnicus), findsNothing);
      expect(find.text(AppDictionary.lblDate), findsOneWidget);

      await tester.enterText(
          find.byKey(const ValueKey('technician_firstName')), 'Jan');
      await tester.enterText(
          find.byKey(const ValueKey('technician_lastName')), 'Peeters');
      expect(formKey!.currentState!.validate(), isFalse);
    });

    testWidgets(
        'reiniging mode hides analyzer, gates GV/TV on Erkend technicus',
        (tester) async {
      await pumpAndFlushDb(
        tester,
        const MaterialApp(
          home: Scaffold(
            body: FirmaTechnicusTab(
              certificateType: 'reiniging',
            ),
          ),
        ),
      );

      expect(find.text(AppDictionary.lblAnalyzerBrand), findsNothing);
      expect(find.text(AppDictionary.lblAnalyzerSerial), findsNothing);
      expect(find.text(ReinigingDictionary.lblDateReiniging), findsOneWidget);
      expect(
          find.text(ReinigingDictionary.roleErkendTechnicus), findsOneWidget);
      expect(
          find.text(ReinigingDictionary.roleSchoorsteenveger), findsOneWidget);

      // Verify TechnicianSection GV/TV validation flips when Erkend technicus is toggled OFF.
      final techFormKey = GlobalKey<FormState>();
      var isErkend = true;
      var isVeger = false;
      final first = TextEditingController(text: 'Jan');
      final last = TextEditingController(text: 'Peeters');
      final gv = TextEditingController();
      final tv = TextEditingController();
      final brand = TextEditingController();
      final serial = TextEditingController();
      final date = TextEditingController(text: '2026-11-26');
      final start = TextEditingController(text: '09:00');
      final end = TextEditingController(text: '10:00');
      addTearDown(() {
        for (final c in [
          first,
          last,
          gv,
          tv,
          brand,
          serial,
          date,
          start,
          end
        ]) {
          c.dispose();
        }
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => SingleChildScrollView(
                child: Form(
                  key: techFormKey,
                  child: TechnicianSection(
                    firstNameController: first,
                    lastNameController: last,
                    gvController: gv,
                    tvController: tv,
                    analyzerBrandController: brand,
                    analyzerSerialController: serial,
                    dateController: date,
                    startTimeController: start,
                    endTimeController: end,
                    onProfileChanged: () {},
                    onTimingsChanged: () {},
                    certificateType: 'reiniging',
                    isErkendTechnicus: isErkend,
                    isSchoorsteenveger: isVeger,
                    onToggleErkend: () => setState(() => isErkend = !isErkend),
                    onToggleSchoorsteenveger: () =>
                        setState(() => isVeger = !isVeger),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Erkend technicus ON -> empty GV/TV fails validation.
      expect(techFormKey.currentState!.validate(), isFalse);

      // Switch to Schoorsteenveger-only (Erkend technicus OFF) -> passes without GV/TV.
      await tester.tap(find.byKey(const ValueKey('role_schoorsteenveger')));
      await tester.tap(find.byKey(const ValueKey('role_erkend_technicus')));
      await tester.pumpAndSettle();

      expect(techFormKey.currentState!.validate(), isTrue);
    });
  });

  group('Tab 6 (EindbeoordelingTab) mode deltas & safe stub', () {
    testWidgets('verbranding mode shows Staat van werking', (tester) async {
      late DraftVisit draft;
      await tester.runAsync(() async {
        draft = await DraftRepository().getOrCreateActiveDraft();
      });
      await pumpAndFlushDb(
        tester,
        MaterialApp(
          home: Scaffold(body: EindbeoordelingTab(visitId: draft.id)),
        ),
      );

      expect(find.text(EindbeoordelingDictionary.cardTitleConclusie),
          findsOneWidget);
      expect(find.text(EindbeoordelingDictionary.lblTeTreffenMaatregelen),
          findsNothing);
    });

    testWidgets(
        'reiniging mode omits Staat van werking, adds fields, stubs PDF/Finalize',
        (tester) async {
      late DraftVisit draft;
      await tester.runAsync(() async {
        draft = await DraftRepository()
            .getOrCreateActiveDraft(certificateType: 'reiniging');
      });
      await pumpAndFlushDb(
        tester,
        MaterialApp(
          home: Scaffold(
            body: EindbeoordelingTab(
              visitId: draft.id,
              certificateType: 'reiniging',
            ),
          ),
        ),
      );

      expect(find.text(EindbeoordelingDictionary.cardTitleConclusie),
          findsNothing);
      expect(
          find.text(
              EindbeoordelingDictionary.cardTitleVolgendeControleReiniging),
          findsOneWidget);
      expect(find.text(EindbeoordelingDictionary.lblNextReinigingStooktoestel),
          findsOneWidget);
      expect(find.text(EindbeoordelingDictionary.lblNextReinigingRookgas),
          findsOneWidget);
      expect(find.text(EindbeoordelingDictionary.lblTeTreffenMaatregelen),
          findsOneWidget);
      expect(find.text(EindbeoordelingDictionary.lblHandtekeningErkendOfVakman),
          findsOneWidget);
      expect(
          find.text(EindbeoordelingDictionary.lblHandtekeningKlantKennisname),
          findsOneWidget);

      await tester.ensureVisible(
        find.text(EindbeoordelingDictionary.btnTestPdf),
      );
      await tester.tap(find.text(EindbeoordelingDictionary.btnTestPdf));
      await tester.pump();
      expect(find.text(ReinigingDictionary.toastPdfNotYetAvailable),
          findsOneWidget);
    });
  });
}
