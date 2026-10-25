import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/core/widgets/tactical_confirm_dialog.dart';
import 'package:hvac_app/core/widgets/tactical_dialog_window.dart';

void main() {
  testWidgets('TacticalConfirmDialog renders title, content and styled buttons',
      (tester) async {
    bool? confirmed;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                confirmed = await TacticalConfirmDialog.show(
                  context: context,
                  title: 'Bewerken',
                  content: 'Wilt u de geselecteerde klant bewerken?',
                  confirmLabel: 'Ja',
                  cancelLabel: 'Nee',
                );
              },
              child: const Text('Open Dialog'),
            ),
          ),
        ),
      ),
    );

    // Tap to open dialog
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    // Verify dialog content
    expect(find.text('Bewerken'), findsOneWidget);
    expect(
        find.text('Wilt u de geselecteerde klant bewerken?'), findsOneWidget);
    expect(find.text('Nee'), findsOneWidget);
    expect(find.text('Ja'), findsOneWidget);

    // Tap Cancel ("Nee")
    await tester.tap(find.text('Nee'));
    await tester.pumpAndSettle();

    expect(confirmed, isFalse);
    expect(find.text('Bewerken'), findsNothing);

    // Reopen dialog and tap Confirm ("Ja")
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ja'));
    await tester.pumpAndSettle();

    expect(confirmed, isTrue);
  });

  testWidgets('TacticalConfirmDialog destructive mode renders red styling',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TacticalConfirmDialog(
            title: 'Klant Wissen',
            content: 'Weet u zeker dat u deze klantgegevens wilt wissen?',
            confirmLabel: 'Ja, Wissen',
            cancelLabel: 'Annuleren',
            isDestructive: true,
          ),
        ),
      ),
    );

    expect(find.text('Klant Wissen'), findsOneWidget);
    expect(find.text('Ja, Wissen'), findsOneWidget);
    expect(find.text('Annuleren'), findsOneWidget);

    // Verify destructive action uses official M3 OutlinedButton with error color
    final outlinedButtons =
        tester.widgetList<OutlinedButton>(find.byType(OutlinedButton)).toList();
    expect(outlinedButtons.length, 2);
    final destructiveBtn = outlinedButtons.last;
    expect(
      destructiveBtn.style?.foregroundColor?.resolve({}),
      ThemeData.light().colorScheme.error,
    );
  });

  testWidgets('TacticalDialogWindow renders custom child and actions',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TacticalDialogWindow(
            title: 'Custom Modal',
            actions: Text('Custom Actions'),
            child: Text('Custom Child Content'),
          ),
        ),
      ),
    );

    expect(find.text('Custom Modal'), findsOneWidget);
    expect(find.text('Custom Child Content'), findsOneWidget);
    expect(find.text('Custom Actions'), findsOneWidget);
  });

  testWidgets(
      'TacticalConfirmDialog renders Verwijderen in single line with FittedBox',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => TacticalConfirmDialog.show(
                context: context,
                title: 'Klant Verwijderen',
                content: 'Weet u het zeker?',
                confirmLabel: 'Verwijderen',
                cancelLabel: 'Nee',
                isDestructive: true,
              ),
              child: const Text('Open Delete'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Verwijderen'), findsOneWidget);
    final textWidget = tester.widget<Text>(find.text('Verwijderen'));
    expect(textWidget.maxLines, 1);
    expect(find.byType(FittedBox), findsWidgets);
  });
}
