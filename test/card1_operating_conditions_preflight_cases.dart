part of 'card1_operating_conditions_test.dart';

void _preflightTests() {
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

  test('OperatingConditionsDraft.copyWith correctly clears fields to null', () {
    final initial = OperatingConditionsDraft.empty().copyWith(
      boilerTempCelsius: 60.0,
      gasPressureMeterMbar: 22.0,
      gasPressureBlockMbar: 18.0,
      gasPressureBurnerBedMbar: 10.0,
      nozzleBrandType: 'Danfoss',
      nozzleFlowRate: '0.60',
      nozzleAngleDegrees: 60.0,
      pumpPressureBar: 12.0,
      smokeIndexBacharach: 1,
    );

    expect(initial.boilerTempCelsius, 60.0);
    expect(initial.gasPressureMeterMbar, 22.0);

    // Now clear them to null
    final cleared = initial.copyWith(
      boilerTempCelsius: null,
      gasPressureMeterMbar: null,
      gasPressureBlockMbar: null,
      gasPressureBurnerBedMbar: null,
      nozzleBrandType: null,
      nozzleFlowRate: null,
      nozzleAngleDegrees: null,
      pumpPressureBar: null,
      smokeIndexBacharach: null,
    );

    expect(cleared.boilerTempCelsius, isNull);
    expect(cleared.gasPressureMeterMbar, isNull);
    expect(cleared.gasPressureBlockMbar, isNull);
    expect(cleared.gasPressureBurnerBedMbar, isNull);
    expect(cleared.nozzleBrandType, isNull);
    expect(cleared.nozzleFlowRate, isNull);
    expect(cleared.nozzleAngleDegrees, isNull);
    expect(cleared.pumpPressureBar, isNull);
    expect(cleared.smokeIndexBacharach, isNull);
  });
}
