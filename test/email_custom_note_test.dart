import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/localization/email_delivery_dictionary.dart';
import 'package:hvac_app/features/email_delivery/data/email_job_models.dart';
import 'package:hvac_app/features/email_delivery/ui/email_custom_note_input.dart';

void main() {
  group('Email Custom Note Dictionary & Model Tests', () {
    test('emailBodyCustomer without note returns standard body', () {
      final body = EmailDeliveryDictionary.emailBodyCustomer('2026-001');
      expect(body, contains('verbrandingsattest'));
      expect(body, contains('2026-001'));
      expect(body, isNot(contains('Opmerking van de technicus')));
    });

    test('emailBodyCustomer with note inserts note neatly', () {
      final body = EmailDeliveryDictionary.emailBodyCustomer(
        '2026-001',
        customNote: 'Factuur volgt later per post.',
      );
      expect(body, contains('Opmerking van de technicus:'));
      expect(body, contains('Factuur volgt later per post.'));
      expect(body, contains('Met vriendelijke groeten'));
    });

    test('emailBodyCustomer with whitespace-only note returns standard body',
        () {
      final body = EmailDeliveryDictionary.emailBodyCustomer(
        '2026-001',
        customNote: '   \n  ',
      );
      expect(body, isNot(contains('Opmerking van de technicus')));
    });

    test('emailBodyTechnicianMessage formats note reference when present', () {
      final withoutNote = EmailDeliveryDictionary.emailBodyTechnicianMessage();
      expect(withoutNote, equals(EmailDeliveryDictionary.emailBodyTechnician));

      final withNote = EmailDeliveryDictionary.emailBodyTechnicianMessage(
        customNote: 'Klant wenst volgend jaar onderhoud in mei.',
      );
      expect(withNote, contains('Kopie verbrandingsattest'));
      expect(withNote, contains('Klant wenst volgend jaar onderhoud in mei.'));
    });

    test('EmailJobSpec.buildJobs preserves custom note in bodyText', () {
      final jobs = EmailJobSpec.buildJobs(
        visitId: 42,
        pdfPath: '/path/test.pdf',
        sendToCustomer: true,
        customerName: 'Jan Peeters',
        customerEmail: 'jan@peeters.be',
        sendToTechnician: true,
        technicianEmail: 'tech@firma.be',
        attestNumber: '2026-042',
        customerNote: 'Gelieve druk in het oog te houden.',
      );

      expect(jobs.length, equals(2));
      final customerJob =
          jobs.firstWhere((j) => j.recipientType == RecipientType.customer);
      final techJob =
          jobs.firstWhere((j) => j.recipientType == RecipientType.technician);

      expect(
          customerJob.bodyText, contains('Gelieve druk in het oog te houden.'));
      expect(techJob.bodyText, contains('Gelieve druk in het oog te houden.'));
    });

    test(
        'EmailJobSpec.buildJobs prunes note when sendToCustomer is false or email empty',
        () {
      // Negative test 1: sendToCustomer is false
      final jobsNoCustomer = EmailJobSpec.buildJobs(
        visitId: 42,
        pdfPath: '/path/test.pdf',
        sendToCustomer: false,
        customerName: 'Jan Peeters',
        customerEmail: 'jan@peeters.be',
        sendToTechnician: true,
        technicianEmail: 'tech@firma.be',
        attestNumber: '2026-042',
        customerNote: 'Factuur volgt later per post.',
      );

      expect(jobsNoCustomer.length, equals(1));
      expect(
          jobsNoCustomer.first.recipientType, equals(RecipientType.technician));
      expect(jobsNoCustomer.first.bodyText,
          isNot(contains('Toegevoegde opmerking')));

      // Negative test 2: customer email is empty
      final jobsEmptyCustomerEmail = EmailJobSpec.buildJobs(
        visitId: 42,
        pdfPath: '/path/test.pdf',
        sendToCustomer: true,
        customerName: 'Jan Peeters',
        customerEmail: '   ',
        sendToTechnician: true,
        technicianEmail: 'tech@firma.be',
        attestNumber: '2026-042',
        customerNote: 'Factuur volgt later per post.',
      );

      expect(jobsEmptyCustomerEmail.length, equals(1));
      expect(jobsEmptyCustomerEmail.first.recipientType,
          equals(RecipientType.technician));
      expect(jobsEmptyCustomerEmail.first.bodyText,
          isNot(contains('Toegevoegde opmerking')));

      // Negative test 3: whitespace-only note
      final jobsWhitespace = EmailJobSpec.buildJobs(
        visitId: 42,
        pdfPath: '/path/test.pdf',
        sendToCustomer: true,
        customerName: 'Jan Peeters',
        customerEmail: 'jan@peeters.be',
        sendToTechnician: true,
        technicianEmail: 'tech@firma.be',
        attestNumber: '2026-042',
        customerNote: '   \n  \t ',
      );

      expect(jobsWhitespace.first.bodyText,
          isNot(contains('Opmerking van de technicus')));

      // Boundary test 4: over 500 chars truncated
      final longNote = 'A' * 600;
      final jobsLong = EmailJobSpec.buildJobs(
        visitId: 42,
        pdfPath: '/path/test.pdf',
        sendToCustomer: true,
        customerName: 'Jan Peeters',
        customerEmail: 'jan@peeters.be',
        sendToTechnician: true,
        technicianEmail: 'tech@firma.be',
        attestNumber: '2026-042',
        customerNote: longNote,
      );

      expect(jobsLong.first.bodyText, contains('A' * 500));
      expect(jobsLong.first.bodyText, isNot(contains('A' * 501)));
    });
  });

  group('EmailCustomNoteInput Widget Tests', () {
    testWidgets('starts collapsed and expands on tap', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: EmailCustomNoteInput(controller: controller),
            ),
          ),
        ),
      );

      // Initially shows the add note button
      expect(find.text(EmailDeliveryDictionary.emailNoteActionAdd),
          findsOneWidget);
      expect(find.byType(TextField), findsNothing);

      // Tap to expand
      await tester.tap(find.text(EmailDeliveryDictionary.emailNoteActionAdd));
      await tester.pumpAndSettle();

      // Now textfield is visible
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text(EmailDeliveryDictionary.emailNoteLabel), findsOneWidget);

      // Type text
      await tester.enterText(
          find.byType(TextField), 'Factuur via mail verstuurd');
      expect(controller.text, equals('Factuur via mail verstuurd'));

      // Verify tooltip on close button
      expect(find.byTooltip(EmailDeliveryDictionary.emailNoteActionRemove),
          findsOneWidget);

      // Tap close/clear icon
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      // Field collapses and controller is cleared
      expect(find.byType(TextField), findsNothing);
      expect(controller.text, isEmpty);
      expect(find.text(EmailDeliveryDictionary.emailNoteActionAdd),
          findsOneWidget);

      controller.dispose();
    });
  });
}
