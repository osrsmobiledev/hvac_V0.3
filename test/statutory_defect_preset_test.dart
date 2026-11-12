// File: test/statutory_defect_preset_test.dart
// Responsibility: Unit and widget tests for Flemish statutory defect presets and smart modal selector.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/localization/eindbeoordeling_dictionary.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/features/certificate_draft/domain/statutory_defect_preset.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/eindbeoordeling/gebreken_opmerkingen_card.dart';

void main() {
  group('StatutoryDefectPreset Domain Logic Tests', () {
    test(
        'Gas + Type C returns concentric flue and gas presets, excludes oil & Type B',
        () {
      final presets =
          StatutoryDefectPreset.filter(fuel: 'gas', boilerType: 'C');
      final ids = presets.map((p) => p.id).toSet();

      // Must include Type C & Gas & Hydraulic
      expect(ids.contains('concentric_recirculation_c'), isTrue);
      expect(ids.contains('gas_exchanger_fouled'), isTrue);
      expect(ids.contains('gas_co_exceeded'), isTrue);
      expect(ids.contains('safety_valve_leaking'), isTrue);
      expect(ids.contains('diverter_valve_defect'), isTrue);
      expect(ids.contains('circulator_pump_defect'), isTrue);
      expect(ids.contains('flue_fan_defect'), isTrue);
      expect(ids.contains('plate_exchanger_clogged'), isTrue);
      expect(ids.contains('condensate_siphon_blocked'), isTrue);
      expect(ids.contains('pcb_control_defect'), isTrue);
      expect(ids.contains('gas_shutoff_valve_defect'), isTrue);
      expect(ids.contains('copper_pipes_corroded'), isTrue);

      // Must exclude Type B & Oil & Solid
      expect(ids.contains('ventilation_type_b'), isFalse);
      expect(ids.contains('ttb_safety_defect'), isFalse);
      expect(ids.contains('oil_leak_trace'), isFalse);
      expect(ids.contains('solid_creosote_flue'), isFalse);
    });

    test(
        'Stookolie + Type B returns ventilation & oil presets, excludes Type C & gas',
        () {
      final presets =
          StatutoryDefectPreset.filter(fuel: 'vloeibaar', boilerType: 'B');
      final ids = presets.map((p) => p.id).toSet();

      // Must include Type B & Oil
      expect(ids.contains('ventilation_type_b'), isTrue);
      expect(ids.contains('ttb_safety_defect'), isTrue);
      expect(ids.contains('oil_leak_trace'), isTrue);
      expect(ids.contains('oil_supply_twopipe'), isTrue);
      expect(ids.contains('oil_smoke_number_high'), isTrue);

      // Must exclude Type C & Gas
      expect(ids.contains('concentric_recirculation_c'), isFalse);
      expect(ids.contains('flue_fan_defect'), isFalse);
      expect(ids.contains('gas_exchanger_fouled'), isFalse);
    });

    test('Category filtering isolates flue, fuel, and hydraulic presets', () {
      final fluePresets = StatutoryDefectPreset.filter(
        fuel: 'gas',
        boilerType: 'B',
        categoryFilter: 'flue_vent',
      );
      expect(fluePresets.every((p) => p.category == 'flue_vent'), isTrue);

      final hydraulicPresets = StatutoryDefectPreset.filter(
        fuel: 'gas',
        boilerType: 'B',
        categoryFilter: 'hydraulic',
      );
      expect(hydraulicPresets.every((p) => p.category == 'hydraulic'), isTrue);
    });

    test('Presets are ordered strictly from most common to rare', () {
      final gasPresets =
          StatutoryDefectPreset.filter(fuel: 'gas', boilerType: 'C');
      final ids = gasPresets.map((p) => p.id).toList();

      final idxExpVessel = ids.indexOf('expansion_vessel_depleted');
      final idxBurnerGasket = ids.indexOf('burner_gasket_worn');
      final idxSafetyValve = ids.indexOf('safety_valve_leaking');
      final idxConcentric = ids.indexOf('concentric_recirculation_c');
      final idxElectrodes = ids.indexOf('gas_electrodes_worn');
      final idxPcb = ids.indexOf('pcb_control_defect');
      final idxPorts = ids.indexOf('missing_test_ports');

      // Top common failures must appear near the top
      expect(idxExpVessel, lessThan(idxPcb));
      expect(idxBurnerGasket, lessThan(idxPcb));
      expect(idxSafetyValve, lessThan(idxPcb));
      expect(idxConcentric, lessThan(idxPorts));
      expect(idxElectrodes, lessThan(idxPorts));
    });
  });

  group('GebrekenOpmerkingenCard & StatutoryDefectsModal Widget Tests', () {
    testWidgets(
        'Tapping Snelselectie opens modal, multi-selects and applies defect & remedy',
        (tester) async {
      final defectsCtrl = TextEditingController(text: 'Bestaande opmerking');
      final remarksCtrl = TextEditingController();
      bool changed = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: SingleChildScrollView(
              child: GebrekenOpmerkingenCard(
                defectsController: defectsCtrl,
                remarksController: remarksCtrl,
                hasNegativeAssessment: false,
                fuelType: 'gas',
                boilerType: 'C',
                onChanged: () => changed = true,
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.lightbulb_outline_rounded), findsOneWidget);

      // Tap hint icon button to open modal
      await tester.tap(find.byIcon(Icons.lightbulb_outline_rounded));
      await tester.pumpAndSettle();

      // Verify modal is open with subtitle badge
      expect(find.text(EindbeoordelingDictionary.modalTitleSnelselectie),
          findsOneWidget);
      expect(find.textContaining('Aardgas • Type C (Gesloten)'), findsOneWidget);

      // Tap the top preset (Expansievat defect)
      final presetTitleFinder = find.text('Expansievat defect');
      expect(presetTitleFinder, findsOneWidget);
      await tester.tap(presetTitleFinder);
      await tester.pumpAndSettle();

      // Apply button now shows 1 selected
      final applyButton =
          find.text('${EindbeoordelingDictionary.btnToepassen} (1)');
      expect(applyButton, findsOneWidget);
      await tester.tap(applyButton);
      await tester.pumpAndSettle();

      // Modal closed, text formatted cleanly with bullets
      expect(changed, isTrue);
      expect(defectsCtrl.text, contains('Bestaande opmerking'));
      expect(defectsCtrl.text, contains('• Expansievat membraan gescheurd'));
      expect(remarksCtrl.text, contains('• Expansievat vervangen'));
    });

    testWidgets('Tapping Wis button opens confirm dialog and clears field',
        (tester) async {
      final defectsCtrl = TextEditingController(text: 'Defect to clear');
      final remarksCtrl = TextEditingController(text: 'Remark to clear');
      bool changed = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: SingleChildScrollView(
              child: GebrekenOpmerkingenCard(
                defectsController: defectsCtrl,
                remarksController: remarksCtrl,
                hasNegativeAssessment: false,
                fuelType: 'gas',
                boilerType: 'C',
                onChanged: () => changed = true,
              ),
            ),
          ),
        ),
      );

      // Two clear buttons are visible because both controllers have text
      expect(find.byTooltip(EindbeoordelingDictionary.btnWissen),
          findsNWidgets(2));

      // Tap the first clear button (for defects)
      await tester
          .tap(find.byTooltip(EindbeoordelingDictionary.btnWissen).first);
      await tester.pumpAndSettle();

      // Dialog is shown
      expect(find.text(EindbeoordelingDictionary.dlgClearDefectsTitle),
          findsOneWidget);

      // Confirm in dialog
      await tester.tap(find.text(EindbeoordelingDictionary.btnWissen).last);
      await tester.pumpAndSettle();

      expect(defectsCtrl.text, isEmpty);
      expect(changed, isTrue);
    });

    testWidgets(
        'Preset already present in text box appears disabled with Reeds toegevoegd badge',
        (tester) async {
      final defectsCtrl = TextEditingController(
          text: '• Expansievat membraan gescheurd');
      final remarksCtrl = TextEditingController(
          text: '• Expansievat vervangen');

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: SingleChildScrollView(
              child: GebrekenOpmerkingenCard(
                defectsController: defectsCtrl,
                remarksController: remarksCtrl,
                hasNegativeAssessment: false,
                fuelType: 'gas',
                boilerType: 'C',
                onChanged: () {},
              ),
            ),
          ),
        ),
      );

      // Open Snelselectie
      await tester.tap(find.byIcon(Icons.lightbulb_outline_rounded));
      await tester.pumpAndSettle();

      // Expansievat preset is already present -> displays "Reeds toegevoegd" badge
      expect(find.text('Reeds toegevoegd'), findsOneWidget);
    });
  });
}
