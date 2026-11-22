import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/localization/email_delivery_dictionary.dart';
import 'package:hvac_app/features/email_delivery/ui/email_recovery_dialogs.dart';

void main() {
  group('EmailRecoveryDialogs Tests', () {
    testWidgets(
        'Address correction rejects invalid email and returns valid email',
        (tester) async {
      String? returnedEmail;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                returnedEmail =
                    await EmailRecoveryDialogs.showAddressCorrection(
                  context,
                  currentEmail: 'bad-email',
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Attempt to submit bad email
      await tester.tap(find.text(EmailDeliveryDictionary.correctEmailConfirm));
      await tester.pumpAndSettle();

      expect(find.text(EmailDeliveryDictionary.correctEmailInvalid),
          findsOneWidget);
      expect(returnedEmail, isNull);

      // Enter valid email
      await tester.enterText(find.byType(TextField), 'goed@example.com');
      await tester.pumpAndSettle();

      await tester.tap(find.text(EmailDeliveryDictionary.correctEmailConfirm));
      await tester.pumpAndSettle();

      expect(returnedEmail, 'goed@example.com');
    });

    testWidgets(
        'Uncertain retry confirmation returns true on confirm and false on cancel',
        (tester) async {
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result =
                    await EmailRecoveryDialogs.showUncertainRetryConfirmation(
                        context);
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      // 1. Cancel
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(EmailDeliveryDictionary.uncertainRetryCancel));
      await tester.pumpAndSettle();
      expect(result, isFalse);

      // 2. Confirm
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester
          .tap(find.text(EmailDeliveryDictionary.uncertainRetryConfirm));
      await tester.pumpAndSettle();
      expect(result, isTrue);
    });

    testWidgets(
        'Manual resolution requires non-empty explanation and disables confirm button when empty',
        (tester) async {
      String? resultNotes;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                resultNotes =
                    await EmailRecoveryDialogs.showManualResolution(context);
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final confirmBtnFinder = find.widgetWithText(
        FilledButton,
        EmailDeliveryDictionary.manualResolveConfirm,
      );

      // Button is initially disabled because input is empty
      expect(
        tester.widget<FilledButton>(confirmBtnFinder).onPressed,
        isNull,
      );

      // Entering spaces only keeps button disabled
      await tester.enterText(find.byType(TextField), '   ');
      await tester.pumpAndSettle();
      expect(
        tester.widget<FilledButton>(confirmBtnFinder).onPressed,
        isNull,
      );

      // Entering non-empty explanation enables confirm button
      await tester.enterText(
          find.byType(TextField), 'Afgedrukt attest meegegeven aan bewoner');
      await tester.pumpAndSettle();

      expect(
        tester.widget<FilledButton>(confirmBtnFinder).onPressed,
        isNotNull,
      );

      await tester.tap(confirmBtnFinder);
      await tester.pumpAndSettle();

      expect(resultNotes, 'Afgedrukt attest meegegeven aan bewoner');
    });
  });
}
