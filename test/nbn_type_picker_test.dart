import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/stooktoestel/centraal_types_section.dart';

void main() {
  testWidgets('NBN CR 1749 Tactical Bottom Sheet modal opens and selects code',
      (WidgetTester tester) async {
    final typeBController = TextEditingController(text: '11');
    final typeCController = TextEditingController(text: '13');
    String activeType = 'C';

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return CentraalTypesSection(
                isCentral: true,
                centraalType: activeType,
                typeBController: typeBController,
                typeCController: typeCController,
                onCentraalTypeChanged: (type) {
                  setState(() => activeType = type);
                },
              );
            },
          ),
        ),
      ),
    );

    // Initial check: Type C shows '13'
    expect(typeCController.text, '13');

    // Tap the Type C input box to open tactical bottom sheet
    final inputC = find.byKey(const ValueKey('nbn_input_C'));
    expect(inputC, findsOneWidget);

    await tester.tap(inputC);
    await tester.pumpAndSettle();

    // Modal sheet is now open with NBN options
    expect(find.text('Aansluiting Type C (Gesloten)'), findsOneWidget);
    expect(find.text('Dakdoorvoer (C33)'), findsOneWidget);
    expect(find.text('Schoorsteenschacht (C93)'), findsOneWidget);

    // Tap 'C33' option
    await tester.tap(find.text('Dakdoorvoer (C33)'));
    await tester.pumpAndSettle();

    // Verify modal dismissed and controller updated to '33'
    expect(find.text('Aansluiting Type C (Gesloten)'), findsNothing);
    expect(typeCController.text, '33');
  });
}
