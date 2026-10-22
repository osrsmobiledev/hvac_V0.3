import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/core/database/app_database.dart';
import 'package:hvac_app/features/certificate_draft/data/draft_repository.dart';
import 'package:hvac_app/features/certificate_draft/data/technician_profile_repository.dart';
import 'package:hvac_app/features/certificate_draft/domain/technician_profile.dart';
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

      // Verify Company Labels
      expect(find.text('Naam:'), findsOneWidget);
      expect(find.text('Straat:'), findsOneWidget);
      expect(find.text('Nr:'), findsOneWidget);
      expect(find.text('Postnummer:'), findsOneWidget);
      expect(find.text('Gemeente:'), findsOneWidget);
      expect(find.text('Tel:'), findsOneWidget);
      expect(find.text('Email:'), findsOneWidget);
      expect(find.text('Ondernemingsnummer (KBO):'), findsOneWidget);

      // Verify Technician Labels
      expect(find.text('Voornaam:'), findsOneWidget);
      expect(find.text('Achternaam:'), findsOneWidget);
      expect(find.text('GV-nummer:'), findsOneWidget);
      expect(find.text('TV-nummer:'), findsOneWidget);

      // Verify Visit Timings Labels
      expect(find.text('Datum onderhoud:'), findsOneWidget);
      expect(find.text('Arbeidsduur van:'), findsOneWidget);
      expect(find.text('tot:'), findsOneWidget);
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
            technicianFirstName: 'Pieter',
            technicianLastName: 'Claes',
            gvNumber: 'GV99999',
          ),
        );
      });

      await pumpTab(tester);

      expect(find.text('Pre-existing HVAC'), findsOneWidget);
      expect(find.text('Pieter'), findsOneWidget);
      expect(find.text('Claes'), findsOneWidget);
      expect(find.text('GV99999'), findsOneWidget);
    });
  });
}
