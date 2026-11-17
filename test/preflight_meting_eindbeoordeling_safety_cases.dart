part of 'preflight_meting_eindbeoordeling_test.dart';

void _safetyCases() {
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
}
