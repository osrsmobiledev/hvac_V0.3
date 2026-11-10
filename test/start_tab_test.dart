import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/core/database/app_database.dart';
import 'package:hvac_app/core/widgets/tactical_group_outline.dart';
import 'package:hvac_app/features/certificate_draft/data/draft_repository.dart';
import 'package:hvac_app/features/certificate_draft/domain/draft_visit.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/start/activity_option_tile.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/start_tab.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late DraftRepository repository;

  setUp(() async {
    db = await AppDatabase.instance.initDatabase(
      customPath: inMemoryDatabasePath,
    );
    AppDatabase.instance.setDatabaseForTesting(db);
    repository = DraftRepository();
  });

  tearDown(() async {
    await AppDatabase.instance.close();
  });

  Widget buildTestWidget() {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(
        body: StartTab(draftRepository: repository),
      ),
    );
  }

  Future<void> pumpStartTab(WidgetTester tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pump();
  }

  group('Slice 2.2 — Tab 2 (Start) UI & SQLite Auto-Save', () {
    testWidgets(
        'Renders Start tab form with activity options and sequence number field',
        (tester) async {
      await pumpStartTab(tester);

      // Verify Main Gold Dropdown Header
      expect(find.text(AppDictionary.headerActivity), findsOneWidget);

      // Verify Side-by-side Option Buttons
      expect(
          find.widgetWithText(ActivityOptionTile, 'Onderhoud'), findsOneWidget);
      expect(
          find.widgetWithText(ActivityOptionTile, 'Keuring'), findsOneWidget);

      // Verify Caption under Keuring button
      expect(find.text(AppDictionary.captionCommissioning), findsOneWidget);

      // Verify Sequence Number Field (no trailing colon)
      expect(find.text(AppDictionary.lblSequenceNumber), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets(
        'Tapping commissioning inspection updates selection and persists to SQLite',
        (tester) async {
      await pumpStartTab(tester);

      // Tap 'Keuring' button
      await tester.tap(find.widgetWithText(ActivityOptionTile, 'Keuring'));
      late DraftVisit draft;
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        draft = await repository.getOrCreateActiveDraft();
      });
      await tester.pump();

      // Verify in SQLite database
      expect(draft.activityType, equals('eerste_ingebruikname'));
    });

    testWidgets(
        'Starts un-selected, tapping selects it, tapping again de-selects it',
        (tester) async {
      await pumpStartTab(tester);

      // Default is un-selected ('')
      late DraftVisit draft;
      await tester.runAsync(() async {
        draft = await repository.getOrCreateActiveDraft();
      });
      expect(draft.activityType, equals(''));

      // Tapping 'Onderhoud' selects it
      final onderhoudButton =
          find.widgetWithText(ActivityOptionTile, 'Onderhoud');
      await tester.tap(onderhoudButton);
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        draft = await repository.getOrCreateActiveDraft();
      });
      await tester.pump();

      expect(draft.activityType, equals('onderhoud'));

      // Tapping again de-selects it back to ''
      await tester.tap(onderhoudButton);
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        draft = await repository.getOrCreateActiveDraft();
      });
      await tester.pump();

      expect(draft.activityType, equals(''));
    });

    testWidgets(
        'Entering sequence number debounces and persists to SQLite draft',
        (tester) async {
      await pumpStartTab(tester);

      // Enter sequence number
      await tester.enterText(find.byType(TextField), 'ATTEST-2026-999');
      // Wait for debounce timer (300ms) to trigger auto-save
      await tester.pump(const Duration(milliseconds: 350));
      late DraftVisit draft;
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        draft = await repository.getOrCreateActiveDraft();
      });

      // Verify in SQLite database
      expect(draft.attestNumber, equals('ATTEST-2026-999'));
    });

    testWidgets('Reloading Start tab restores entered data from SQLite',
        (tester) async {
      // Pre-populate draft in SQLite
      await tester.runAsync(() async {
        final initialDraft = await repository.getOrCreateActiveDraft();
        await repository.updateStartTabDraft(
          visitId: initialDraft.id,
          activityType: 'eerste_ingebruikname',
          attestNumber: 'SAVED-DRAFT-123',
        );
      });

      // Render fresh widget
      await pumpStartTab(tester);

      // Verify restored in form
      expect(find.text('SAVED-DRAFT-123'), findsOneWidget);
      late DraftVisit draft;
      await tester.runAsync(() async {
        draft = await repository.getOrCreateActiveDraft();
      });
      expect(draft.activityType, equals('eerste_ingebruikname'));
    });

    testWidgets(
        'On narrow S23 phone (360dp width), activity options render on one line without overflow',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await pumpStartTab(tester);

      expect(tester.takeException(), isNull);
      expect(
        find.widgetWithText(
            ActivityOptionTile, AppDictionary.activityMaintenance),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(
          ActivityOptionTile,
          AppDictionary.activityCommissioningShort,
        ),
        findsOneWidget,
      );

      // Verify the button text widget has maxLines: 1
      final textFinder = find.descendant(
        of: find.widgetWithText(
          ActivityOptionTile,
          AppDictionary.activityCommissioningShort,
        ),
        matching: find.text(AppDictionary.activityCommissioningShort),
      );
      final textWidget = tester.widget<Text>(textFinder);
      expect(textWidget.maxLines, equals(1));
    });

    testWidgets(
        'Submitting sequence number immediately saves without waiting for debounce',
        (tester) async {
      await pumpStartTab(tester);

      // Enter text and immediately submit (tap Done on keyboard)
      await tester.enterText(find.byType(TextField), 'IMMEDIATE-777');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      late DraftVisit draft;
      await tester.runAsync(() async {
        draft = await repository.getOrCreateActiveDraft();
      });

      // Should be saved immediately without 300ms wait
      expect(draft.attestNumber, equals('IMMEDIATE-777'));
    });

    testWidgets('Disposing StartTab flushes pending debounce input to SQLite',
        (tester) async {
      await pumpStartTab(tester);

      // Enter text (triggers 300ms timer)
      await tester.enterText(find.byType(TextField), 'FLUSH-ON-DISPOSE');

      // Immediately unmount/replace widget BEFORE debounce expires (only 50ms)
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpWidget(const SizedBox.shrink());

      late DraftVisit draft;
      await tester.runAsync(() async {
        draft = await repository.getOrCreateActiveDraft();
      });

      // Flushed to database during dispose
      expect(draft.attestNumber, equals('FLUSH-ON-DISPOSE'));
    });

    testWidgets(
        'onFormKeyReady exposes formKey and validate() checks required fields',
        (tester) async {
      GlobalKey<FormState>? formKey;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: StartTab(
              draftRepository: repository,
              onFormKeyReady: (key) => formKey = key,
            ),
          ),
        ),
      );
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      await tester.pump();

      expect(formKey, isNotNull);
      // Empty fields -> validate() fails
      expect(formKey!.currentState!.validate(), isFalse);
      await tester.pumpAndSettle();

      // Zero error text rendered on screen
      expect(
        find.text(
            'Kies een activiteitstype (Onderhoud of Eerste ingebruikname)'),
        findsNothing,
      );
      expect(find.text('Volgnummer attest is verplicht'), findsNothing);

      // Verify unified TacticalGroupOutline has red border outlining both activity options
      final groupOutline = tester.widget<TacticalGroupOutline>(
        find.byType(TacticalGroupOutline),
      );
      expect(groupOutline.hasError, isTrue);

      final groupContainer = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(TacticalGroupOutline),
              matching: find.byType(Container),
            )
            .first,
      );
      final border = (groupContainer.decoration as BoxDecoration).border;
      expect(border?.top.color, AppColors.errorRed);

      // Verify individual buttons keep resting border (not individual error outlines)
      final activityTiles = tester.widgetList<ActivityOptionTile>(
        find.byType(ActivityOptionTile),
      );
      expect(activityTiles.first.isError, isFalse);
      expect(activityTiles.last.isError, isFalse);

      // Selecting an activity option immediately clears the group error outline
      await tester.tap(find.widgetWithText(ActivityOptionTile, 'Onderhoud'));
      await tester.pump();

      final updatedGroupOutline = tester.widget<TacticalGroupOutline>(
        find.byType(TacticalGroupOutline),
      );
      expect(updatedGroupOutline.hasError, isFalse);

      final updatedContainer = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(TacticalGroupOutline),
              matching: find.byType(Container),
            )
            .first,
      );
      final updatedBorder =
          (updatedContainer.decoration as BoxDecoration).border;
      expect(updatedBorder?.top.color, Colors.transparent);

      // Verify sequence number input box has red border
      final attestTextField = tester.widget<TextField>(find.descendant(
        of: find.byKey(const ValueKey('start_attestNumber')),
        matching: find.byType(TextField),
      ));
      expect(
        (attestTextField.decoration!.enabledBorder as OutlineInputBorder)
            .borderSide
            .color,
        AppColors.errorRed,
      );
    });
  });
}
