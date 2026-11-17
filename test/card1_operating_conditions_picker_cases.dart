part of 'card1_operating_conditions_test.dart';

void _pickerTests() {
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
}
