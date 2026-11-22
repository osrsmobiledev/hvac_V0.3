// File: test/preflight_liquid_fuel_validation_test.dart
// Purpose: Verifies that liquid fuel (stookolie) requires 5-digit TV number and permits empty GV number at pre-flight gate.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/core/database/app_database.dart';
import 'package:hvac_app/core/utils/form_scroll_helper.dart';
import 'package:hvac_app/features/certificate_draft/data/draft_repository.dart';
import 'package:hvac_app/features/certificate_draft/data/technician_profile_repository.dart';
import 'package:hvac_app/features/certificate_draft/domain/boiler_draft.dart';
import 'package:hvac_app/features/certificate_draft/domain/technician_profile.dart';
import 'package:hvac_app/features/certificate_draft/ui/boiler_draft_notifier.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/firma_technicus_tab.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Database db;
  late TechnicianProfileRepository profileRepo;
  late DraftRepository draftRepo;

  setUp(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    db = await AppDatabase.instance.initDatabase(
      customPath: inMemoryDatabasePath,
    );
    AppDatabase.instance.setDatabaseForTesting(db);
    profileRepo = TechnicianProfileRepository();
    draftRepo = DraftRepository();
  });

  tearDown(() async {
    await AppDatabase.instance.close();
  });

  testWidgets(
      'Pre-flight check blocks finalization when boiler fuel is oil but TV is missing or 4-digit',
      (tester) async {
    GlobalKey<FormState>? formKey;
    tester.view.physicalSize = const Size(412, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    // Profile without TV and without GV
    await tester.runAsync(() async {
      await profileRepo.saveProfile(
        const TechnicianProfile(
          companyName: 'HVAC Solutions BV',
          street: 'Kerkstraat',
          houseNumber: '1',
          postalCode: '9000',
          city: 'Gent',
          phone: '+32 470 12 34 56',
          email: 'info@hvac.be',
          kboNumber: 'BE 0400.378.485',
          technicianFirstName: 'Jan',
          technicianLastName: 'Peeters',
          gvNumber: '',
          tvNumber: '',
        ),
      );
    });

    final boilerNotifier = BoilerDraftNotifier();
    boilerNotifier.useSavedCopy(const BoilerDraft(fuelCategory: 'vloeibaar'));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: FirmaTechnicusTab(
            profileRepository: profileRepo,
            draftRepository: draftRepo,
            boilerNotifier: boilerNotifier,
            onFormKeyReady: (key) => formKey = key,
          ),
        ),
      ),
    );

    for (int i = 0; i < 20; i++) {
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 30));
      });
      await tester.pump();
      if (find.byType(CircularProgressIndicator).evaluate().isEmpty) break;
    }

    expect(formKey, isNotNull);

    // Set valid start and end times
    final startFinder = find.descendant(
      of: find.ancestor(
        of: find.text(AppDictionary.lblTimeFrom),
        matching: find.byType(Expanded),
      ),
      matching: find.byType(TextField),
    );
    final endFinder = find.descendant(
      of: find.ancestor(
        of: find.text(AppDictionary.lblTimeTo),
        matching: find.byType(Expanded),
      ),
      matching: find.byType(TextField),
    );
    tester.widget<TextField>(startFinder).controller!.text = '09:00';
    tester.widget<TextField>(endFinder).controller!.text = '10:30';
    await tester.pumpAndSettle();

    // When TV is missing, validation fails with statutory message
    expect(formKey!.currentState!.validate(), isFalse);
    expect(
      FormScrollHelper.findFirstError(formKey!.currentContext),
      'TV-nummer is verplicht voor stookolie',
    );

    // Find TV field and enter 4 digits (e.g. 0000)
    final tvInputFinder = find.descendant(
      of: find.ancestor(
        of: find.text(AppDictionary.lblTV),
        matching: find.byType(Expanded),
      ),
      matching: find.byType(TextField),
    );
    await tester.enterText(tvInputFinder, '0000');
    await tester.pump(const Duration(milliseconds: 350));

    expect(formKey!.currentState!.validate(), isFalse);
    expect(
      FormScrollHelper.findFirstError(formKey!.currentContext),
      'TV-nummer moet 5 cijfers zijn',
    );

    // Enter valid 5 digits for TV
    await tester.enterText(tvInputFinder, '54321');
    await tester.pump(const Duration(milliseconds: 350));

    // Now form validates successfully even with empty GV!
    expect(formKey!.currentState!.validate(), isTrue);
    expect(FormScrollHelper.findFirstError(formKey!.currentContext), isNull);

    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 350));
    });
    await tester.pumpAndSettle();
  });
}
