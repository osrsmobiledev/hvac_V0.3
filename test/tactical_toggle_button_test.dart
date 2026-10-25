import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/core/widgets/tactical_toggle_button.dart';

void main() {
  group('TacticalToggleButton Widget Tests', () {
    testWidgets('Renders label and raw Switch correctly', (tester) async {
      bool value = true;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: TacticalToggleButton(
              label: 'Test Toggle',
              value: value,
              onChanged: (v) => value = v,
            ),
          ),
        ),
      );

      expect(find.text('Test Toggle'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, isTrue);
      expect(switchWidget.onChanged, isNotNull);
    });

    testWidgets('Disabled state disables Switch and prevents interaction',
        (tester) async {
      bool? changedValue;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: TacticalToggleButton(
              label: 'Disabled Toggle',
              value: false,
              enabled: false,
              onChanged: (v) => changedValue = v,
            ),
          ),
        ),
      );

      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.onChanged, isNull);

      // Attempting to tap should do nothing
      await tester.tap(find.byType(Switch));
      await tester.pump();
      expect(changedValue, isNull);
    });

    testWidgets('Tapping enabled switch fires onChanged callback',
        (tester) async {
      bool currentValue = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return TacticalToggleButton(
                  label: 'Interactive Toggle',
                  value: currentValue,
                  onChanged: (v) => setState(() => currentValue = v),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(currentValue, isTrue);
    });
  });
}
