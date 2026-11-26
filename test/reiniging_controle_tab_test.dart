import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/localization/reiniging_dictionary.dart';
import 'package:hvac_app/core/database/database_schema.dart';
import 'package:hvac_app/core/utils/debouncer.dart';
import 'package:hvac_app/core/utils/form_scroll_helper.dart';
import 'package:hvac_app/features/certificate_draft/data/boiler_draft_repository.dart';
import 'package:hvac_app/features/certificate_draft/data/reiniging_repository.dart';
import 'package:hvac_app/features/certificate_draft/domain/boiler_draft.dart';
import 'package:hvac_app/features/certificate_draft/domain/reiniging_controls_draft.dart';
import 'package:hvac_app/features/certificate_draft/ui/boiler_draft_notifier.dart';
import 'package:hvac_app/features/certificate_draft/ui/draft_save_scope.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/reiniging_controle_tab.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class _TestReinigingRepository extends ReinigingRepository {
  _TestReinigingRepository(this.db);
  final Database db;

  @override
  Future<ReinigingControlsDraft> loadControls(int visitId,
          {Database? dbOverride}) =>
      super.loadControls(visitId, dbOverride: db);

  @override
  Future<void> saveControls({
    required int visitId,
    required ReinigingControlsDraft draft,
    Database? dbOverride,
  }) =>
      super.saveControls(visitId: visitId, draft: draft, dbOverride: db);
}

class _FakeBoilerRepository extends BoilerDraftRepository {
  @override
  Future<BoilerDraft> saveBoilerDraft(BoilerDraft draft,
          {Database? dbOverride}) async =>
      draft;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late _TestReinigingRepository repo;
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
    repo = _TestReinigingRepository(db);
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

