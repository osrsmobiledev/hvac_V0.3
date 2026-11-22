// File: test/preflight_finalization_validation_test.dart
// Purpose: Verifies that incomplete or malformed technician certification numbers (e.g. 4-digit GV0000)
// strictly block finalization at the pre-flight gate, navigate to Tab 3, and surface exact error feedback.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
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
      'Pre-flight check blocks finalization when GV has only 4 digits (e.g. GV0000)',
      (tester) async {
    GlobalKey<FormState>? formKey;
    tester.view.physicalSize = const Size(412, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    // Pre-populate with valid profile except 4-digit GV (GV0000)
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
          gvNumber: 'GV0000', // Incomplete 4 digits!
        ),
      );
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: FirmaTechnicusTab(
            profileRepository: profileRepo,
            draftRepository: draftRepo,
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

    // Set valid times so only GV is the invalid field
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
    tester.widget<TextField>(startFinder).controller!.text = '08:00';
    tester.widget<TextField>(endFinder).controller!.text = '10:00';
    await tester.pumpAndSettle();

    // Trigger pre-flight validation
    final isValid = formKey!.currentState!.validate();
    await tester.pumpAndSettle();

    // Finalization is BLOCKED
    expect(isValid, isFalse);

    // FormScrollHelper discovers the exact failing reason
    final errorDetail =
        FormScrollHelper.findFirstError(formKey!.currentContext);
    expect(errorDetail, equals('GV-nummer moet 5 cijfers zijn'));

    // GV field highlights red border
    final gvContainer = find.ancestor(
      of: find.text(AppDictionary.lblGV),
      matching: find.byType(Expanded),
    );
    final gvFieldFinder = find.descendant(
      of: gvContainer,
      matching: find.byType(TextField),
    );
    final gvField = tester.widget<TextField>(gvFieldFinder);
    expect(
      (gvField.decoration!.enabledBorder as OutlineInputBorder)
          .borderSide
          .color,
      AppColors.errorRed,
    );

    // Correcting GV to 5 digits clears the error
    await tester.enterText(gvFieldFinder, '01234');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });

    final isNowValid = formKey!.currentState!.validate();
    await tester.pump();

    // Now finalization check PASSES!
    expect(isNowValid, isTrue);
    expect(
      (tester.widget<TextField>(gvFieldFinder).decoration!.enabledBorder
              as OutlineInputBorder)
          .borderSide
          .color,
      isNot(AppColors.errorRed),
    );
  });

  testWidgets(
      'Pre-flight check blocks finalization when boiler fuel is gas but GV is missing',
      (tester) async {
    GlobalKey<FormState>? formKey;
    tester.view.physicalSize = const Size(412, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    // Profile with only TV (oil certification), missing GV (gas certification)
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
          tvNumber: 'TV67890',
        ),
      );
    });

    final boilerNotifier = BoilerDraftNotifier();
    boilerNotifier.useSavedCopy(const BoilerDraft(fuelCategory: 'gas'));

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

    // Set valid times
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
    tester.widget<TextField>(startFinder).controller!.text = '08:00';
    tester.widget<TextField>(endFinder).controller!.text = '10:00';
    await tester.pumpAndSettle();

    // Trigger pre-flight validation
    final isValid = formKey!.currentState!.validate();
    await tester.pumpAndSettle();

    // Blocked because gas requires GV!
    expect(isValid, isFalse);

    final errorDetail =
        FormScrollHelper.findFirstError(formKey!.currentContext);
    expect(errorDetail, equals('GV-nummer is verplicht voor aardgas'));
  });
}
