import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/core/widgets/tactical_feedback.dart';

void main() {
  testWidgets('TacticalFeedback shows success, info, and error floating toasts',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return Column(
                children: [
                  ElevatedButton(
                    onPressed: () => TacticalFeedback.showSuccess(
                        context, 'Succesvol opgeslagen'),
                    child: const Text('Success'),
                  ),
                  ElevatedButton(
                    onPressed: () =>
                        TacticalFeedback.showInfo(context, 'Info bericht'),
                    child: const Text('Info'),
                  ),
                  ElevatedButton(
                    onPressed: () =>
                        TacticalFeedback.showError(context, 'Fout opgetreden'),
                    child: const Text('Error'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Trigger success toast
    await tester.tap(find.text('Success'));
    await tester.pump();
    expect(find.text('Succesvol opgeslagen'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

    // Trigger info toast (replaces previous toast)
    await tester.tap(find.text('Info'));
    await tester.pump();
    expect(find.text('Info bericht'), findsOneWidget);
    expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);

    // Trigger error toast (replaces previous toast)
    await tester.tap(find.text('Error'));
    await tester.pump();
    expect(find.text('Fout opgetreden'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
  });
}