  Widget buildHarness({
    required int id,
    BoilerDraftNotifier? boilerNotifier,
    ValueChanged<GlobalKey<FormState>>? onFormKeyReady,
    Set<Debouncer>? saves,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: DraftSaveScope(
          saves: saves ?? <Debouncer>{},
          child: ReinigingControleTab(
            visitId: id,
            repository: repo,
            boilerNotifier: boilerNotifier,
            onFormKeyReady: onFormKeyReady,
          ),
        ),
      ),
    );
  }

  Future<ReinigingControlsDraft> settleAndLoad(
    WidgetTester tester,
    Set<Debouncer> saves,
  ) async {
    late ReinigingControlsDraft loaded;
    await tester.runAsync(() async {
      for (final s in saves.toList()) {
        await s.settle();
      }
      loaded = await repo.loadControls(visitId);
    });
    return loaded;
  }

  testWidgets('1. Renders all 14 Dutch labels and hides andere field initially',
      (tester) async {
    await tester.pumpWidget(buildHarness(id: visitId));
    await tester.pumpAndSettle();

    expect(find.text(ReinigingDictionary.headerFlue), findsOneWidget);
    expect(find.text(ReinigingDictionary.headerBoiler), findsOneWidget);
    for (final label in [
      ReinigingDictionary.itemFlueSweeping,
      ReinigingDictionary.itemFlueGoodOperation,
      ReinigingDictionary.itemFlueBackdraft,
      ReinigingDictionary.itemAllOther,
      ReinigingDictionary.itemAllVentilation,
      ReinigingDictionary.itemAllFlueTightness,
      ReinigingDictionary.itemGasDustRemoval,
      ReinigingDictionary.itemGasBurnerBedExchanger,
      ReinigingDictionary.itemGasFanBurner,
      ReinigingDictionary.itemLiquidFilters,
      ReinigingDictionary.itemLiquidBoiler,
      ReinigingDictionary.itemLiquidBurner,
      ReinigingDictionary.itemSolidGeneralCondition,
      ReinigingDictionary.itemSolidInternalCleaning,
    ]) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.text(ReinigingDictionary.lblOtherText), findsNothing);
  });

  testWidgets('2. Toggling persists to SQLite and restores on remount',
      (tester) async {
    final saves = <Debouncer>{};
    await tester.pumpWidget(buildHarness(id: visitId, saves: saves));
    await tester.pumpAndSettle();

    await tester.tap(find.text(ReinigingDictionary.itemFlueSweeping));
    await tester.pump();
    await tester.ensureVisible(find.text(ReinigingDictionary.itemLiquidBoiler));
    await tester.tap(find.text(ReinigingDictionary.itemLiquidBoiler));
    await tester.pump();

    final saved = await settleAndLoad(tester, saves);
    expect(saved.flueSweeping, isTrue);
    expect(saved.liquidBoiler, isTrue);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(buildHarness(id: visitId));
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pumpAndSettle();

    final restored = await settleAndLoad(tester, saves);
    expect(restored.flueSweeping, isTrue);
    expect(restored.liquidBoiler, isTrue);
  });

  testWidgets('3. Conditional andere field validates, clears, and prunes DB',
      (tester) async {
    GlobalKey<FormState>? formKey;
    final saves = <Debouncer>{};
    await tester.pumpWidget(buildHarness(
      id: visitId,
      saves: saves,
      onFormKeyReady: (k) => formKey = k,
    ));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text(ReinigingDictionary.itemAllOther));
    await tester.tap(find.text(ReinigingDictionary.itemAllOther));
    await tester.pumpAndSettle();

    expect(find.text(ReinigingDictionary.lblOtherText), findsOneWidget);
    expect(formKey!.currentState!.validate(), isFalse);
    await tester.pump();

    await tester.ensureVisible(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'Sifon gereinigd');
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 500));
    final savedWithText = await settleAndLoad(tester, saves);
    expect(formKey!.currentState!.validate(), isTrue);
    expect(savedWithText.allOtherText, 'Sifon gereinigd');

    // Unchecking clears controller, hides field, and prunes SQLite to null.
    await tester.ensureVisible(find.text(ReinigingDictionary.itemAllOther));
    await tester.tap(find.text(ReinigingDictionary.itemAllOther));
    await tester.pumpAndSettle();
    final savedAfterUncheck = await settleAndLoad(tester, saves);
    expect(find.text(ReinigingDictionary.lblOtherText), findsNothing);
    expect(savedAfterUncheck.allOtherText, isNull);

    // Re-checking starts clean with empty field.
    await tester.ensureVisible(find.text(ReinigingDictionary.itemAllOther));
    await tester.tap(find.text(ReinigingDictionary.itemAllOther));
    await tester.pumpAndSettle();
    await settleAndLoad(tester, saves);
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller!.text, isEmpty);
  });

  testWidgets('4. Fuel subgroup highlights active fuel without losing checks',
      (tester) async {
    final notifier = BoilerDraftNotifier(repository: _FakeBoilerRepository())
      ..useSavedCopy(BoilerDraft.initial().copyWith(fuelCategory: 'vloeibaar'));
    addTearDown(notifier.dispose);
    final saves = <Debouncer>{};

    await tester.pumpWidget(
      buildHarness(id: visitId, boilerNotifier: notifier, saves: saves),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text(ReinigingDictionary.itemLiquidBoiler));
    await tester.tap(find.text(ReinigingDictionary.itemLiquidBoiler));
    await tester.pump();

    expect(find.text(ReinigingDictionary.badgeActiveFuel), findsOneWidget);
    final liquidY =
        tester.getTopLeft(find.text(ReinigingDictionary.subLiquid)).dy;
    final gasY = tester.getTopLeft(find.text(ReinigingDictionary.subGas)).dy;
    expect(liquidY, lessThan(gasY));

    // Switch fuel to gas: Gas moves above Liquid, liquid item stays checked.
    notifier.useSavedCopy(notifier.draft.copyWith(fuelCategory: 'gas'));
    await tester.pumpAndSettle();

    final newGasY = tester.getTopLeft(find.text(ReinigingDictionary.subGas)).dy;
    final newLiquidY =
        tester.getTopLeft(find.text(ReinigingDictionary.subLiquid)).dy;
    expect(newGasY, lessThan(newLiquidY));
    final saved = await settleAndLoad(tester, saves);
    expect(saved.liquidBoiler, isTrue);
  });

  testWidgets('5. Empty selection fails validation and clears on first tap',
      (tester) async {
    GlobalKey<FormState>? formKey;
    final saves = <Debouncer>{};
    await tester.pumpWidget(
      buildHarness(
        id: visitId,
        saves: saves,
        onFormKeyReady: (k) => formKey = k,
      ),
    );
    await tester.pumpAndSettle();

    expect(formKey!.currentState!.validate(), isFalse);
    await tester.pump();
    expect(
      FormScrollHelper.findFirstError(formKey!.currentContext),
      ReinigingDictionary.errSelectAtLeastOne,
    );

    await tester.tap(find.text(ReinigingDictionary.itemFlueSweeping));
    await tester.pump();
    expect(FormScrollHelper.findFirstError(formKey!.currentContext), isNull);
    expect(formKey!.currentState!.validate(), isTrue);
    await settleAndLoad(tester, saves);
  });
}
