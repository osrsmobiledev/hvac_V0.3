// File: test/preflight_meting_eindbeoordeling_test.dart
// Responsibility: Pre-flight validation tests for Tab 6 (Rookgasmetingen,
// Veilige staat van werking) and Tab 7 (Staat van werking & Veiligheid).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/app/localization/eindbeoordeling_dictionary.dart';
import 'package:hvac_app/app/localization/meting_dictionary.dart';
import 'package:hvac_app/features/certificate_draft/domain/boiler_draft.dart';
import 'package:hvac_app/features/certificate_draft/domain/operating_conditions_draft.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/meting/combustion_fields_layout.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/meting/measurement_slots_card.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/meting/safety_checks_card.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/meting/slot_form_controllers.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/eindbeoordeling/staat_van_werking_card.dart';

void main() {
  group('Pre-Flight: Rookgasmetingen (CombustionFieldsLayout validators)', () {
    Widget buildCard({
      required TextEditingController o2,
      required TextEditingController co2,
      required TextEditingController coMgKwh,
      required TextEditingController flueTempTg,
      required TextEditingController ambientTempTa,
      required TextEditingController efficiencyHi,
      required TextEditingController efficiencyHs,
      required GlobalKey<FormState> formKey,
      String activeSlot = 'proef1',
    }) {
      return MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: CombustionFieldsLayout(
                boiler: BoilerDraft.initial().copyWith(fuelCategory: 'gas'),
                activeSlot: activeSlot,
                o2Controller: o2,
                co2Controller: co2,
                coMgKwhController: coMgKwh,
                flueTempTgController: flueTempTg,
                ambientTempTaController: ambientTempTa,
                calculatedNetTemp: '',
                efficiencyHiController: efficiencyHi,
                efficiencyHsController: efficiencyHs,
                onChanged: () {},
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('Empty combustion fields fail pre-flight validation',
        (tester) async {
      tester.view.physicalSize = const Size(412, 2200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final formKey = GlobalKey<FormState>();
      final o2 = TextEditingController();
      final co2 = TextEditingController();
      final co = TextEditingController();
      final tg = TextEditingController();
      final ta = TextEditingController();
      final hi = TextEditingController();
      final hs = TextEditingController();

      await tester.pumpWidget(buildCard(
        o2: o2,
        co2: co2,
        coMgKwh: co,
        flueTempTg: tg,
        ambientTempTa: ta,
        efficiencyHi: hi,
        efficiencyHs: hs,
        formKey: formKey,
      ));
      await tester.pumpAndSettle();

      // All required combustion fields empty → invalid
      expect(formKey.currentState!.validate(), isFalse);
    });

    testWidgets(
        'All required combustion fields filled pass pre-flight validation',
        (tester) async {
      tester.view.physicalSize = const Size(412, 2200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final formKey = GlobalKey<FormState>();
      final o2 = TextEditingController(text: '4.8');
      final co2 = TextEditingController(text: '9.2');
      final co = TextEditingController(text: '24');
      final tg = TextEditingController(text: '54');
      final ta = TextEditingController(text: '20');
      final hi = TextEditingController(text: '98');
      final hs = TextEditingController();

      await tester.pumpWidget(buildCard(
        o2: o2,
        co2: co2,
        coMgKwh: co,
        flueTempTg: tg,
        ambientTempTa: ta,
        efficiencyHi: hi,
        efficiencyHs: hs,
        formKey: formKey,
      ));
      await tester.pumpAndSettle();

      // Required fields filled (hs is optional) → valid
      expect(formKey.currentState!.validate(), isTrue);
    });

    testWidgets('Proef 2 Hooglast is optional and passes even when all empty',
        (tester) async {
      tester.view.physicalSize = const Size(412, 2200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final formKey = GlobalKey<FormState>();
      final o2 = TextEditingController();
      final co2 = TextEditingController();
      final co = TextEditingController();
      final tg = TextEditingController();
      final ta = TextEditingController();
      final hi = TextEditingController();
      final hs = TextEditingController();

      await tester.pumpWidget(buildCard(
        o2: o2,
        co2: co2,
        coMgKwh: co,
        flueTempTg: tg,
        ambientTempTa: ta,
        efficiencyHi: hi,
        efficiencyHs: hs,
        formKey: formKey,
        activeSlot: 'proef2_hooglast',
      ));
      await tester.pumpAndSettle();

      // Hooglast is legally optional in Flanders → all empty is valid!
      expect(formKey.currentState!.validate(), isTrue);
    });

    testWidgets('Proef 2 Laaglast is required and fails when empty',
        (tester) async {
      tester.view.physicalSize = const Size(412, 2200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final formKey = GlobalKey<FormState>();
      final o2 = TextEditingController();
      final co2 = TextEditingController();
      final co = TextEditingController();
      final tg = TextEditingController();
      final ta = TextEditingController();
      final hi = TextEditingController();
      final hs = TextEditingController();

      await tester.pumpWidget(buildCard(
        o2: o2,
        co2: co2,
        coMgKwh: co,
        flueTempTg: tg,
        ambientTempTa: ta,
        efficiencyHi: hi,
        efficiencyHs: hs,
        formKey: formKey,
        activeSlot: 'proef2_laaglast',
      ));
      await tester.pumpAndSettle();

      // Laaglast is required for modulating boilers → empty is invalid
      expect(formKey.currentState!.validate(), isFalse);
    });
  });

  group(
      'Pre-Flight: Both Proef 1 & Proef 2 Laaglast required (MeasurementSlotsCard)',
      () {
    Widget buildMultiSlotCard({
      required Map<String, SlotFormControllers> slots,
      required GlobalKey<FormState> formKey,
      String activeSlot = 'proef1',
      ValueChanged<String>? onSlotChanged,
    }) {
      return MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: MeasurementSlotsCard(
                boiler: BoilerDraft.initial().copyWith(fuelCategory: 'gas'),
                activeSlot: activeSlot,
                onSlotChanged: onSlotChanged ?? (_) {},
                slots: slots,
                onCopyFromDataTab: () {},
                onScanEurolyzer: () {},
                onClearSlot: () {},
                onChanged: () {},
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('Fails when Proef 1 is filled but Proef 2 Laaglast is empty',
        (tester) async {
      tester.view.physicalSize = const Size(412, 2200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final formKey = GlobalKey<FormState>();
      final slots = {
        'proef1': SlotFormControllers(),
        'proef2_laaglast': SlotFormControllers(),
        'proef2_hooglast': SlotFormControllers(),
      };

      // Fill Proef 1 completely
      slots['proef1']!.o2.text = '4.5';
      slots['proef1']!.co2.text = '9.3';
      slots['proef1']!.coMgKwh.text = '25';
      slots['proef1']!.flueTempTg.text = '55';
      slots['proef1']!.ambientTempTa.text = '20';
      slots['proef1']!.efficiencyHi.text = '98';

      // Leave Proef 2 Laaglast empty
      await tester.pumpWidget(buildMultiSlotCard(
        slots: slots,
        formKey: formKey,
        activeSlot: 'proef1',
      ));
      await tester.pumpAndSettle();

      // Proef 1 is complete, but Proef 2 Laaglast is required → form fails!
      expect(formKey.currentState!.validate(), isFalse);
    });

    testWidgets(
        'Passes when both Proef 1 and Proef 2 Laaglast are filled (Hooglast empty)',
        (tester) async {
      tester.view.physicalSize = const Size(412, 2200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final formKey = GlobalKey<FormState>();
      final slots = {
        'proef1': SlotFormControllers(),
        'proef2_laaglast': SlotFormControllers(),
        'proef2_hooglast': SlotFormControllers(),
      };

      // Fill Proef 1
      slots['proef1']!.o2.text = '4.5';
      slots['proef1']!.co2.text = '9.3';
      slots['proef1']!.coMgKwh.text = '25';
      slots['proef1']!.flueTempTg.text = '55';
      slots['proef1']!.ambientTempTa.text = '20';
      slots['proef1']!.efficiencyHi.text = '98';

      // Fill Proef 2 Laaglast
      slots['proef2_laaglast']!.o2.text = '5.0';
      slots['proef2_laaglast']!.co2.text = '9.0';
      slots['proef2_laaglast']!.coMgKwh.text = '20';
      slots['proef2_laaglast']!.flueTempTg.text = '52';
      slots['proef2_laaglast']!.ambientTempTa.text = '20';
      slots['proef2_laaglast']!.efficiencyHi.text = '99';

      // Hooglast empty
      await tester.pumpWidget(buildMultiSlotCard(
        slots: slots,
        formKey: formKey,
        activeSlot: 'proef1',
      ));
      await tester.pumpAndSettle();

      // Both statutory slots filled → form passes!
      expect(formKey.currentState!.validate(), isTrue);
    });

    testWidgets(
        'Populating simulated measurements clears red borders automatically',
        (tester) async {
      tester.view.physicalSize = const Size(412, 2200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final formKey = GlobalKey<FormState>();
      final slots = {
        'proef1': SlotFormControllers(),
        'proef2_laaglast': SlotFormControllers(),
        'proef2_hooglast': SlotFormControllers(),
      };

      await tester.pumpWidget(buildMultiSlotCard(
        slots: slots,
        formKey: formKey,
        activeSlot: 'proef1',
      ));
      await tester.pumpAndSettle();

      // Trigger pre-flight check on empty slots → fails
      formKey.currentState!.validate();
      await tester.pump();

      // Now simulate measurements being inserted into Proef 1 & 2
      slots['proef1']!.o2.text = '4.8 %';
      slots['proef1']!.co2.text = '9.2 %';
      slots['proef1']!.coMgKwh.text = '24';
      slots['proef1']!.flueTempTg.text = '54 °C';
      slots['proef1']!.ambientTempTa.text = '20 °C';
      slots['proef1']!.efficiencyHi.text = '98';

      slots['proef2_laaglast']!.o2.text = '5.0 %';
      slots['proef2_laaglast']!.co2.text = '9.0 %';
      slots['proef2_laaglast']!.coMgKwh.text = '20';
      slots['proef2_laaglast']!.flueTempTg.text = '52 °C';
      slots['proef2_laaglast']!.ambientTempTa.text = '20 °C';
      slots['proef2_laaglast']!.efficiencyHi.text = '99';

      await tester.pump();

      // With autovalidateMode: onUserInteraction, the form should now be valid!
      expect(formKey.currentState!.validate(), isTrue);
    });
  });

  group('Pre-Flight: Veilige staat van werking (SafetyChecksCard validators)',
      () {
    Widget buildCard({
      required BoilerDraft boiler,
      required OperatingConditionsDraft draft,
      required GlobalKey<FormState> formKey,
    }) {
      return MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: SafetyChecksCard(
                boiler: boiler,
                draft: draft,
                onDraftChanged: (_) {},
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('Gas boiler with unanswered safety toggles fails validation',
        (tester) async {
      final formKey = GlobalKey<FormState>();
      final boiler = BoilerDraft.initial().copyWith(
        fuelCategory: 'gas',
        centraalType: 'C',
      );
      // All toggles null (unanswered)
      final draft = OperatingConditionsDraft.empty();

      await tester.pumpWidget(
          buildCard(boiler: boiler, draft: draft, formKey: formKey));
      await tester.pumpAndSettle();

      expect(formKey.currentState!.validate(), isFalse);
    });

    testWidgets('Gas boiler with all applicable safety toggles answered passes',
        (tester) async {
      final formKey = GlobalKey<FormState>();
      final boiler = BoilerDraft.initial().copyWith(
        fuelCategory: 'gas',
        centraalType: 'C',
      );
      // Gas + Type C: fluePressure, ventilation, fuelSupplyTightness, flueTightness
      final draft = OperatingConditionsDraft.empty().copyWith(
        fluePressureOk: true,
        ventilationOk: true,
        fuelSupplyTightnessOk: true,
        flueTightnessOk: true,
      );

      await tester.pumpWidget(
          buildCard(boiler: boiler, draft: draft, formKey: formKey));
      await tester.pumpAndSettle();

      expect(formKey.currentState!.validate(), isTrue);
    });

    testWidgets('Liquid boiler with applicable toggles answered passes',
        (tester) async {
      final formKey = GlobalKey<FormState>();
      final boiler = BoilerDraft.initial().copyWith(
        fuelCategory: 'vloeibaar',
        centraalType: 'B',
      );
      // Liquid + Type B: fluePressure, ventilation, noOilTrace, noUnwantedCondensation
      final draft = OperatingConditionsDraft.empty().copyWith(
        fluePressureOk: true,
        ventilationOk: false, // NOK but answered → valid form
        noOilTraceOk: true,
        noUnwantedCondensationOk: true,
      );

      await tester.pumpWidget(
          buildCard(boiler: boiler, draft: draft, formKey: formKey));
      await tester.pumpAndSettle();

      expect(formKey.currentState!.validate(), isTrue);
    });

    testWidgets(
        'Gas-only toggle (fuelSupplyTightness) is NOT validated for solid fuel',
        (tester) async {
      final formKey = GlobalKey<FormState>();
      final boiler = BoilerDraft.initial().copyWith(
        fuelCategory: 'vast',
        centraalType: 'B',
      );
      // Solid + Type B: fluePressure, ventilation, noUnwantedCondensation, rarelyPollutingSmoke
      final draft = OperatingConditionsDraft.empty().copyWith(
        fluePressureOk: true,
        ventilationOk: true,
        noUnwantedCondensationOk: true,
        rarelyPollutingSmokeOk: false, // answered (NOK) but answered → valid
      );

      await tester.pumpWidget(
          buildCard(boiler: boiler, draft: draft, formKey: formKey));
      await tester.pumpAndSettle();

      // fuelSupplyTightnessOk remains null but should NOT be validated for solid fuel
      expect(draft.fuelSupplyTightnessOk, isNull);
      expect(formKey.currentState!.validate(), isTrue);
    });
  });

  group(
      'Pre-Flight: Staat van werking & Veiligheid (StaatVanWerkingCard validators)',
      () {
    Widget buildCard({
      required String? selectedGoed,
      required String? selectedVeilig,
      required GlobalKey<FormState> formKey,
    }) {
      return MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: StaatVanWerkingCard(
                selectedGoed: selectedGoed,
                selectedVeilig: selectedVeilig,
                selectedDate: null,
                fuelType: 'gas',
                onGoedChanged: (_) {},
                onVeiligChanged: (_) {},
                onDateChanged: (_) {},
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('Both conclusion toggles unanswered fails pre-flight',
        (tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(buildCard(
        selectedGoed: null,
        selectedVeilig: null,
        formKey: formKey,
      ));
      await tester.pumpAndSettle();

      expect(formKey.currentState!.validate(), isFalse);
    });

    testWidgets('Only toestelWerkingGoed answered still fails', (tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(buildCard(
        selectedGoed: EindbeoordelingDictionary.optGoed,
        selectedVeilig: null,
        formKey: formKey,
      ));
      await tester.pumpAndSettle();

      expect(formKey.currentState!.validate(), isFalse);
    });

    testWidgets('Both toggles answered (even NOK) passes pre-flight',
        (tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(buildCard(
        selectedGoed: EindbeoordelingDictionary.optNietGoed,
        selectedVeilig: EindbeoordelingDictionary.optNietVeilig,
        formKey: formKey,
      ));
      await tester.pumpAndSettle();

      // NOK answers are still valid answers — form should pass
      expect(formKey.currentState!.validate(), isTrue);
    });

    testWidgets('Unanswered toggles show red border after validate() is called',
        (tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(buildCard(
        selectedGoed: null,
        selectedVeilig: null,
        formKey: formKey,
      ));
      await tester.pumpAndSettle();

      formKey.currentState!.validate();
      await tester.pump();

      // Red border containers should be visible
      final redBorderContainers = tester
          .widgetList<Container>(
        find.byType(Container),
      )
          .where((c) {
        final decoration = c.decoration;
        if (decoration is BoxDecoration) {
          final border = decoration.border;
          if (border is Border) {
            return border.top.color == AppColors.errorRed;
          }
        }
        return false;
      });

      expect(redBorderContainers.isNotEmpty, isTrue);
    });

    testWidgets(
        'Red border shown for lblCheckFluePressure when unanswered in gas boiler',
        (tester) async {
      final formKey = GlobalKey<FormState>();
      final boiler = BoilerDraft.initial()
          .copyWith(fuelCategory: 'gas', centraalType: 'C');
      final draft = OperatingConditionsDraft.empty();

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: SafetyChecksCard(
                boiler: boiler,
                draft: draft,
                onDraftChanged: (_) {},
              ),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      formKey.currentState!.validate();
      await tester.pump();

      // The flue pressure label must be visible
      expect(find.text(MetingDictionary.lblCheckFluePressure), findsOneWidget);
    });
  });
}
