// File: test/gebreken_opmerkingen_test.dart
// Responsibility: Unit & widget tests for GebrekenOpmerkingenCard and side-by-side actions.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/app/localization/eindbeoordeling_dictionary.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/eindbeoordeling/gebreken_action_buttons.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/eindbeoordeling/gebreken_opmerkingen_card.dart';

void main() {
  Widget buildCard({
    required TextEditingController defectsController,
    required TextEditingController remarksController,
    bool hasNegativeAssessment = false,
    VoidCallback? onChanged,
  }) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(
        body: SingleChildScrollView(
          child: GebrekenOpmerkingenCard(
            defectsController: defectsController,
            remarksController: remarksController,
            hasNegativeAssessment: hasNegativeAssessment,
            onChanged: onChanged ?? () {},
          ),
        ),
      ),
    );
  }

  group('GebrekenOpmerkingenCard layout and side-by-side positioning', () {
    testWidgets(
        'Renders defect title and SnelselectieButton side by side in a Row',
        (tester) async {
      final defectsController = TextEditingController();
      final remarksController = TextEditingController();
      addTearDown(() {
        defectsController.dispose();
        remarksController.dispose();
      });

      await tester.pumpWidget(buildCard(
        defectsController: defectsController,
        remarksController: remarksController,
      ));
      await tester.pumpAndSettle();

      // Find the defects title text and lightbulb icon
      final titleFinder =
          find.text(EindbeoordelingDictionary.lblGebrekenNietWeggewerkt);
      final lampFinder = find.byType(SnelselectieButton);

      expect(titleFinder, findsOneWidget);
      expect(lampFinder, findsOneWidget);

      // Verify both title and lamp button are children of the same Row (side by side)
      final rowFinder =
          find.ancestor(of: titleFinder, matching: find.byType(Row));
      expect(rowFinder, findsOneWidget);
      expect(
          find.descendant(of: rowFinder, matching: lampFinder), findsOneWidget);

      // Verify horizontal positions: title on the left, lamp icon on the right
      final titleTopLeft = tester.getTopLeft(titleFinder);
      final lampTopLeft = tester.getTopLeft(lampFinder);
      expect(lampTopLeft.dx, greaterThan(titleTopLeft.dx));
    });

    testWidgets('Tapping SnelselectieButton opens bottom sheet modal',
        (tester) async {
      final defectsController = TextEditingController();
      final remarksController = TextEditingController();
      addTearDown(() {
        defectsController.dispose();
        remarksController.dispose();
      });

      await tester.pumpWidget(buildCard(
        defectsController: defectsController,
        remarksController: remarksController,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(SnelselectieButton));
      await tester.pumpAndSettle();

      // Modal title is displayed
      expect(find.text(EindbeoordelingDictionary.modalTitleSnelselectie),
          findsOneWidget);
    });

    testWidgets(
        'Embedded clear button appears in top-right of input box when text is entered',
        (tester) async {
      final defectsController = TextEditingController();
      final remarksController = TextEditingController();
      addTearDown(() {
        defectsController.dispose();
        remarksController.dispose();
      });

      await tester.pumpWidget(buildCard(
        defectsController: defectsController,
        remarksController: remarksController,
      ));
      await tester.pumpAndSettle();

      // Initially no clear button inside the defects multiline input
      final closeFinder = find.byTooltip(EindbeoordelingDictionary.btnWissen);
      expect(closeFinder, findsNothing);

      // Type defect text
      defectsController.text = 'Defect item 1';
      await tester.pumpAndSettle();

      // TacticalSquareButton with close icon appears inside the input box
      expect(closeFinder, findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);

      // Verify the delete button is embedded inside TacticalMultilineInput Stack
      final inputFinder = find.ancestor(
          of: closeFinder, matching: find.byType(TacticalMultilineInput));
      expect(inputFinder, findsOneWidget);
    });
  });
}
