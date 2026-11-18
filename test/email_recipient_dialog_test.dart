import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/localization/email_delivery_dictionary.dart';
import 'package:hvac_app/features/email_delivery/ui/email_recipient_dialog.dart';
import 'package:hvac_app/features/pdf_export/data/pdf_visit_data.dart';

void main() {
  Widget buildTestApp({
    required PdfVisitData snapshot,
    required bool defaultCopyTechnician,
    required String technicianEmail,
    required ValueChanged<RecipientConfirmation?> onResult,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              final result = await EmailRecipientDialog.show(
                context,
                snapshot: snapshot,
                defaultCopyTechnician: defaultCopyTechnician,
                technicianEmail: technicianEmail,
              );
              onResult(result);
            },
            child: const Text('Open Dialog'),
          ),
        ),
      ),
    );
  }

  const sampleSnapshot = PdfVisitData(
    klantVoornaam: 'Jan',
    klantAchternaam: 'Peeters',
    klantEmail: 'jan@example.com',
  );

  group('EmailRecipientDialog Widget Tests', () {
    testWidgets('renders customer email and technician copy checkbox',
        (tester) async {
      RecipientConfirmation? result;
      await tester.pumpWidget(buildTestApp(
        snapshot: sampleSnapshot,
        defaultCopyTechnician: true,
        technicianEmail: 'tech@example.com',
        onResult: (r) => result = r,
      ));

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text(EmailDeliveryDictionary.recipientDialogTitle),
          findsOneWidget);
      expect(find.text('Jan Peeters'), findsOneWidget);
      expect(find.text('jan@example.com'), findsOneWidget);
      expect(find.text('tech@example.com'), findsOneWidget);
      expect(find.text(EmailDeliveryDictionary.recipientTechnicianLabel),
          findsOneWidget);

      // Confirm with default technician copy checked
      await tester
          .tap(find.text(EmailDeliveryDictionary.recipientDialogConfirm));
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!.sendToCustomer, isTrue);
      expect(result!.customerEmail, equals('jan@example.com'));
      expect(result!.sendToTechnician, isTrue);
      expect(result!.technicianEmail, equals('tech@example.com'));
    });

    testWidgets('tapping Overslaan cancels without confirming', (tester) async {
      RecipientConfirmation? result;
      bool callbackFired = false;
      await tester.pumpWidget(buildTestApp(
        snapshot: sampleSnapshot,
        defaultCopyTechnician: true,
        technicianEmail: 'tech@example.com',
        onResult: (r) {
          result = r;
          callbackFired = true;
        },
      ));

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      await tester
          .tap(find.text(EmailDeliveryDictionary.recipientDialogCancel));
      await tester.pumpAndSettle();

      expect(callbackFired, isTrue);
      expect(result, isNull);
    });

    testWidgets('unchecking technician copy updates confirmation result',
        (tester) async {
      RecipientConfirmation? result;
      await tester.pumpWidget(buildTestApp(
        snapshot: sampleSnapshot,
        defaultCopyTechnician: true,
        technicianEmail: 'tech@example.com',
        onResult: (r) => result = r,
      ));

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Tap the checkbox tile to uncheck technician copy
      await tester
          .tap(find.text(EmailDeliveryDictionary.recipientTechnicianLabel));
      await tester.pumpAndSettle();

      await tester
          .tap(find.text(EmailDeliveryDictionary.recipientDialogConfirm));
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!.sendToCustomer, isTrue);
      expect(result!.sendToTechnician, isFalse);
    });

    testWidgets('shows warning when customer has no email address',
        (tester) async {
      const noEmailSnapshot = PdfVisitData(
        klantVoornaam: 'Klant',
        klantAchternaam: 'ZonderMail',
        klantEmail: '',
      );

      await tester.pumpWidget(buildTestApp(
        snapshot: noEmailSnapshot,
        defaultCopyTechnician: false,
        technicianEmail: '',
        onResult: (_) {},
      ));

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(
        find.text(EmailDeliveryDictionary.recipientNoCustomerEmail),
        findsOneWidget,
      );
      expect(
        find.text(EmailDeliveryDictionary.recipientNoneAvailable),
        findsOneWidget,
      );
    });
  });
}
