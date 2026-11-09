import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/core/database/app_database.dart';
import 'package:hvac_app/features/certificate_draft/data/draft_repository.dart';
import 'package:hvac_app/features/certificate_draft/data/technician_profile_repository.dart';
import 'package:hvac_app/features/certificate_draft/domain/technician_profile.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/firma_technicus/technician_section.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/firma_technicus_tab.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late TechnicianProfileRepository profileRepository;
  late DraftRepository draftRepository;

  setUp(() async {
    db = await AppDatabase.instance.initDatabase(
      customPath: inMemoryDatabasePath,
    );
    AppDatabase.instance.setDatabaseForTesting(db);
    profileRepository = TechnicianProfileRepository();
    draftRepository = DraftRepository();
  });

  tearDown(() async {
    await AppDatabase.instance.close();
  });

  Widget buildTestWidget() {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(
        body: FirmaTechnicusTab(
          profileRepository: profileRepository,
          draftRepository: draftRepository,
        ),
      ),
    );
  }

  Future<void> pumpTab(WidgetTester tester) async {
    tester.view.physicalSize = const Size(412, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildTestWidget());
    for (int i = 0; i < 20; i++) {
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 30));
      });
      await tester.pump();
      if (find.byType(CircularProgressIndicator).evaluate().isEmpty) {
        break;
      }
    }
  }

  group('Slice 2.3 — Tab 3 (Firma - Technicus) UI & Persistence', () {
    testWidgets('Renders Firma and Technicus sections with all core inputs',
        (tester) async {
      await pumpTab(tester);

      // Verify Main Section Titles
      expect(find.text('Firma'), findsOneWidget);
      expect(find.text('Technicus'), findsOneWidget);

      // Verify Company Labels (matching Klant standard)
      expect(find.text(AppDictionary.lblCompanyName), findsOneWidget);
      expect(find.text(AppDictionary.lblStreet), findsOneWidget);
      expect(find.text(AppDictionary.lblHouseNumber), findsOneWidget);
      expect(find.text(AppDictionary.lblBox), findsOneWidget);
      expect(find.text(AppDictionary.lblPostalCode), findsOneWidget);
      expect(find.text(AppDictionary.lblCity), findsOneWidget);
      expect(find.text(AppDictionary.lblPhone), findsOneWidget);
      expect(find.text(AppDictionary.lblEmail), findsOneWidget);
      expect(find.text(AppDictionary.lblKBO), findsOneWidget);

      // Verify Technician Labels (no trailing colons)
      expect(find.text(AppDictionary.lblFirstName), findsOneWidget);
      expect(find.text(AppDictionary.lblLastName), findsOneWidget);
      expect(find.text(AppDictionary.lblGV), findsOneWidget);
      expect(find.text(AppDictionary.lblTV), findsOneWidget);

      // Verify Visit Timings Labels (no trailing colons)
      expect(find.text(AppDictionary.lblDate), findsOneWidget);
      expect(find.text(AppDictionary.lblTimeFrom), findsOneWidget);
      expect(find.text(AppDictionary.lblTimeTo), findsOneWidget);

      // Verify Date and Time input fields have centered text alignment
      final dateField = tester
          .widget<TextField>(find.widgetWithText(TextField, 'JJJJ-MM-DD'));
      expect(dateField.textAlign, equals(TextAlign.center));

      final startTimeField =
          tester.widget<TextField>(find.widgetWithText(TextField, '08:00'));
      expect(startTimeField.textAlign, equals(TextAlign.center));

      final endTimeField =
          tester.widget<TextField>(find.widgetWithText(TextField, '10:00'));
      expect(endTimeField.textAlign, equals(TextAlign.center));
    });

    testWidgets(
        'Editing company name debounces and persists to technician_profile',
        (tester) async {
      await pumpTab(tester);

      // Enter company name
      final nameField = find.widgetWithText(TextField, 'bv. HVAC Solutions BV');
      await tester.enterText(nameField, 'Klimaat Pro BV');
      await tester.pump(const Duration(milliseconds: 350));

      late TechnicianProfile profile;
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        profile = await profileRepository.getProfile();
      });

      expect(profile.companyName, equals('Klimaat Pro BV'));
    });

    testWidgets(
        'Tapping time field launches BO2 Time Spinner with Dutch labels',
        (tester) async {
      await pumpTab(tester);

      // Scroll to 'Arbeidsduur van'
      final timeField = find.widgetWithText(TextField, '08:00');
      await tester.ensureVisible(timeField);
      await tester.pumpAndSettle();

      await tester.tap(timeField);
      await tester.pumpAndSettle();

      // Verify BO2 Time Spinner Header & Dutch labels
      expect(find.text('Tijd instellen'), findsOneWidget);
      expect(find.text('UREN'), findsOneWidget);
      expect(find.text('MINUTEN'), findsOneWidget);
      expect(find.text('Annuleren'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);

      // Tap OK
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Spinner should dismiss
      expect(find.text('Tijd instellen'), findsNothing);
    });

    testWidgets('Pre-populated profile is restored in form fields',
        (tester) async {
      await tester.runAsync(() async {
        await profileRepository.saveProfile(
          const TechnicianProfile(
            companyName: 'Pre-existing HVAC',
            boxNumber: 'Bus 4B',
            technicianFirstName: 'Pieter',
            technicianLastName: 'Claes',
            gvNumber: 'GV99999',
          ),
        );
      });

      await pumpTab(tester);

      expect(find.text('Pre-existing HVAC'), findsOneWidget);
      expect(find.text('Bus 4B'), findsOneWidget);
      expect(find.text('Pieter'), findsOneWidget);
      expect(find.text('Claes'), findsOneWidget);
      expect(find.text('GV99999'), findsOneWidget);
    });

    testWidgets(
        'Disposing FirmaTechnicusTab flushes pending debounced profile to SQLite',
        (tester) async {
      await pumpTab(tester);

      // Enter company name (triggers 300ms debounce timer)
      final nameField = find.widgetWithText(TextField, 'bv. HVAC Solutions BV');
      await tester.enterText(nameField, 'Emergency Flush BV');

      // Unmount before 300ms expires (e.g. after 50ms)
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpWidget(const SizedBox.shrink());

      late TechnicianProfile profile;
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        profile = await profileRepository.getProfile();
      });

      // Profile was saved during dispose!
      expect(profile.companyName, equals('Emergency Flush BV'));
    });

    testWidgets(
        'onFormKeyReady exposes formKey and validate() checks required fields',
        (tester) async {
      GlobalKey<FormState>? formKey;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: FirmaTechnicusTab(
              profileRepository: profileRepository,
              draftRepository: draftRepository,
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
      // Empty fields -> validate() fails
      expect(formKey!.currentState!.validate(), isFalse);
      await tester.pumpAndSettle();

      // Verify fields highlight red border and NO text underneath
      final firstNameField = tester.widget<TextField>(find.descendant(
        of: find.byKey(const ValueKey('technician_firstName')),
        matching: find.byType(TextField),
      ));
      expect(
        (firstNameField.decoration!.enabledBorder as OutlineInputBorder)
            .borderSide
            .color,
        AppColors.errorRed,
      );
      expect(find.text('Naam firma is verplicht'), findsNothing);
      expect(find.text('Voornaam is verplicht'), findsNothing);
      expect(find.text('GV-nummer vereist'), findsNothing);
    });

    testWidgets(
        'Phone field is optional when empty but validates strictly when entered',
        (tester) async {
      await pumpTab(tester);

      final phoneFinder = find.byKey(const ValueKey('company_phone'));
      expect(phoneFinder, findsOneWidget);

      // Empty phone does not show any error
      expect(
        find.text('Ongeldig telefoonnummer (bv. 470 12 34 56)'),
        findsNothing,
      );

      // Enter invalid phone (8 digits starting with 4)
      await tester.enterText(phoneFinder, '47012345');
      await tester.pumpAndSettle();
      final phoneFieldInvalid = tester.widget<TextField>(find.descendant(
        of: phoneFinder,
        matching: find.byType(TextField),
      ));
      expect(
        (phoneFieldInvalid.decoration!.enabledBorder as OutlineInputBorder)
            .borderSide
            .color,
        AppColors.errorRed,
      );
      expect(
        find.text('Ongeldig telefoonnummer (bv. 470 12 34 56)'),
        findsNothing,
      );

      // Complete to valid 9 digits
      await tester.enterText(phoneFinder, '470123456');
      await tester.pumpAndSettle();
      final phoneFieldValid = tester.widget<TextField>(find.descendant(
        of: phoneFinder,
        matching: find.byType(TextField),
      ));
      expect(
        (phoneFieldValid.decoration!.enabledBorder as OutlineInputBorder)
            .borderSide
            .color,
        isNot(AppColors.errorRed),
      );

      // Clearing back to empty removes error
      await tester.enterText(phoneFinder, '');
      await tester.pumpAndSettle();
      final phoneFieldEmpty = tester.widget<TextField>(find.descendant(
        of: phoneFinder,
        matching: find.byType(TextField),
      ));
      expect(
        (phoneFieldEmpty.decoration!.enabledBorder as OutlineInputBorder)
            .borderSide
            .color,
        isNot(AppColors.errorRed),
      );

      // Let debounce timer and async persistence complete cleanly
      await tester.pump(const Duration(milliseconds: 350));
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
    });

    testWidgets(
        'Typing in GV immediately clears TV validation error and vice-versa',
        (tester) async {
      await pumpTab(tester);

      // Validate form to trigger initial errors
      final form = tester.widget<Form>(find.byType(Form));
      (form.key as GlobalKey<FormState>).currentState!.validate();
      await tester.pumpAndSettle();

      final tvFinder = find.descendant(
        of: find.byType(TechnicianSection),
        matching: find.widgetWithText(TextField, 'TV01234'),
      );
      final gvFinder = find.descendant(
        of: find.byType(TechnicianSection),
        matching: find.widgetWithText(TextField, 'GV01234'),
      );
      expect(
        (tester.widget<TextField>(tvFinder).decoration!.enabledBorder
                as OutlineInputBorder)
            .borderSide
            .color,
        AppColors.errorRed,
      );
      expect(
        (tester.widget<TextField>(gvFinder).decoration!.enabledBorder
                as OutlineInputBorder)
            .borderSide
            .color,
        AppColors.errorRed,
      );
      expect(find.text('GV-nummer vereist'), findsNothing);

      // Typing into GV immediately clears both errors
      await tester.enterText(gvFinder, 'GV98765');
      await tester.pumpAndSettle();

      expect(
        (tester.widget<TextField>(tvFinder).decoration!.enabledBorder
                as OutlineInputBorder)
            .borderSide
            .color,
        isNot(AppColors.errorRed),
      );
      expect(
        (tester
                .widget<TextField>(find.widgetWithText(TextField, 'GV98765'))
                .decoration!
                .enabledBorder as OutlineInputBorder)
            .borderSide
            .color,
        isNot(AppColors.errorRed),
      );

      // Clearing GV brings both errors back
      await tester.enterText(find.widgetWithText(TextField, 'GV98765'), '');
      await tester.pumpAndSettle();

      expect(
        (tester.widget<TextField>(tvFinder).decoration!.enabledBorder
                as OutlineInputBorder)
            .borderSide
            .color,
        AppColors.errorRed,
      );

      // Let debounce timer complete
      await tester.pump(const Duration(milliseconds: 350));
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
    });

    testWidgets('Voornaam and Achternaam auto-capitalize words in real time',
        (tester) async {
      await pumpTab(tester);

      final firstNameFinder = find.widgetWithText(TextField, 'bv. Jan');
      await tester.enterText(firstNameFinder, 'jan-pieter');
      await tester.pumpAndSettle();
      expect(find.text('Jan-Pieter'), findsOneWidget);

      final lastNameFinder = find.widgetWithText(TextField, 'bv. Janssens');
      await tester.enterText(lastNameFinder, 'van den berg');
      await tester.pumpAndSettle();
      expect(find.text('Van Den Berg'), findsOneWidget);

      // Let debounce timer complete
      await tester.pump(const Duration(milliseconds: 350));
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
    });

    testWidgets('Arbeidsduur van and tot validate presence and time order',
        (tester) async {
      GlobalKey<FormState>? formKey;
      tester.view.physicalSize = const Size(412, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: FirmaTechnicusTab(
              profileRepository: profileRepository,
              draftRepository: draftRepository,
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
        if (find.byType(CircularProgressIndicator).evaluate().isEmpty) {
          break;
        }
      }

      expect(formKey, isNotNull);

      // Validate on initially empty draft -> fails validation
      final initialValid = formKey!.currentState!.validate();
      await tester.pumpAndSettle();
      expect(initialValid, isFalse);

      // Error text is suppressed (showErrorText: false), no error text widgets rendered
      expect(find.text('Starttijd is verplicht'), findsNothing);
      expect(find.text('Eindtijd is verplicht'), findsNothing);

      // Find Start Time and End Time fields by their section label
      final startContainer = find.ancestor(
        of: find.text(AppDictionary.lblTimeFrom),
        matching: find.byType(Expanded),
      );
      final startTimeFinder = find.descendant(
        of: startContainer,
        matching: find.byType(TextField),
      );

      final endContainer = find.ancestor(
        of: find.text(AppDictionary.lblTimeTo),
        matching: find.byType(Expanded),
      );
      final endTimeFinder = find.descendant(
        of: endContainer,
        matching: find.byType(TextField),
      );

      expect(startTimeFinder, findsOneWidget);
      expect(endTimeFinder, findsOneWidget);

      final startTextField = tester.widget<TextField>(startTimeFinder);
      final endTextField = tester.widget<TextField>(endTimeFinder);

      // Verify start time field has error border (red border)
      expect(
        (startTextField.decoration!.enabledBorder as OutlineInputBorder)
            .borderSide
            .color,
        AppColors.errorRed,
      );

      // Filling start time enables tot; set both to valid times (08:15 and 10:30)
      startTextField.controller!.text = '08:15';
      endTextField.controller!.text = '10:30';
      await tester.pumpAndSettle();

      formKey!.currentState!.validate();
      await tester.pumpAndSettle();

      expect(
        (tester.widget<TextField>(startTimeFinder).decoration!.enabledBorder
                as OutlineInputBorder)
            .borderSide
            .color,
        isNot(AppColors.errorRed),
      );
      expect(
        (tester.widget<TextField>(endTimeFinder).decoration!.enabledBorder
                as OutlineInputBorder)
            .borderSide
            .color,
        isNot(AppColors.errorRed),
      );

      // Test invalid time order (end <= start)
      endTextField.controller!.text = '07:30';
      await tester.pumpAndSettle();
      formKey!.currentState!.validate();
      await tester.pumpAndSettle();

      expect(
        (tester.widget<TextField>(endTimeFinder).decoration!.enabledBorder
                as OutlineInputBorder)
            .borderSide
            .color,
        AppColors.errorRed,
      );

      // Restoring valid time order clears the red border
      endTextField.controller!.text = '09:00';
      await tester.pumpAndSettle();
      formKey!.currentState!.validate();
      await tester.pumpAndSettle();

      expect(
        (tester.widget<TextField>(endTimeFinder).decoration!.enabledBorder
                as OutlineInputBorder)
            .borderSide
            .color,
        isNot(AppColors.errorRed),
      );
    });
  });
}
