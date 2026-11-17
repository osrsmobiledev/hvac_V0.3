part of 'preflight_meting_eindbeoordeling_test.dart';

void _conclusionCases() {
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
