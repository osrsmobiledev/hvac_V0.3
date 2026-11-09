import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/features/certificate_draft/domain/boiler_draft.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/meting/bacharach_selector.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/meting/operating_conditions_card.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/meting/slider_input_row.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/meting/wheel_input_row.dart';
import 'package:hvac_app/features/certificate_draft/ui/widgets/horizontal_wheel_picker.dart';
import 'package:hvac_app/features/certificate_draft/ui/widgets/quick_slider_picker.dart';

void main() {
  group('Card 1 — Operating Conditions Smart Logic & Quick Slider Picker', () {
    testWidgets(
        'QuickSliderPicker toggles selection (tap to select, tap to unselect)',
        (tester) async {
      final controller = TextEditingController();
      bool changed = false;

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: QuickSliderPicker.forController(
            controller: controller,
            options: const ['21', '25', '37'],
            onChanged: () => changed = true,
            suffix: 'mbar',
          ),
        ),
      ));

      expect(find.text('21 mbar'), findsOneWidget);
      expect(find.text('25 mbar'), findsOneWidget);

      // 1. First tap selects '21'
      await tester.tap(find.text('21 mbar'));
      await tester.pump();
      expect(controller.text, '21');
      expect(changed, isTrue);

      // 2. Second tap on active '21' unselects it (clears to empty)
      changed = false;
      await tester.tap(find.text('21 mbar'));
      await tester.pump();
      expect(controller.text, '');
      expect(changed, isTrue);
    });

    testWidgets(
        'SliderInputRow coordinates chip selection and compact text entry',
        (tester) async {
      final controller = TextEditingController();
      bool changed = false;

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: SliderInputRow(
            controller: controller,
            options: const ['50', '60', '70', '80'],
            suffix: '°C',
            hintText: '°C',
            onChanged: () => changed = true,
          ),
        ),
      ));

      expect(find.text('60 °C'), findsOneWidget);

      // Tap chip
      await tester.tap(find.text('60 °C'));
      await tester.pump();
      expect(controller.text, '60');
      expect(changed, isTrue);

      // Custom input in small text field
      await tester.enterText(find.byType(TextFormField), '65');
      await tester.pump();
      expect(controller.text, '65');
    });

    testWidgets(
        'WheelInputRow coordinates 3D wheel selection, text entry, and decimal nudge steppers',
        (tester) async {
      final controller = TextEditingController(text: '20');
      bool changed = false;

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: WheelInputRow.range(
            min: 15,
            max: 37,
            controller: controller,
            suffix: 'mbar',
            hintText: 'mbar',
            onChanged: () => changed = true,
          ),
        ),
      ));

      expect(find.byType(WheelInputRow), findsOneWidget);
      expect(find.byType(QuickSliderPicker), findsOneWidget);
      expect(find.text('20 mbar'), findsOneWidget);
      expect(find.text('20'), findsOneWidget);

      // Verify '-' stepper: tapping '-' on '20' wraps backwards to '20,9'
      final minusFinder = find.byIcon(Icons.remove);
      final plusFinder = find.byIcon(Icons.add);
      expect(minusFinder, findsOneWidget);
      expect(plusFinder, findsOneWidget);

      await tester.tap(minusFinder);
      await tester.pumpAndSettle();
      expect(controller.text, '20,9');
      expect(changed, isTrue);

      // Verify '-' stepper again: '20,9' -> '20,8'
      await tester.tap(minusFinder);
      await tester.pumpAndSettle();
      expect(controller.text, '20,8');

      // Verify '+' stepper: '20,8' -> '20,9'
      await tester.tap(plusFinder);
      await tester.pumpAndSettle();
      expect(controller.text, '20,9');

      // Verify '+' stepper wraps back to integer: '20,9' -> '20'
      await tester.tap(plusFinder);
      await tester.pumpAndSettle();
      expect(controller.text, '20');

      // Custom input in responsive text field
      await tester.enterText(find.byType(TextFormField), '25');
      await tester.pumpAndSettle();
      expect(controller.text, '25');
    });

    testWidgets(
        'BacharachSelector toggles selection and auto-evaluates compliance',
        (tester) async {
      final controller = TextEditingController();
      bool? isOk;

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.darkTheme,
        home: StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              body: BacharachSelector(
                controller: controller,
                isOk: isOk,
                onOkChanged: (val) => setState(() => isOk = val),
                onChanged: () {},
              ),
            );
          },
        ),
      ));

      // 1. Tap '0' -> auto sets OK (true)
      await tester.tap(find.text('0'));
      await tester.pump();
      expect(controller.text, '0');
      expect(isOk, isTrue);

      // 2. Tap '0' again -> unselects (empty & null check)
      await tester.tap(find.text('0'));
      await tester.pump();
      expect(controller.text, '');
      expect(isOk, isNull);

      // 3. Tap '>2' -> auto sets Niet OK (false)
      await tester.tap(find.text('>2'));
      await tester.pump();
      expect(controller.text, '>2');
      expect(isOk, isFalse);

      // 4. Tap '1' -> auto sets OK (true)
      await tester.tap(find.text('1'));
      await tester.pump();
      expect(controller.text, '1');
      expect(isOk, isTrue);
    });

    testWidgets(
        'OperatingConditionsCard renders quick slider ribbons for gas and oil',
        (tester) async {
      final boilerTemp = TextEditingController(text: '60');
      final gasMeter = TextEditingController(text: '21');
      final gasBlock = TextEditingController();
      final gasBed = TextEditingController();
      final nozzleBrand = TextEditingController();
      final nozzleFlow = TextEditingController();
      final nozzleAngle = TextEditingController(text: '60');
      final pumpPressure = TextEditingController();
      final smokeIndex = TextEditingController();
      bool? smokeOk;

      Widget buildCard(BoilerDraft boiler) {
        return MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: SingleChildScrollView(
              child: OperatingConditionsCard(
                boiler: boiler,
                boilerTempController: boilerTemp,
                gasMeterController: gasMeter,
                gasBlockController: gasBlock,
                gasBurnerBedController: gasBed,
                nozzleBrandTypeController: nozzleBrand,
                nozzleFlowRateController: nozzleFlow,
                nozzleAngleController: nozzleAngle,
                pumpPressureController: pumpPressure,
                smokeIndexController: smokeIndex,
                smokeIndexOk: smokeOk,
                onSmokeIndexOkChanged: (v) => smokeOk = v,
                onChanged: () {},
              ),
            ),
          ),
        );
      }

      // Gas mode
      await tester.pumpWidget(
        buildCard(BoilerDraft.initial().copyWith(fuelCategory: 'gas')),
      );
      expect(find.text('21 mbar'), findsWidgets);
      expect(find.byType(WheelInputRow), findsNWidgets(4));
      expect(find.byType(QuickSliderPicker), findsWidgets);

      // Oil mode
      await tester.pumpWidget(
        buildCard(BoilerDraft.initial().copyWith(fuelCategory: 'vloeibaar')),
      );
      expect(find.text('Danfoss'), findsOneWidget);
      expect(find.text('60 °'), findsWidgets);
      expect(find.byType(WheelInputRow), findsNWidgets(4));
      expect(find.byType(BacharachSelector), findsOneWidget);
    });

    testWidgets(
        'HorizontalWheelPicker initializes, scrolls and updates controller',
        (tester) async {
      final controller = TextEditingController(text: '60');

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: HorizontalWheelPicker.range(
            min: 50,
            max: 80,
            controller: controller,
            suffix: '°C',
            onChanged: () {},
          ),
        ),
      ));

      expect(find.byType(HorizontalWheelPicker), findsOneWidget);
      expect(find.text('60 °C'), findsOneWidget);

      // Programmatically update controller -> wheel synchronizes
      controller.text = '70';
      await tester.pumpAndSettle();
      expect(find.text('70 °C'), findsOneWidget);
    });

    testWidgets(
        'HorizontalWheelPicker rests on preferredInitialItem when empty, and 1-tap applies it',
        (tester) async {
      final controller = TextEditingController();
      bool changed = false;

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: HorizontalWheelPicker.range(
            min: 15,
            max: 37,
            controller: controller,
            preferredInitialItem: '21',
            suffix: 'mbar',
            onChanged: () => changed = true,
          ),
        ),
      ));

      // Controller is legally empty
      expect(controller.text, '');
      expect(find.text('21 mbar'), findsOneWidget);

      // Tapping the resting centered 21 mbar item locks it in in 1 tap!
      await tester.tap(find.text('21 mbar'));
      await tester.pump();
      expect(controller.text, '21');
      expect(changed, isTrue);
    });

    testWidgets(
        'BacharachSelector does not overflow on narrow 360px mobile screen',
        (tester) async {
      tester.view.physicalSize = const Size(360, 740);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final controller = TextEditingController();
      bool? isOk;

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: BacharachSelector(
              controller: controller,
              isOk: isOk,
              onOkChanged: (v) => isOk = v,
              onChanged: () {},
            ),
          ),
        ),
      ));

      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'QuickSliderPicker does not scroll or switch ancestor TabBarView tabs when initialized or updated',
        (tester) async {
      final tabController = TabController(length: 2, vsync: const TestVSync());
      final pickerController = TextEditingController();

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: TabBarView(
            controller: tabController,
            children: [
              const Center(child: Text('Tab 0 Content')),
              Center(
                child: QuickSliderPicker.forController(
                  controller: pickerController,
                  options: const ['50', '60', '70', '80'],
                  preferredInitialItem: '70',
                  suffix: '°C',
                  onChanged: () {},
                ),
              ),
            ],
          ),
        ),
      ));

      // Tab 0 must remain active!
      expect(tabController.index, 0);
      expect(find.text('Tab 0 Content'), findsOneWidget);

      // Rebuild and pump to let any post-frame callbacks execute
      await tester.pumpAndSettle();

      // Ensure Tab 0 is STILL active and has not been teleported to Tab 1
      expect(tabController.index, 0);
      expect(find.text('Tab 0 Content'), findsOneWidget);
    });

    testWidgets(
        'Card 1 Pre-Flight Check: Fuel Gas validates only boilerTemp and gas pressures',
        (tester) async {
      final formKey = GlobalKey<FormState>();
      final boiler = BoilerDraft.initial().copyWith(
        fuelCategory: 'gas',
        fuelSubtype: 'aardgas',
      );
      final boilerTemp = TextEditingController();
      final gasMeter = TextEditingController();
      final gasBlock = TextEditingController();
      final gasBurnerBed = TextEditingController();
      final nozzleBrand = TextEditingController();
      final nozzleFlow = TextEditingController();
      final nozzleAngle = TextEditingController();
      final pumpPressure = TextEditingController();
      final smokeIndex = TextEditingController();
      bool? smokeOk;

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: OperatingConditionsCard(
                boiler: boiler,
                boilerTempController: boilerTemp,
                gasMeterController: gasMeter,
                gasBlockController: gasBlock,
                gasBurnerBedController: gasBurnerBed,
                nozzleBrandTypeController: nozzleBrand,
                nozzleFlowRateController: nozzleFlow,
                nozzleAngleController: nozzleAngle,
                pumpPressureController: pumpPressure,
                smokeIndexController: smokeIndex,
                smokeIndexOk: smokeOk,
                onSmokeIndexOkChanged: (v) => smokeOk = v,
                onChanged: () {},
              ),
            ),
          ),
        ),
      ));

      // Initially empty -> validate fails
      final isValidInitial = formKey.currentState!.validate();
      expect(isValidInitial, isFalse);

      // Liquid fields do NOT exist in the widget tree for gas!
      expect(find.text('Sproeier: merk en type'), findsNothing);
      expect(find.text('Sproeier: debiet'), findsNothing);
      expect(find.text('Pompdruk (bar)'), findsNothing);

      // Gas fields DO exist and are required
      expect(find.text('Gasdruk teller (mbar)'), findsOneWidget);
      expect(find.text('Gasdruk gasblok (mbar)'), findsOneWidget);
      expect(find.text('Gasdruk branderbed (mbar)'), findsOneWidget);

      // Populate all gas fields
      boilerTemp.text = '60';
      gasMeter.text = '21';
      gasBlock.text = '20';
      gasBurnerBed.text = '10';

      await tester.pump();
      final isValidFilled = formKey.currentState!.validate();
      expect(isValidFilled, isTrue);
    });

    testWidgets(
        'Card 1 Pre-Flight Check: Fuel Liquid validates only boilerTemp, nozzle, pump and Bacharach',
        (tester) async {
      final formKey = GlobalKey<FormState>();
      final boiler = BoilerDraft.initial().copyWith(
        fuelCategory: 'vloeibaar',
        fuelSubtype: 'stookolie',
      );
      final boilerTemp = TextEditingController();
      final gasMeter = TextEditingController();
      final gasBlock = TextEditingController();
      final gasBurnerBed = TextEditingController();
      final nozzleBrand = TextEditingController();
      final nozzleFlow = TextEditingController();
      final nozzleAngle = TextEditingController();
      final pumpPressure = TextEditingController();
      final smokeIndex = TextEditingController();
      bool? smokeOk;

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, setModalState) {
                return Form(
                  key: formKey,
                  child: OperatingConditionsCard(
                    boiler: boiler,
                    boilerTempController: boilerTemp,
                    gasMeterController: gasMeter,
                    gasBlockController: gasBlock,
                    gasBurnerBedController: gasBurnerBed,
                    nozzleBrandTypeController: nozzleBrand,
                    nozzleFlowRateController: nozzleFlow,
                    nozzleAngleController: nozzleAngle,
                    pumpPressureController: pumpPressure,
                    smokeIndexController: smokeIndex,
                    smokeIndexOk: smokeOk,
                    onSmokeIndexOkChanged: (v) =>
                        setModalState(() => smokeOk = v),
                    onChanged: () {},
                  ),
                );
              },
            ),
          ),
        ),
      ));

      // Initially empty -> validate fails
      final isValidInitial = formKey.currentState!.validate();
      expect(isValidInitial, isFalse);

      // Gas fields do NOT exist in the widget tree for liquid!
      expect(find.text('Gasdruk teller (mbar)'), findsNothing);
      expect(find.text('Gasdruk gasblok (mbar)'), findsNothing);
      expect(find.text('Gasdruk branderbed (mbar)'), findsNothing);

      // Liquid fields DO exist and are required
      expect(find.text('Sproeier: merk en type'), findsOneWidget);
      expect(find.text('Sproeier: debiet'), findsOneWidget);
      expect(find.text('Pompdruk (bar)'), findsOneWidget);
      expect(find.text('Rookindex (Bacharach)'), findsOneWidget);

      // Populate liquid fields
      boilerTemp.text = '65';
      nozzleBrand.text = 'Danfoss';
      nozzleFlow.text = '0.60';
      nozzleAngle.text = '60';
      pumpPressure.text = '10';

      // Tap Bacharach 0 chip (which automatically marks OK)
      await tester.tap(find.text('0'));
      await tester.pump();

      final isValidFilled = formKey.currentState!.validate();
      expect(isValidFilled, isTrue);
    });

    testWidgets('Card 1 Pre-Flight Check: Fuel Solid validates ONLY boilerTemp',
        (tester) async {
      final formKey = GlobalKey<FormState>();
      final boiler = BoilerDraft.initial().copyWith(
        fuelCategory: 'vast',
        fuelSubtype: 'houtpellets',
      );
      final boilerTemp = TextEditingController();
      final gasMeter = TextEditingController();
      final gasBlock = TextEditingController();
      final gasBurnerBed = TextEditingController();
      final nozzleBrand = TextEditingController();
      final nozzleFlow = TextEditingController();
      final nozzleAngle = TextEditingController();
      final pumpPressure = TextEditingController();
      final smokeIndex = TextEditingController();
      bool? smokeOk;

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: OperatingConditionsCard(
                boiler: boiler,
                boilerTempController: boilerTemp,
                gasMeterController: gasMeter,
                gasBlockController: gasBlock,
                gasBurnerBedController: gasBurnerBed,
                nozzleBrandTypeController: nozzleBrand,
                nozzleFlowRateController: nozzleFlow,
                nozzleAngleController: nozzleAngle,
                pumpPressureController: pumpPressure,
                smokeIndexController: smokeIndex,
                smokeIndexOk: smokeOk,
                onSmokeIndexOkChanged: (v) => smokeOk = v,
                onChanged: () {},
              ),
            ),
          ),
        ),
      ));

      // Initially empty -> validate fails
      final isValidInitial = formKey.currentState!.validate();
      expect(isValidInitial, isFalse);

      // Neither gas nor liquid fields exist for solid
      expect(find.text('Gasdruk teller (mbar)'), findsNothing);
      expect(find.text('Sproeier: merk en type'), findsNothing);

      // Only Keteltemperatuur is present
      expect(find.text('Keteltemperatuur (°C)'), findsOneWidget);

      // Fill Keteltemperatuur
      boilerTemp.text = '70';
      await tester.pump();

      final isValidFilled = formKey.currentState!.validate();
      expect(isValidFilled, isTrue);
    });
  });
}
