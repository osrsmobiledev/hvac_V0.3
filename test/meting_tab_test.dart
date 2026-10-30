import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/core/database/app_database.dart';
import 'package:hvac_app/features/certificate_draft/domain/boiler_draft.dart';
import 'package:hvac_app/features/certificate_draft/ui/boiler_draft_notifier.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/meting/measurement_slot_selector.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/meting/meting_fuel_banner.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/meting/proef2_modulation_badge.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/meting/statutory_combustion_field.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/meting/tactical_binary_check.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/meting_tab.dart';
import 'package:hvac_app/features/certificate_draft/ui/widgets/dark_text_field.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  messenger.setMockMethodCallHandler(
    const MethodChannel('dev.steenbakker.mobile_scanner/scanner/method'),
    (call) async {
      if (call.method == 'state') return 1;
      return null;
    },
  );
  messenger.setMockMethodCallHandler(
    const MethodChannel('dev.steenbakker.mobile_scanner/scanner/event'),
    (call) async => null,
  );
  messenger.setMockMethodCallHandler(
    const MethodChannel(
        'dev.steenbakker.mobile_scanner/scanner/deviceOrientation'),
    (call) async => null,
  );

  late Database db;

  setUp(() async {
    db = await AppDatabase.instance.initDatabase(
      customPath: inMemoryDatabasePath,
    );
    AppDatabase.instance.setDatabaseForTesting(db);

    // Seed visit 1 and default boiler
    await db.insert('maintenance_visits', {
      'id': 1,
      'activity_type': 'onderhoud',
      'visit_date': '2026-10-27',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
    await db.insert('boilers', {
      'id': 1,
      'fuel_type': 'gas',
      'fuel_subtype': 'aardgas',
      'centraal_type': 'C',
      'is_central': 1,
      'boiler_operation': 'condenserend',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });

    // Seed Tab 1 raw measurement buffer
    await db.insert('measurement_captures', {
      'visit_id': 1,
      'slot': 'tab1_raw',
      'o2_percent': 4.8,
      'co2_percent': 9.2,
      'co_mg_kwh': 24.5,
      'co_ok': 1,
      'flue_temp_celsius': 54.2,
      'ambient_temp_celsius': 19.8,
      'net_temp_celsius': 34.4,
      'combustion_efficiency_hi': 98.4,
      'combustion_efficiency_hi_ok': 1,
      'combustion_efficiency_hs': 88.6,
      'flue_pressure_pa': 12.0,
      'created_at': DateTime.now().toIso8601String(),
    });
  });

  tearDown(() async {
    await AppDatabase.instance.close();
  });

  group('Slice 3.2 — MetingTab Widget Tests', () {
    Widget buildTestWidget({BoilerDraftNotifier? notifier}) {
      return MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: MetingTab(visitId: 1, boilerNotifier: notifier),
        ),
      );
    }

    Future<void> pumpTab(WidgetTester tester,
        {BoilerDraftNotifier? notifier}) async {
      tester.view.physicalSize = const Size(412, 2200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestWidget(notifier: notifier));
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

    Future<void> settleDebounce(WidgetTester tester) async {
      await tester.pump(const Duration(milliseconds: 350));
      for (int i = 0; i < 5; i++) {
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 100));
        });
        await tester.pump();
      }
      await tester.pumpAndSettle();
    }

    testWidgets('Renders all 3 Bento Cards and tactical fuel banner',
        (tester) async {
      await pumpTab(tester);

      // 1. Tactical Fuel Banner
      expect(find.byType(MetingFuelBanner), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(MetingFuelBanner),
          matching: find.textContaining('Gas'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(MetingFuelBanner),
          matching: find.textContaining('Type C'),
        ),
        findsOneWidget,
      );

      // 2. Card 1: Goede staat van werking
      expect(find.text(MetingDictionary.headerOperatingConditions),
          findsOneWidget);
      expect(find.text(MetingDictionary.lblBoilerTemp), findsOneWidget);
      expect(find.text(MetingDictionary.lblGasPressureMeter), findsOneWidget);

      // Gas boiler hides oil nozzle fields
      expect(find.text(MetingDictionary.lblNozzleBrandType), findsNothing);

      // 3. Card 2: Rookgasmetingen
      expect(find.text(MetingDictionary.headerCombustionMeasurements),
          findsOneWidget);
      expect(find.byType(MeasurementSlotSelector), findsOneWidget);
      expect(find.text(MetingDictionary.btnCopyFromDataTab), findsOneWidget);

      // 4. Card 3: Veilige staat van werking
      expect(find.text(MetingDictionary.headerSafetyChecks), findsOneWidget);
      expect(find.text(MetingDictionary.lblCheckFluePressure), findsOneWidget);
      expect(find.text(MetingDictionary.lblCheckVentilation), findsOneWidget);
      expect(find.text(MetingDictionary.lblCheckFuelSupplyTightness),
          findsOneWidget);
      expect(find.text(MetingDictionary.lblCheckFlueTightness), findsOneWidget);
    });

    testWidgets(
        'Tapping Neem over van Tab 1 populates slot and calculates net temp',
        (tester) async {
      await pumpTab(tester);

      // Tap import button
      await tester.tap(find.text(MetingDictionary.btnCopyFromDataTab));
      await settleDebounce(tester);

      // Net temp: 54.2 - 19.8 = 34.4 °C
      expect(find.text('34.4 °C'), findsOneWidget);

      // CO (24.5) and Hi (98.4) display populated numbers
      expect(find.text('24.5'), findsOneWidget);
      expect(find.text('98.4'), findsOneWidget);

      // Statutory combustion fields are present with smart norms inside the input box
      expect(find.byType(StatutoryCombustionField), findsNWidgets(2));
      expect(
        find.text(MetingDictionary.getCoNormText(fuelCategory: 'gas')),
        findsOneWidget,
      );
      expect(
        find.text(MetingDictionary.getHiNormText(
          fuelCategory: 'gas',
          centraalType: 'C',
        )),
        findsOneWidget,
      );
    });

    testWidgets('Tapping Wissen clears the active slot after confirmation',
        (tester) async {
      await pumpTab(tester);

      // Initially empty: delete button is disabled
      final clearButton = find.byTooltip(MetingDictionary.btnClearSlot);
      expect(clearButton, findsOneWidget);

      // Populate via Tab 1 import
      await tester.tap(find.text(MetingDictionary.btnCopyFromDataTab));
      await settleDebounce(tester);
      expect(find.text('34.4 °C'), findsOneWidget);

      // Now tap delete icon button
      await tester.tap(clearButton);
      await tester.pumpAndSettle();

      // Confirmation dialog appears
      expect(find.text(MetingDictionary.dlgConfirmClearTitle), findsOneWidget);
      await tester.tap(find.text('Wissen'));
      await settleDebounce(tester);

      // Net temp cleared
      expect(find.text('—'), findsOneWidget);
    });

    testWidgets(
        'Tapping QR icon opens EurolyzerScannerModal and simulates scan',
        (tester) async {
      await pumpTab(tester);

      final qrButton = find.byTooltip(MetingDictionary.btnScanEurolyzer);
      expect(qrButton, findsOneWidget);
      await tester.tap(qrButton);
      await tester.pumpAndSettle();

      // Scanner modal opens with simulate button
      final simulateBtn =
          find.byKey(const ValueKey('simulate_eurolyzer_qr_button'));
      expect(simulateBtn, findsOneWidget);

      await tester.tap(simulateBtn);
      await settleDebounce(tester);

      // Values populated from simulation!
      expect(find.text('34.4 °C'), findsOneWidget);
    });

    testWidgets(
        'Neem over van Tab 1 shows warning dialog when Tab 1 has no data',
        (tester) async {
      await tester.runAsync(() async {
        await db.delete('measurement_captures', where: "slot = 'tab1_raw'");
      });

      await pumpTab(tester);

      await tester.tap(find.text(MetingDictionary.btnCopyFromDataTab));
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pumpAndSettle();

      expect(find.text(MetingDictionary.dlgNoTab1DataTitle), findsOneWidget);
      expect(find.text(MetingDictionary.btnScanDirect), findsOneWidget);

      // Dismiss dialog so async action completes cleanly
      await tester.tap(find.text(AppDictionary.btnCancel));
      await tester.pumpAndSettle();
    });

    testWidgets('Tapping TacticalBinaryCheck toggles OK and Niet OK states',
        (tester) async {
      await pumpTab(tester);

      // Find first TacticalBinaryCheck in Card 3
      final firstCheck = find.descendant(
        of: find.ancestor(
          of: find.text(MetingDictionary.lblCheckFluePressure),
          matching: find.byType(Column),
        ),
        matching: find.byType(TacticalBinaryCheck),
      );
      expect(firstCheck, findsWidgets);

      // Tap OK
      final okButton = find.descendant(
        of: firstCheck.first,
        matching: find.text(MetingDictionary.lblOk),
      );
      await tester.tap(okButton);
      await settleDebounce(tester);

      // Tap Niet OK
      final notOkButton = find.descendant(
        of: firstCheck.first,
        matching: find.text(MetingDictionary.lblNotOk),
      );
      await tester.tap(notOkButton);
      await settleDebounce(tester);

      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'Instant reactive fuel switch from Gas to Stookolie via Notifier',
        (tester) async {
      final notifier = BoilerDraftNotifier();
      await tester.runAsync(() async => notifier.loadInitial());
      await pumpTab(tester, notifier: notifier);

      // Initially gas
      expect(find.textContaining('Gas'), findsWidgets);

      // Switch to Stookolie (vloeibaar)
      notifier.updateDraft(notifier.draft.copyWith(
        fuelCategory: 'vloeibaar',
        fuelSubtype: 'stookolie',
      ));
      await tester.pump();

      // Top banner immediately updates
      expect(find.text('Stookolie (Mazout)'), findsOneWidget);
      // Card 1 immediately switches to nozzle brand
      expect(find.text(MetingDictionary.lblNozzleBrandType), findsOneWidget);

      await settleDebounce(tester);
      notifier.dispose();
    });

    testWidgets(
        '2-Tier Collapsible MeasurementSlotSelector switches between Proef I and Proef II and expands modulation on demand',
        (tester) async {
      await pumpTab(tester);

      // 1. Initially on Proef I
      expect(find.text(MetingDictionary.slotProef1), findsOneWidget);
      expect(find.text(MetingDictionary.slotProef1Sub), findsOneWidget);
      expect(find.text(MetingDictionary.slotProef2), findsOneWidget);
      expect(find.text(MetingDictionary.slotProef2Sub), findsOneWidget);

      // Modulation sub-toggle is hidden on Proef I
      expect(find.text(MetingDictionary.subSlotLaaglast), findsNothing);
      expect(find.text(MetingDictionary.subSlotHooglast), findsNothing);

      // 2. Tap Proef II: activates Proef II displaying [ L / H ▾ ] badge next to Proef II
      await tester.tap(find.text(MetingDictionary.slotProef2));
      await tester.pumpAndSettle();

      // Proef II displays compact Proef2ModulationBadge on top line and "Eindmeting" on bottom line
      expect(find.text(MetingDictionary.slotProef2Sub), findsOneWidget);
      expect(find.byType(Proef2ModulationBadge), findsOneWidget);
      expect(find.text('L'), findsOneWidget);
      expect(find.text('H'), findsOneWidget);
      expect(find.byIcon(Icons.expand_more_rounded), findsOneWidget);

      // 3. Tap Proef II while active to expand modulation dropdown
      await tester.tap(find.text(MetingDictionary.slotProef2));
      await tester.pumpAndSettle();

      // Modulation sub-toggle is now smoothly revealed with full Dutch names
      expect(find.text(MetingDictionary.subSlotLaaglast), findsOneWidget);
      expect(find.text(MetingDictionary.subSlotHooglast), findsOneWidget);
      expect(find.byIcon(Icons.expand_less_rounded), findsOneWidget);

      // 4. Tap Hooglast: switches active mode to Hooglast and closes dropdown
      await tester.tap(find.text(MetingDictionary.subSlotHooglast));
      await tester.pumpAndSettle();

      // Dropdown closes, top badge remains showing L / H
      expect(find.text(MetingDictionary.subSlotHooglast), findsNothing);
      expect(find.byIcon(Icons.expand_more_rounded), findsOneWidget);

      // 5. Tap Proef I -> switches back cleanly
      await tester.tap(find.text(MetingDictionary.slotProef1));
      await tester.pumpAndSettle();
      expect(find.text(MetingDictionary.slotProef2Sub), findsOneWidget);
    });

    testWidgets(
        'Statutory combustion fields adapt norm labels smartly to fuel and boiler type',
        (tester) async {
      final notifier = BoilerDraftNotifier();
      await pumpTab(tester, notifier: notifier);

      // Default: Gas Type C Condenserend
      expect(find.byType(StatutoryCombustionField), findsNWidgets(2));
      expect(
        find.text(MetingDictionary.getCoNormText(fuelCategory: 'gas')),
        findsOneWidget,
      );
      expect(
        find.text(MetingDictionary.getHiNormText(
          fuelCategory: 'gas',
          centraalType: 'C',
        )),
        findsOneWidget,
      );

      // Update to Gas Type B1 -> Hi norm changes to >= 88%
      notifier.updateDraft(const BoilerDraft(
        fuelCategory: 'gas',
        centraalType: 'B',
        typeBText: 'B11',
      ));
      await settleDebounce(tester);

      expect(
        find.text(MetingDictionary.getHiNormText(
          fuelCategory: 'gas',
          centraalType: 'B',
          typeBText: 'B11',
        )),
        findsOneWidget,
      );

      // Update to Gas Type B23P -> Hi norm changes to >= 90%
      notifier.updateDraft(const BoilerDraft(
        fuelCategory: 'gas',
        centraalType: 'B',
        typeBText: 'B23P',
      ));
      await settleDebounce(tester);

      expect(
        find.text(MetingDictionary.getHiNormText(
          fuelCategory: 'gas',
          centraalType: 'B',
          typeBText: 'B23P',
        )),
        findsOneWidget,
      );

      // Update to Vloeibaar (Stookolie) -> Hi norm changes to >= 90% Stookolie
      notifier.updateDraft(const BoilerDraft(
        fuelCategory: 'vloeibaar',
        fuelSubtype: 'stookolie',
      ));
      await settleDebounce(tester);

      expect(
        find.text(MetingDictionary.getHiNormText(
          fuelCategory: 'vloeibaar',
          centraalType: 'C',
        )),
        findsOneWidget,
      );

      // Switch to Proef II: Fields remain present
      await tester.tap(find.text(MetingDictionary.slotProef2));
      await tester.pumpAndSettle();

      expect(find.byType(StatutoryCombustionField), findsNWidgets(2));
    });

    testWidgets(
        'CombustionFieldsLayout adapts on narrow Galaxy S23 (<380px) and wide screens',
        (tester) async {
      // 1. Narrow Galaxy S23 (360px viewport width)
      tester.view.physicalSize = const Size(360, 2200);
      tester.view.devicePixelRatio = 1.0;
      await pumpTab(tester);

      // All 8 labels with bracketed units are rendered without clipping
      expect(find.text(MetingDictionary.lblO2), findsOneWidget);
      expect(find.text(MetingDictionary.lblCO2), findsOneWidget);
      expect(find.text(MetingDictionary.lblCO), findsOneWidget);
      expect(find.text(MetingDictionary.lblFlueTempTg), findsOneWidget);
      expect(find.text(MetingDictionary.lblAirTempTa), findsOneWidget);
      expect(find.text(MetingDictionary.lblNetTemp), findsOneWidget);
      expect(find.text(MetingDictionary.lblEfficiencyHi), findsOneWidget);
      expect(find.text(MetingDictionary.lblEfficiencyHs), findsOneWidget);
    });

    testWidgets(
        'StatutoryCombustionField shows warning triangle (!) next to number when non-compliant or NOK',
        (tester) async {
      await pumpTab(tester);

      // Initially compliant or empty: no warning triangle
      expect(find.byIcon(Icons.warning_rounded), findsNothing);

      // Enter failing CO value (250 mg/kWh > 150)
      final coField = find.descendant(
        of: find.byType(StatutoryCombustionField).first,
        matching: find.byType(TextFormField),
      );
      await tester.enterText(coField, '250.0');
      await tester.pump();

      // Warning triangle (!) appears next to the number
      expect(find.byIcon(Icons.warning_rounded), findsOneWidget);
    });

    testWidgets(
        'Combustion measurements support Proef I and Proef II values independently',
        (tester) async {
      await pumpTab(tester);

      // 1. Proef I: enter failing CO (250 mg/kWh) and compliant Hi (95%)
      final coField = find.descendant(
        of: find.byType(StatutoryCombustionField).first,
        matching: find.byType(TextFormField),
      );
      await tester.enterText(coField, '250.0');

      final hiField = find.descendant(
        of: find.byType(StatutoryCombustionField).last,
        matching: find.byType(TextFormField),
      );
      await tester.enterText(hiField, '95.0');
      await settleDebounce(tester);

      // Warning triangle (!) appears for failing CO in Proef I
      expect(find.byIcon(Icons.warning_rounded), findsOneWidget);

      // 2. Switch to Proef II (Eindmeting after cleaning)
      await tester.tap(find.text(MetingDictionary.slotProef2));
      await tester.pumpAndSettle();

      // Enter compliant readings in Proef II (CO 25, Hi 98)
      final p2CoField = find.descendant(
        of: find.byType(StatutoryCombustionField).first,
        matching: find.byType(TextFormField),
      );
      await tester.enterText(p2CoField, '25.0');
      final p2HiField = find.descendant(
        of: find.byType(StatutoryCombustionField).last,
        matching: find.byType(TextFormField),
      );
      await tester.enterText(p2HiField, '98.0');
      await settleDebounce(tester);

      // Proef II is compliant: no warning triangle
      expect(find.byIcon(Icons.warning_rounded), findsNothing);

      // 3. Switch back to Proef I: failing state remains isolated in Proef I
      await tester.tap(find.text(MetingDictionary.slotProef1));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.warning_rounded), findsOneWidget);
    });

    testWidgets(
        'Technician has full manual authority: tapping OK on failing CO (250 mg/kWh) retains OK',
        (tester) async {
      await pumpTab(tester);

      final coFieldWidget = find.byType(StatutoryCombustionField).first;
      final coInput = find.descendant(
        of: coFieldWidget,
        matching: find.byType(TextFormField),
      );
      await tester.enterText(coInput, '250.0');
      await settleDebounce(tester);

      // Automatically assessed as NOK
      final binaryCheckBefore = tester.widget<TacticalBinaryCheck>(
        find.descendant(
          of: coFieldWidget,
          matching: find.byType(TacticalBinaryCheck),
        ),
      );
      expect(binaryCheckBefore.value, isFalse);

      // Tap OK button inside CO field
      final coOkBtn = find.descendant(
        of: coFieldWidget,
        matching: find.text(MetingDictionary.lblOk),
      );
      await tester.tap(coOkBtn);
      await settleDebounce(tester);

      // Verify technician choice is preserved and not clobbered
      final binaryCheckAfter = tester.widget<TacticalBinaryCheck>(
        find.descendant(
          of: coFieldWidget,
          matching: find.byType(TacticalBinaryCheck),
        ),
      );
      expect(binaryCheckAfter.value, isTrue);
    });

    testWidgets(
        'Numeric combustion fields display right-side unit when value is entered',
        (tester) async {
      await pumpTab(tester);

      // Initially no % unit is visible for O2
      expect(
        find.descendant(
          of: find.byType(DarkTextField).first,
          matching: find.textContaining('%'),
        ),
        findsNothing,
      );

      // Enter value in O2 field
      final o2Field = find.descendant(
        of: find.byType(DarkTextField).first,
        matching: find.byType(TextFormField),
      );
      await tester.enterText(o2Field, '4.8');
      await tester.pump();

      // % unit now appears attached to the number!
      expect(
        find.descendant(
          of: find.byType(DarkTextField).first,
          matching: find.text('4.8 %'),
        ),
        findsOneWidget,
      );

      // Enter value in flue temp (tg) field (4th DarkTextField)
      final tgField = find.descendant(
        of: find.byType(DarkTextField).at(3),
        matching: find.byType(TextFormField),
      );
      await tester.enterText(tgField, '54.2');
      await tester.pump();

      // °C unit appears attached to tg field!
      expect(
        find.descendant(
          of: find.byType(DarkTextField).at(3),
          matching: find.text('54.2 °C'),
        ),
        findsOneWidget,
      );
    });
  });
}
