import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/localization/email_delivery_dictionary.dart';
import 'package:hvac_app/core/widgets/tactical_dialog_window.dart';
import 'package:hvac_app/features/email_delivery/ui/customer_recipient_card.dart';
import 'package:hvac_app/features/email_delivery/ui/email_recipient_dialog.dart';
import 'package:hvac_app/features/email_delivery/ui/technician_recipient_card.dart';
import 'package:hvac_app/features/pdf_export/data/pdf_visit_data.dart';

void main() {
  group('EmailRecipientDialog Tactical Window Tests', () {
    testWidgets('renders tactical window with laser divider and title',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => EmailRecipientDialog.show(
                  context,
                  snapshot: const PdfVisitData(
                    klantVoornaam: 'Jan',
                    klantAchternaam: 'Janssens',
                    klantEmail: 'jan@example.com',
                  ),
                  defaultCopyTechnician: true,
                  technicianEmail: 'tech@firma.be',
                ),
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.byType(TacticalDialogWindow), findsOneWidget);
      expect(find.byType(TacticalLaserDivider), findsOneWidget);
      expect(find.text(EmailDeliveryDictionary.recipientDialogTitle),
          findsOneWidget);
      expect(find.byType(CustomerRecipientCard), findsOneWidget);
      expect(find.byType(TechnicianRecipientCard), findsOneWidget);
      expect(find.text('Klant: Jan Janssens'), findsOneWidget);
      expect(find.text('jan@example.com'), findsOneWidget);
      expect(find.text('tech@firma.be'), findsOneWidget);
    });

    testWidgets('enables confirm button when snapshot has customer email',
        (tester) async {
      RecipientDialogResult? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await EmailRecipientDialog.show(
                    context,
                    snapshot: const PdfVisitData(
                      klantVoornaam: 'Jan',
                      klantAchternaam: 'Janssens',
                      klantEmail: 'jan@example.com',
                    ),
                    defaultCopyTechnician: false,
                    technicianEmail: '',
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Klant: Jan Janssens'), findsOneWidget);
      expect(find.text('jan@example.com'), findsOneWidget);

      final confirmButtonFinder = find.widgetWithText(
        FilledButton,
        EmailDeliveryDictionary.finalizeAndEmailAction,
      );
      expect(confirmButtonFinder, findsOneWidget);

      await tester.tap(confirmButtonFinder);
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!.isQueue, isTrue);
      expect(result!.confirmation?.customerEmail, 'jan@example.com');
      expect(result!.confirmation?.sendToCustomer, isTrue);
      expect(result!.confirmation?.sendToTechnician, isFalse);
    });

    testWidgets(
        'shows Kopie naar technicus when customer email missing but technician email configured',
        (tester) async {
      RecipientDialogResult? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await EmailRecipientDialog.show(
                    context,
                    snapshot: const PdfVisitData(
                      klantVoornaam: 'Pieter',
                      klantAchternaam: 'Peeters',
                      klantEmail: '',
                    ),
                    defaultCopyTechnician: true,
                    technicianEmail: 'tech@firma.be',
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text(EmailDeliveryDictionary.recipientNoCustomerEmail),
          findsOneWidget);
      expect(find.text(EmailDeliveryDictionary.recipientPaperNotice),
          findsOneWidget);

      final techButtonFinder = find.widgetWithText(
        FilledButton,
        EmailDeliveryDictionary.finalizeTechnicianCopyOnlyAction,
      );
      expect(techButtonFinder, findsOneWidget);

      await tester.tap(techButtonFinder);
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!.isQueue, isTrue);
      expect(result!.confirmation?.sendToCustomer, isFalse);
      expect(result!.confirmation?.sendToTechnician, isTrue);
      expect(result!.confirmation?.technicianEmail, 'tech@firma.be');
    });

    testWidgets('tapping Alleen bewaren returns skip result', (tester) async {
      RecipientDialogResult? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await EmailRecipientDialog.show(
                    context,
                    snapshot: const PdfVisitData(klantVoornaam: 'Klant Zonder'),
                    defaultCopyTechnician: false,
                    technicianEmail: '',
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      final skipFinder =
          find.text(EmailDeliveryDictionary.finalizeOnlySaveAction);
      expect(skipFinder, findsOneWidget);
      await tester.tap(skipFinder);
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!.isSkip, isTrue);
      expect(result!.isCancel, isFalse);
    });

    testWidgets('tapping Annuleren returns cancel result', (tester) async {
      RecipientDialogResult? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await EmailRecipientDialog.show(
                    context,
                    snapshot: const PdfVisitData(klantVoornaam: 'Klant Zonder'),
                    defaultCopyTechnician: false,
                    technicianEmail: '',
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      final cancelFinder =
          find.text(EmailDeliveryDictionary.recipientDialogAbort);
      expect(cancelFinder, findsOneWidget);
      await tester.tap(cancelFinder);
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!.isCancel, isTrue);
      expect(result!.isQueue, isFalse);
    });
  });
}
