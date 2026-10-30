import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/core/widgets/tactical_square_button.dart';

void main() {
  testWidgets('TacticalSquareButton renders icon, tooltip, and fires onPressed',
      (tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: Center(
            child: TacticalSquareButton(
              key: const ValueKey('test_btn'),
              icon: Icons.qr_code_scanner_rounded,
              tooltip: 'Scan QR',
              accentColor: AppColors.amberGold,
              onPressed: () => tapped = true,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('test_btn')), findsOneWidget);
    expect(find.byIcon(Icons.qr_code_scanner_rounded), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('test_btn')));
    await tester.pumpAndSettle();

    expect(tapped, isTrue);
  });

  testWidgets(
      'TacticalSquareButton handles disabled state when onPressed is null',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: const Scaffold(
          body: Center(
            child: TacticalSquareButton(
              key: ValueKey('disabled_btn'),
              icon: Icons.delete_outline_rounded,
              tooltip: 'Wissen',
              onPressed: null,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final btnFinder = find.byKey(const ValueKey('disabled_btn'));
    expect(btnFinder, findsOneWidget);

    final iconButton = tester.widget<IconButton>(
      find.descendant(of: btnFinder, matching: find.byType(IconButton)),
    );
    expect(iconButton.onPressed, isNull);
  });
}
