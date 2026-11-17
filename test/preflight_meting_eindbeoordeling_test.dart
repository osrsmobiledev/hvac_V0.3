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

part 'preflight_meting_eindbeoordeling_measurement_slot_cases.dart';
part 'preflight_meting_eindbeoordeling_safety_cases.dart';
part 'preflight_meting_eindbeoordeling_conclusion_cases.dart';

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

  _measurementSlotCases();
  _safetyCases();
  _conclusionCases();
}
