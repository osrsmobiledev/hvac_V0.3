import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/core/database/app_database.dart';
import 'package:hvac_app/features/certificate_draft/data/draft_repository.dart';
import 'package:hvac_app/features/certificate_draft/data/technician_profile_repository.dart';
import 'package:hvac_app/features/certificate_draft/domain/technician_profile.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/firma_technicus_tab.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

part 'firma_technicus_tab_profile_cases.dart';
part 'firma_technicus_tab_input_cases.dart';
part 'firma_technicus_tab_validation_cases.dart';

late Database db;
late TechnicianProfileRepository profileRepository;
late DraftRepository draftRepository;

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

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

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

  group('Slice 2.3 — Tab 3 (Firma - Technicus) UI & Persistence', () {
    _profileTests();
    _inputTests();
    _validationTests();
  });
}
