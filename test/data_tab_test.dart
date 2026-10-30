import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/features/certificate_draft/data/measurement_draft_repository.dart';
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

  testWidgets(
      'DataTab renders Meetgegevens header, title Rookgassen, QR scanner button, and 21 fields',
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

    // Verify flue gas parameter boxes are rendered (21 fields)
    expect(find.byType(FlueGasFieldBox), findsWidgets);
    expect(find.text('Brandstof'), findsOneWidget);
    expect(find.text('Druk [hPa]'), findsOneWidget);

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
}
