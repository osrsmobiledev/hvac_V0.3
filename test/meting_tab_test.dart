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

part 'meting_tab_slot_cases.dart';
part 'meting_tab_layout_cases.dart';
part 'meting_tab_statutory_cases.dart';

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

    // Seed default boiler and visit 1
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
    await db.insert('maintenance_visits', {
      'id': 1,
      'boiler_id': 1,
      'is_draft': 1,
      'activity_type': 'onderhoud',
      'visit_date': '2026-10-27',
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
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 350));
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
        'Displays neutral placeholder in fuel banner when fuelCategory is empty',
        (tester) async {
      final notifier = BoilerDraftNotifier();
      await pumpTab(tester, notifier: notifier);

      expect(find.byType(MetingFuelBanner), findsOneWidget);
      expect(find.text(MetingDictionary.lblNoFuelSelected), findsOneWidget);
      expect(find.text(MetingDictionary.subNoFuelSelected), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(MetingFuelBanner),
          matching: find.textContaining('Gas'),
        ),
        findsNothing,
      );
    });

    _slotCases(pumpTab, settleDebounce, () => db);
    _layoutCases(pumpTab, settleDebounce);
    _statutoryCases(pumpTab, settleDebounce);
  });
}
