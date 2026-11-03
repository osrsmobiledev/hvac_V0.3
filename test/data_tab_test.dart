import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/features/certificate_draft/data/measurement_draft_repository.dart';
import 'package:hvac_app/features/certificate_draft/domain/flue_gas_field.dart';
import 'package:hvac_app/features/certificate_draft/domain/measurement_slot_draft.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/data/flue_gas_field_box.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/data_tab.dart';

class FakeMeasurementDraftRepository extends MeasurementDraftRepository {
  MeasurementSlotDraft? slot;

  @override
  Future<MeasurementSlotDraft?> loadTab1RawMeasurement(int visitId) async {
    return slot;
  }

  @override
  Future<void> saveMeasurementSlot(
    int visitId,
    MeasurementSlotDraft slotDraft,
  ) async {
    slot = slotDraft;
  }

  @override
  Future<void> clearMeasurementSlot(int visitId, String slotName) async {
    slot = null;
  }
}

void main() {
  late FakeMeasurementDraftRepository fakeRepo;

  setUp(() {
    fakeRepo = FakeMeasurementDraftRepository();
  });

  test(
      'FlueGasField.defaultFields follows official Flemish certificate sequence',
      () {
    final labels = FlueGasField.defaultFields.map((f) => f.label).toList();
    expect(FlueGasField.defaultFields.length, equals(19));
    expect(labels[0], equals(DataTabDictionary.lblBrandstof));
    expect(labels[1], equals(DataTabDictionary.lblBoilerTemp));
    expect(labels[2], equals(DataTabDictionary.lblO2));
    expect(labels[3], equals(DataTabDictionary.lblCo2));
    expect(labels[4], equals(DataTabDictionary.lblCoMgKwh));
    expect(labels[5], equals(DataTabDictionary.lblFlueTempTg));
    expect(labels[6], equals(DataTabDictionary.lblAirTempTa));
    expect(labels[7], equals(DataTabDictionary.lblNetTemp));
    expect(labels[8], equals(DataTabDictionary.lblEfficiencyHi));
    expect(labels[9], equals(DataTabDictionary.lblEfficiencyHs));
    expect(labels[10], equals(DataTabDictionary.lblFluePressurePa));
  });

  testWidgets(
      'DataTab renders Meetgegevens header, title Rookgassen, QR scanner button, and 19 fields',
      (tester) async {
    bool qrScanned = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: DataTab(
            visitId: 1,
            repository: fakeRepo,
            onScanQrPressed: () => qrScanned = true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify main Bento header 'Meetgegevens'
    expect(find.text(AppDictionary.headerMeetgegevens), findsOneWidget);

    // Verify direct title 'Rookgassen' is centered without sub-accordion
    final titleWidget =
        tester.widget<Text>(find.text(AppDictionary.headerRookgassen));
    expect(titleWidget.textAlign, TextAlign.center);

    // Verify QR scan button in the header row
    final qrBtn = find.byKey(const ValueKey('qr_scan_button'));
    expect(qrBtn, findsOneWidget);

    // Tap QR scan button and verify callback triggers
    await tester.tap(qrBtn);
    await tester.pumpAndSettle();
    expect(qrScanned, isTrue);

    // Verify flue gas parameter boxes are rendered (19 fields with official statutory names)
    expect(find.byType(FlueGasFieldBox), findsWidgets);
    expect(find.text(DataTabDictionary.lblBrandstof), findsOneWidget);
    expect(find.text(DataTabDictionary.lblDrukHpa), findsOneWidget);
    expect(find.text(DataTabDictionary.lblFlueTempTg), findsOneWidget);
    expect(find.text(DataTabDictionary.lblAirTempTa), findsOneWidget);
    expect(find.text(DataTabDictionary.lblCoMgKwh), findsOneWidget);
    expect(find.text(DataTabDictionary.lblFluePressurePa), findsOneWidget);

    // Without data, clear button should not be present
    expect(find.byKey(const ValueKey('data_tab_clear_button')), findsNothing);
  });

  testWidgets(
      'DataTab displays telemetry values and clears them with tactical confirmation dialog',
      (tester) async {
    // Seed fake tab1_raw measurement
    fakeRepo.slot = const MeasurementSlotDraft(
      slot: 'tab1_raw',
      o2Percent: 4.8,
      co2Percent: 9.1,
      coMgKwh: 35.0,
      flueTempTg: 58.2,
      ambientTempTa: 20.1,
      efficiencyHi: 98.4,
      fluePressurePa: -12.5,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: DataTab(
            visitId: 1,
            repository: fakeRepo,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify clear button is now visible
    final clearBtn = find.byKey(const ValueKey('data_tab_clear_button'));
    expect(clearBtn, findsOneWidget);

    // Verify parameter values are rendered
    expect(find.text('4.8'), findsOneWidget); // O2
    expect(find.text('9.1'), findsOneWidget); // CO2
    expect(find.text('58.2'), findsOneWidget); // Tg

    // Tap clear button to open tactical dialog
    await tester.tap(clearBtn);
    await tester.pumpAndSettle();

    // Dialog should show confirmation
    expect(find.text(MetingDictionary.dlgConfirmClearTitle), findsOneWidget);
    expect(find.text(MetingDictionary.dlgConfirmClearDataTab), findsOneWidget);

    // Confirm deletion via Wissen button
    final confirmBtn =
        find.widgetWithText(OutlinedButton, AppDictionary.btnDelete);
    expect(confirmBtn, findsOneWidget);
    await tester.tap(confirmBtn);
    await tester.pumpAndSettle();

    // After deletion, repository is cleared, clear button is gone and values return to placeholder
    expect(fakeRepo.slot, isNull);
    expect(find.byKey(const ValueKey('data_tab_clear_button')), findsNothing);
    expect(find.text('4.8'), findsNothing);
  });

  testWidgets(
      'Tapping QR button when data already exists shows overwrite confirmation',
      (tester) async {
    final fakeRepo = FakeMeasurementDraftRepository();
    fakeRepo.slot = MeasurementSlotDraft.empty('tab1_raw').copyWith(
      o2Percent: 5.0,
      co2Percent: 9.5,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: DataTab(
            visitId: 1,
            repository: fakeRepo,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap QR scanner button
    final qrBtn = find.widgetWithIcon(
      IconButton,
      Icons.qr_code_scanner_rounded,
    );
    expect(qrBtn, findsOneWidget);
    await tester.tap(qrBtn);
    await tester.pumpAndSettle();

    // Should show overwrite confirmation dialog
    expect(
      find.text(MetingDictionary.dlgConfirmOverwriteTitle),
      findsOneWidget,
    );
    expect(
      find.text(MetingDictionary.dlgConfirmOverwriteBodyDataTab),
      findsOneWidget,
    );
    expect(find.text(MetingDictionary.btnOverwrite), findsOneWidget);
  });
}
