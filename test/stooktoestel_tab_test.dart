import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/core/database/app_database.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/stooktoestel/brand_quick_picker.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/stooktoestel/unknown_badge.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/stooktoestel_tab.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

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

      // Buttons with 2-line text
      expect(find.text(AppDictionary.lblConnected), findsNWidgets(2));
      expect(find.textContaining(AppDictionary.lblAsTypeB), findsOneWidget);
      expect(find.textContaining(AppDictionary.lblAsTypeC), findsOneWidget);

      // Compact input boxes beside the buttons
      expect(find.text(AppDictionary.hintSubtypeB), findsOneWidget);
      expect(find.text(AppDictionary.hintSubtypeC), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);

      // Tap Type B text button
      await tester.tap(find.textContaining(AppDictionary.lblAsTypeB));
      await tester.pumpAndSettle();

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

      // Initially gas is active
      expect(find.text(AppDictionary.fuelGasShort), findsOneWidget);
      expect(find.text(AppDictionary.gasNatural), findsOneWidget);
      expect(find.text(AppDictionary.techPremix), findsOneWidget);

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

      await pumpTab(tester);

      // Verify both condenserend and niet-condenserend are present
      expect(find.text(AppDictionary.optCondensing), findsOneWidget);
      expect(find.text(AppDictionary.optNonCondensing), findsOneWidget);

      // Tap Niet-condenserend
      await tester.tap(find.text(AppDictionary.optNonCondensing));
      await tester.pumpAndSettle();

      // No overflow errors occurred during render or tap
      expect(tester.takeException(), isNull);

      // Smart derivation: switching to niet-condenserend auto-selects niet-premix for gas
      expect(find.text(AppDictionary.techNonPremix), findsOneWidget);
    });

    testWidgets(
        'Toestel card renders full-width input boxes with Onbekend header chips and clean labels',
        (tester) async {
      await pumpTab(tester);

      // Verify clean labels without colons (Card 3 in default integrated mode hides separate burner inputs)
      expect(find.text('Merk'), findsOneWidget);
      expect(find.text('Type / Model'), findsOneWidget);
      expect(find.text('Bouwjaar'), findsOneWidget);
      expect(find.text('Fabricatienummer'), findsOneWidget);
      expect(find.text('Nominaal vermogen (kW)'), findsOneWidget);

      // Verify HeaderWithUnknownChip widgets for Bouwjaar and Fabricatienummer
      final unknownHeaderChips = find.byType(HeaderWithUnknownChip);
      expect(unknownHeaderChips, findsNWidgets(2));

      // Tap Onbekend for Bouwjaar
      final yearUnknownChip = find.descendant(
        of: unknownHeaderChips.at(0),
        matching: find.text(AppDictionary.optUnknown),
      );
      await tester.tap(yearUnknownChip);
      await tester.pumpAndSettle();

      // Tap Onbekend for Fabricatienummer
      final serialUnknownChip = find.descendant(
        of: unknownHeaderChips.at(1),
        matching: find.text(AppDictionary.optUnknown),
      );
      await tester.tap(serialUnknownChip);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'BrandQuickPicker renders distinct boiler brand chips and populates brand field on tap',
        (tester) async {
      await pumpTab(tester);

      // Verify popular brand chips exist as distinct entities (Bosch and Junkers are not merged)
      expect(find.text('Vaillant'), findsOneWidget);
      expect(find.text('Viessmann'), findsOneWidget);
      expect(find.text('Remeha'), findsOneWidget);
      expect(find.text('Bulex'), findsOneWidget);
      expect(find.text('Bosch'), findsOneWidget);
      expect(find.text('Junkers'), findsOneWidget);

      // Tap Vaillant chip
      await tester.tap(find.text('Vaillant'));
      await tester.pumpAndSettle();

      // Find the first TextFormField (Merk) and verify text
      expect(find.widgetWithText(TextFormField, 'Vaillant'), findsOneWidget);

      // Scroll and tap Bosch
      final brandScroll = find.descendant(
        of: find.byType(BrandQuickPicker),
        matching: find.byType(Scrollable),
      );
      await tester.scrollUntilVisible(find.text('Bosch'), 50.0,
          scrollable: brandScroll);
      await tester.tap(find.text('Bosch'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TextFormField, 'Bosch'), findsOneWidget);

      // Scroll and tap Junkers
      await tester.scrollUntilVisible(find.text('Junkers'), 50.0,
          scrollable: brandScroll);
      await tester.tap(find.text('Junkers'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TextFormField, 'Junkers'), findsOneWidget);
    });
  });
}
