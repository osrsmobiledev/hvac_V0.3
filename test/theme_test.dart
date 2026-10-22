import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/shell/app_drawer.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/main.dart';

void main() {
  group('Slice 1.2 — Adaptive App Shell & Drawer', () {
    test('AppTheme defines dark brightness and expected color tokens', () {
      final theme = AppTheme.darkTheme;

      expect(theme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, AppColors.scaffoldBackground);
      expect(theme.colorScheme.primary, AppColors.amberGold);
      expect(AppTheme.bentoCornerRadius, 28.0);
    });

    testWidgets('Phone layout: Persistent AppBar and Hamburger Drawer',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const HvacFieldServiceApp());
      await tester.pumpAndSettle();

      // Persistent AppBar with default title
      final appBarFinder = find.byType(AppBar);
      expect(
        find.descendant(
          of: appBarFinder,
          matching: find.text(AppDictionary.appTitle),
        ),
        findsOneWidget,
      );

      // Hamburger button should exist on phone
      final hamburgerFinder = find.byTooltip('Menu openen');
      expect(hamburgerFinder, findsOneWidget);

      // Open drawer
      await tester.tap(hamburgerFinder);
      await tester.pumpAndSettle();

      // Verify Drawer items exist
      expect(find.text(AppDictionary.menuStart), findsOneWidget);
      expect(find.text(AppDictionary.menuCombustion), findsOneWidget);
      expect(find.text(AppDictionary.menuCleaning), findsOneWidget);
      expect(find.text(AppDictionary.menuInspection), findsOneWidget);
      expect(find.text(AppDictionary.menuMeasurement), findsOneWidget);

      // Select 'Verbrandingsattest Vlaanderen'
      await tester.tap(find.text(AppDictionary.menuCombustion));
      await tester.pumpAndSettle();

      // Verify the persistent AppBar dynamically updated its title
      expect(
        find.descendant(
          of: appBarFinder,
          matching: find.text(AppDictionary.menuCombustion),
        ),
        findsOneWidget,
      );
    });

    testWidgets('Tablet layout: Permanent side menu without hamburger button',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(900, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const HvacFieldServiceApp());
      await tester.pumpAndSettle();

      // Persistent AppBar title
      final appBarFinder = find.byType(AppBar);
      expect(
        find.descendant(
          of: appBarFinder,
          matching: find.text(AppDictionary.appTitle),
        ),
        findsOneWidget,
      );

      // Hamburger button should NOT exist on tablet (permanent side menu)
      expect(find.byTooltip('Menu openen'), findsNothing);

      // Permanent AppDrawer should be visible
      expect(find.byType(AppDrawer), findsOneWidget);
      expect(find.text(AppDictionary.menuCombustion), findsOneWidget);
    });
  });
}
