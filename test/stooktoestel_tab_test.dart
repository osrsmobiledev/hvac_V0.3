import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/core/database/app_database.dart';
import 'package:hvac_app/features/certificate_draft/domain/boiler_draft.dart';
import 'package:hvac_app/features/certificate_draft/ui/boiler_draft_notifier.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/stooktoestel/brand_quick_picker.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/stooktoestel/unknown_badge.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/stooktoestel_tab.dart';
import 'package:hvac_app/features/reporting_delivery/ui/veka_attributes_section.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

part 'stooktoestel_tab_persistence_and_controls_cases.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;

  setUp(() async {
    db = await AppDatabase.instance.initDatabase(
      customPath: inMemoryDatabasePath,
    );
    AppDatabase.instance.setDatabaseForTesting(db);
  });

  tearDown(() async {
    await AppDatabase.instance.close();
  });

  group('Slice 3.1 — StooktoestelTab Widget Tests', () {
    Widget buildTestWidget() {
      return MaterialApp(
        theme: AppTheme.darkTheme,
        home: const Scaffold(
          body: StooktoestelTab(),
        ),
      );
    }

    Future<void> pumpTab(WidgetTester tester) async {
      tester.view.physicalSize = const Size(412, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestWidget());
      for (int i = 0; i < 20; i++) {
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 20));
        });
        await tester.pump();
        if (find.byType(CircularProgressIndicator).evaluate().isEmpty) {
          break;
        }
      }
      await tester.pumpAndSettle();
    }

    testWidgets('Renders all 3 Bento Cards with official headings',
        (tester) async {
      await pumpTab(tester);

      // Card 1: Kenmerken
      expect(find.text(AppDictionary.headerKenmerken), findsOneWidget);
      expect(find.text(AppDictionary.lblCentraal), findsOneWidget);

      // Card 2: Toestel
      expect(find.text(AppDictionary.headerAppliance), findsOneWidget);
      expect(find.text(AppDictionary.lblBrand), findsOneWidget);

      // Card 3: Brander
      expect(
        find.text('${AppDictionary.headerBurner} ${AppDictionary.subBurner}'),
        findsOneWidget,
      );
    });

    testWidgets(
        'Centraal Type B and C displays Tab Start style text buttons beside compact input boxes',
        (tester) async {
      await pumpTab(tester);

      // Buttons with 1-line text
      expect(find.textContaining(AppDictionary.lblConnected), findsNWidgets(2));
      expect(find.textContaining(AppDictionary.lblAsTypeB), findsOneWidget);
      expect(find.textContaining(AppDictionary.lblAsTypeC), findsOneWidget);

      // Compact input boxes beside the buttons
      expect(find.text(AppDictionary.hintSubtypeB), findsOneWidget);
      expect(find.text(AppDictionary.hintSubtypeC), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);

      // Tapping Type B directly selects it AND automatically turns Centraal switch ON
      await tester.tap(find.textContaining(AppDictionary.lblAsTypeB));
      await tester.pumpAndSettle();

      final centralSwitch = tester.widget<Switch>(find.byType(Switch).first);
      expect(centralSwitch.value, isTrue);

      // Tap Type B input to open tactical bottom sheet
      final typeBInput = find.byKey(const ValueKey('nbn_input_B'));
      await tester.tap(typeBInput);
      await tester.pumpAndSettle();

      // Select B23 from bottom sheet
      await tester
          .tap(find.text('Zonder trekonderbreker met ventilator (B23)'));
      await tester.pumpAndSettle();

      // Displays selected '23'
      expect(find.text('23'), findsOneWidget);
    });

    testWidgets('Tapping primary fuel buttons switches fuel category',
        (tester) async {
      await pumpTab(tester);

      // Initially fuel category starts unselected
      expect(find.text(AppDictionary.fuelGasShort), findsOneWidget);
      expect(find.text(AppDictionary.gasNatural), findsNothing);

      // Tap Gas: sub-options become visible
      await tester.tap(find.text(AppDictionary.fuelGasShort));
      await tester.pumpAndSettle();

      expect(find.text(AppDictionary.gasNatural), findsOneWidget);
      expect(find.text(AppDictionary.headerBurnerTech), findsOneWidget);
      expect(AppDictionary.headerBurnerTech, 'Brandertechnologie');

      // Tap Vloeibaar: bare-bones selector hides gas sub-options
      await tester.tap(find.text(AppDictionary.fuelLiquidShort));
      await tester.pumpAndSettle();

      expect(find.text(AppDictionary.gasNatural), findsNothing);

      // Tap Vast: renders solid subtypes
      await tester.tap(find.text(AppDictionary.fuelSolidShort));
      await tester.pumpAndSettle();

      expect(find.text(AppDictionary.solidPellets), findsOneWidget);
      expect(find.text(AppDictionary.solidLogs), findsOneWidget);
    });

    testWidgets('Tapping barcode scanner icon shows upcoming slice SnackBar',
        (tester) async {
      await pumpTab(tester);

      final scanButtons = find.byIcon(Icons.qr_code_scanner_rounded);
      expect(scanButtons, findsOneWidget);

      await tester.tap(scanButtons.first);
      await tester.pump();

      expect(
        find.text(AppDictionary.barcodeScannerPlaceholder),
        findsOneWidget,
      );
    });

    testWidgets(
        'Tapping Niet-condenserend selects boiler operation without wrapping',
        (tester) async {
      // Simulate Galaxy S23 narrow viewport (360x780 dp)
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      String heating = '';
      String operation = '';
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: StatefulBuilder(
        builder: (context, setState) => VekaAttributesSection(
          heatingType: heating,
          boilerOperation: operation,
          onHeatingTypeChanged: (value) => setState(() => heating = value),
          onBoilerOperationChanged: (value) =>
              setState(() => operation = value),
        ),
      ))));
      expect(find.text(AppDictionary.optCondensing), findsOneWidget);
      expect(find.text(AppDictionary.optNonCondensing), findsOneWidget);

      // Tap Niet-condenserend
      await tester.tap(find.text(AppDictionary.optNonCondensing));
      await tester.pumpAndSettle();
      expect(operation, 'niet_condenserend');
      await tester.tap(find.text(AppDictionary.optNonCondensing));
      await tester.tap(find.text(AppDictionary.optIndividual));
      expect(operation, isEmpty);
      expect(heating, 'individueel');
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppDictionary.optIndividual));
      expect(heating, isEmpty);

      // No overflow errors occurred during render or tap
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'Fuel selection toggles off and VEKA attributes are absent from Tab 5',
        (tester) async {
      await pumpTab(tester);

      expect(find.byType(VekaAttributesSection), findsNothing);
      await tester.tap(find.text(AppDictionary.fuelGasShort));
      await tester.pumpAndSettle();
      expect(find.text(AppDictionary.gasNatural), findsOneWidget);

      await tester.tap(find.text(AppDictionary.fuelGasShort));
      await tester.pumpAndSettle();
      expect(find.text(AppDictionary.gasNatural), findsNothing);
    });

    _persistenceAndControlsCases(pumpTab);
  });
}
