import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/core/database/app_database.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/stooktoestel/brander_card.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/stooktoestel/integrated_burner_badge.dart';
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

  group('Slice 3.1 — Smart Brander (enkel CV) Tests', () {
    testWidgets(
        'BranderCard in integrated mode displays compliance badge and hides inputs',
        (tester) async {
      final brandCtrl = TextEditingController();
      final modelCtrl = TextEditingController();
      final yearCtrl = TextEditingController();
      final serialCtrl = TextEditingController();
      final flowCtrl = TextEditingController();
      String activeType = 'geintegreerd';

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return BranderCard(
                  burnerType: activeType,
                  onBurnerTypeChanged: (val) =>
                      setState(() => activeType = val),
                  brandController: brandCtrl,
                  modelController: modelCtrl,
                  yearController: yearCtrl,
                  serialController: serialCtrl,
                  flowRateController: flowCtrl,
                  yearUnknown: false,
                  serialUnknown: false,
                  onYearUnknownChanged: (_) {},
                  onSerialUnknownChanged: (_) {},
                  onScanBarcode: () {},
                  onChanged: () {},
                );
              },
            ),
          ),
        ),
      );

      // Verify TwoWaySlidingBar options
      expect(find.text(AppDictionary.optBurnerIntegrated), findsOneWidget);
      expect(find.text(AppDictionary.optBurnerSeparate), findsOneWidget);

      // Verify integrated badge is shown
      expect(find.byType(IntegratedBurnerBadge), findsOneWidget);
      expect(find.text(AppDictionary.lblBurnerIntegratedBadge), findsOneWidget);
      expect(find.text(AppDictionary.descBurnerIntegrated), findsOneWidget);

      // Separate inputs should not be present
      expect(find.text(AppDictionary.lblFlowRate), findsNothing);
      expect(find.text('Weishaupt'), findsNothing);

      // Switch to Afzonderlijke brander
      await tester.tap(find.text(AppDictionary.optBurnerSeparate));
      await tester.pumpAndSettle();

      // Integrated badge disappears, form and quick chips appear
      expect(find.byType(IntegratedBurnerBadge), findsNothing);
      expect(find.text(AppDictionary.lblFlowRate), findsOneWidget);
      expect(find.text('Weishaupt'), findsOneWidget);
      expect(find.text('Riello'), findsOneWidget);
      expect(find.text('Elco'), findsOneWidget);

      // Tap Weishaupt chip
      await tester.tap(find.text('Weishaupt'));
      await tester.pumpAndSettle();
      expect(brandCtrl.text, 'Weishaupt');
    });

    testWidgets(
        'StooktoestelTab auto-derives burner type based on fuel category',
        (tester) async {
      tester.view.physicalSize = const Size(412, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(body: StooktoestelTab()),
        ),
      );

      for (int i = 0; i < 20; i++) {
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 20));
        });
        await tester.pump();
        if (find.byType(CircularProgressIndicator).evaluate().isEmpty) break;
      }
      await tester.pumpAndSettle();

      // Default gas: burner is integrated
      expect(find.byType(IntegratedBurnerBadge), findsOneWidget);

      // Tap Vloeibare brandstof (Stookolie)
      await tester.tap(find.text(AppDictionary.fuelLiquidShort));
      await tester.pumpAndSettle();

      // Oil boiler auto-switches burner to Afzonderlijke brander
      expect(find.byType(IntegratedBurnerBadge), findsNothing);
      expect(
        find.descendant(
          of: find.byType(BranderCard),
          matching: find.text('Riello'),
        ),
        findsOneWidget,
      );

      // Tap Gasvormige brandstof (Gas)
      await tester.tap(find.text(AppDictionary.fuelGasShort));
      await tester.pumpAndSettle();

      // Switching back to gas auto-defaults back to integrated
      expect(find.byType(IntegratedBurnerBadge), findsOneWidget);
    });
  });
}
