import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/localization/email_delivery_dictionary.dart';
import 'package:hvac_app/features/email_delivery/ui/customer_recipient_card.dart';
import 'package:hvac_app/features/email_delivery/ui/email_custom_note_input.dart';
import 'package:hvac_app/features/email_delivery/ui/email_recipient_dialog.dart';
import 'package:hvac_app/features/pdf_export/data/pdf_visit_data.dart';

void main() {
  group('EmailRecipientDialog Note Gating & Negative Tests', () {
    testWidgets(
        'captures custom note on confirm when customer email is present',
        (tester) async {
      RecipientDialogResult? dialogResult;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  dialogResult = await EmailRecipientDialog.show(
                    context,
                    snapshot: const PdfVisitData(
                      klantVoornaam: 'Els',
                      klantAchternaam: 'De Smet',
                      klantEmail: 'els@desmet.be',
                    ),
                    defaultCopyTechnician: false,
                    technicianEmail: '',
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Expand note field
      expect(find.text(EmailDeliveryDictionary.emailNoteActionAdd),
          findsOneWidget);
      await tester.tap(find.text(EmailDeliveryDictionary.emailNoteActionAdd));
      await tester.pumpAndSettle();

      // Enter note
      await tester.enterText(
          find.byType(TextField), 'Branderdichting volgend jaar nakijken.');
      await tester.pumpAndSettle();

      // Tap Voltooien & E-mailen
      await tester
          .tap(find.text(EmailDeliveryDictionary.finalizeAndEmailAction));
      await tester.pumpAndSettle();

      expect(dialogResult, isNotNull);
      expect(dialogResult!.isQueue, isTrue);
      expect(dialogResult!.confirmation!.customNote,
          equals('Branderdichting volgend jaar nakijken.'));
    });

    testWidgets('hides note field completely when customer has no email',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  await EmailRecipientDialog.show(
                    context,
                    snapshot: const PdfVisitData(
                      klantVoornaam: 'Jan',
                      klantAchternaam: 'Janssens',
                      klantEmail: '',
                    ),
                    defaultCopyTechnician: true,
                    technicianEmail: 'tech@firma.be',
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Customer note input should NOT be in the tree at all
      expect(find.byType(EmailCustomNoteInput), findsNothing);
      expect(
          find.text(EmailDeliveryDictionary.emailNoteActionAdd), findsNothing);
      expect(find.text(EmailDeliveryDictionary.recipientNoCustomerEmail),
          findsOneWidget);
    });

    testWidgets(
        'hides note field and clears note when customer checkbox is toggled off',
        (tester) async {
      RecipientDialogResult? dialogResult;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  dialogResult = await EmailRecipientDialog.show(
                    context,
                    snapshot: const PdfVisitData(
                      klantVoornaam: 'Els',
                      klantAchternaam: 'De Smet',
                      klantEmail: 'els@desmet.be',
                    ),
                    defaultCopyTechnician: true,
                    technicianEmail: 'tech@firma.be',
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Note input initially visible
      expect(find.text(EmailDeliveryDictionary.emailNoteActionAdd),
          findsOneWidget);

      // Expand and enter note
      await tester.tap(find.text(EmailDeliveryDictionary.emailNoteActionAdd));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Test opmerking');
      await tester.pumpAndSettle();

      // Uncheck customer checkbox
      final customerCheckbox = find.descendant(
        of: find.byType(CustomerRecipientCard),
        matching: find.byType(Checkbox),
      );
      await tester.tap(customerCheckbox);
      await tester.pumpAndSettle();

      // Note input is now hidden from the tree
      expect(find.byType(EmailCustomNoteInput), findsNothing);

      // Confirm with only technician copy
      await tester.tap(
          find.text(EmailDeliveryDictionary.finalizeTechnicianCopyOnlyAction));
      await tester.pumpAndSettle();

      expect(dialogResult, isNotNull);
      expect(dialogResult!.isQueue, isTrue);
      expect(dialogResult!.confirmation!.sendToCustomer, isFalse);
      expect(dialogResult!.confirmation!.sendToTechnician, isTrue);
      // Invariant: customNote must be null because customer was unchecked
      expect(dialogResult!.confirmation!.customNote, isNull);
    });
  });
}
