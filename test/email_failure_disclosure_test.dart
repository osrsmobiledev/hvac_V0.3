import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/localization/email_delivery_dictionary.dart';
import 'package:hvac_app/app/localization/email_failure_dictionary.dart';
import 'package:hvac_app/features/email_delivery/ui/email_failure_disclosure.dart';

void main() {
  Widget buildWidget(EmailFailureDisclosure widget) {
    return MaterialApp(
      home: Scaffold(
        body: widget,
      ),
    );
  }

  testWidgets(
      'displays actionable credentials message on authentication_failed',
      (tester) async {
    await tester.pumpWidget(buildWidget(
      const EmailFailureDisclosure(
        status: 'server_rejected',
        failureReason: 'authentication_failed',
        lastError: '535 5.7.8 Bad credentials',
      ),
    ));

    expect(
      find.text(EmailFailureDictionary.authenticationFailedExplanation),
      findsOneWidget,
    );
    expect(
      find.text(EmailFailureDictionary.showTechnicalDetails),
      findsOneWidget,
    );
  });

  testWidgets('displays local file missing message on missing_attachment',
      (tester) async {
    await tester.pumpWidget(buildWidget(
      const EmailFailureDisclosure(
        status: 'failed',
        failureReason: 'missing_attachment',
        lastError: 'File not found: /path/to/archive.pdf',
      ),
    ));

    expect(
      find.text(EmailFailureDictionary.missingAttachmentExplanation),
      findsOneWidget,
    );
  });

  testWidgets('displays distinct message for recipient_rejected',
      (tester) async {
    await tester.pumpWidget(buildWidget(
      const EmailFailureDisclosure(
        status: 'recipient_rejected',
        failureReason: 'recipient_rejected',
        lastError: '550 5.1.1 User unknown',
      ),
    ));

    expect(
      find.text(EmailFailureDictionary.recipientRejectedExplanation),
      findsOneWidget,
    );
  });

  testWidgets('displays distinct message for server_rejected', (tester) async {
    await tester.pumpWidget(buildWidget(
      const EmailFailureDisclosure(
        status: 'server_rejected',
        failureReason: 'policy_rejection',
      ),
    ));

    expect(
      find.text(EmailFailureDictionary.serverRejectedExplanation),
      findsOneWidget,
    );
  });

  testWidgets('displays distinct message for uncertain_timeout',
      (tester) async {
    await tester.pumpWidget(buildWidget(
      const EmailFailureDisclosure(
        status: 'uncertain_timeout',
        failureReason: 'uncertain_timeout',
        lastError: 'SocketException: Connection timed out',
      ),
    ));

    expect(
      find.text(EmailFailureDictionary.uncertainTimeoutExplanation),
      findsOneWidget,
    );
  });

  testWidgets('displays neutral fallback for unknown or generic failures',
      (tester) async {
    await tester.pumpWidget(buildWidget(
      const EmailFailureDisclosure(
        status: 'failed',
        failureReason: 'unexpected_crash',
      ),
    ));

    expect(
      find.text(EmailFailureDictionary.genericExplanation),
      findsOneWidget,
    );
    // Must NOT falsely label as connection or server problem
    expect(find.textContaining('server'), findsNothing);
    expect(find.textContaining('verbinding'), findsNothing);
  });

  testWidgets('expands and collapses technical details disclosure',
      (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(buildWidget(
      const EmailFailureDisclosure(
        status: 'recipient_rejected',
        failureReason: 'recipient_rejected',
        lastError: '550 5.1.1 User unknown',
      ),
    ));

    expect(
      find.text(EmailFailureDictionary.showTechnicalDetails),
      findsOneWidget,
    );
    expect(find.textContaining('550 5.1.1 User unknown'), findsNothing);

    // Tap to expand
    await tester.tap(find.text(EmailFailureDictionary.showTechnicalDetails));
    await tester.pumpAndSettle();

    expect(
      find.text(EmailFailureDictionary.hideTechnicalDetails),
      findsOneWidget,
    );
    expect(find.textContaining('550 5.1.1 User unknown'), findsOneWidget);
    expect(
      find.text(
          '${EmailDeliveryDictionary.labelLastError} 550 5.1.1 User unknown'),
      findsOneWidget,
    );

    // Tap to collapse
    await tester.tap(find.text(EmailFailureDictionary.hideTechnicalDetails));
    await tester.pumpAndSettle();

    expect(
      find.text(EmailFailureDictionary.showTechnicalDetails),
      findsOneWidget,
    );
    expect(find.textContaining('550 5.1.1 User unknown'), findsNothing);
    semantics.dispose();
  });

  testWidgets('does not show technical details toggle when lastError is null',
      (tester) async {
    await tester.pumpWidget(buildWidget(
      const EmailFailureDisclosure(
        status: 'server_rejected',
        failureReason: 'server_rejected',
      ),
    ));

    expect(
      find.text(EmailFailureDictionary.showTechnicalDetails),
      findsNothing,
    );
    expect(
      find.text(EmailFailureDictionary.hideTechnicalDetails),
      findsNothing,
    );
  });
}
