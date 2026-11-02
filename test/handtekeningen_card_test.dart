// File: test/handtekeningen_card_test.dart
// Responsibility: Unit & widget tests for HandtekeningenCard confirmation dialog on delete.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/app/localization/eindbeoordeling_dictionary.dart';
import 'package:hvac_app/core/widgets/tactical_confirm_dialog.dart';
import 'package:hvac_app/core/widgets/tactical_square_button.dart';
import 'package:hvac_app/features/certificate_draft/domain/eindbeoordeling_draft.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/eindbeoordeling/handtekeningen_card.dart';

void main() {
  Widget buildTestWidget({
    required EindbeoordelingDraft draft,
    required ValueChanged<EindbeoordelingDraft> onDraftChanged,
  }) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(
        body: SingleChildScrollView(
          child: HandtekeningenCard(
            draft: draft,
            onDraftChanged: onDraftChanged,
          ),
        ),
      ),
    );
  }

  group('HandtekeningenCard confirmation dialog on delete', () {
    testWidgets('Tapping delete on signature pops up confirmation dialog',
        (tester) async {
      EindbeoordelingDraft currentDraft = const EindbeoordelingDraft(
        technicianSignaturePath: 'data:image/png;base64,fakeSignature',
      );

      await tester.pumpWidget(buildTestWidget(
        draft: currentDraft,
        onDraftChanged: (d) => currentDraft = d,
      ));
      await tester.pumpAndSettle();

      // Find the delete button [X] on the technician signature tile
      final deleteBtn = find.byType(TacticalSquareButton);
      expect(deleteBtn, findsOneWidget);

      // Tap the delete button
      await tester.tap(deleteBtn);
      await tester.pumpAndSettle();

      // Confirmation dialog pops up
      expect(find.byType(TacticalConfirmDialog), findsOneWidget);
      expect(
        find.text(EindbeoordelingDictionary.dlgClearTechnicianSignatureTitle),
        findsOneWidget,
      );
      expect(
        find.text(EindbeoordelingDictionary.dlgClearSignatureBody),
        findsOneWidget,
      );

      // Tap cancel (Annuleren) -> Dialog closes and signature is preserved
      await tester.tap(find.text(EindbeoordelingDictionary.btnAnnuleren));
      await tester.pumpAndSettle();

      expect(find.byType(TacticalConfirmDialog), findsNothing);
      expect(currentDraft.technicianSignaturePath, isNotNull);

      // Tap delete again and confirm (Wissen)
      await tester.tap(deleteBtn);
      await tester.pumpAndSettle();

      await tester.tap(find.text(EindbeoordelingDictionary.btnWissen));
      await tester.pumpAndSettle();

      // Draft was updated with cleared signature
      expect(currentDraft.technicianSignaturePath, isNull);
    });
  });
}
