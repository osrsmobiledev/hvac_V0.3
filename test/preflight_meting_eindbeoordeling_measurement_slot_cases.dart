part of 'preflight_meting_eindbeoordeling_test.dart';

void _measurementSlotCases() {
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
}
