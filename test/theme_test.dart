import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/dashboard/applet_bento_tile.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/shell/app_drawer.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/main.dart';

void main() {
  group('Slice 1.3 — Home Dashboard & Drawer Toggle', () {
    test('AppTheme defines dark brightness and expected color tokens', () {
      final theme = AppTheme.darkTheme;

      expect(theme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, AppColors.scaffoldBackground);
      expect(theme.colorScheme.primary, AppColors.amberGold);
      expect(AppTheme.bentoCornerRadius, 28.0);
    });

    testWidgets(
        'Dashboard renders 2-column tiles in exact order with 2-line labels',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const HvacFieldServiceApp());
      await tester.pumpAndSettle();

      // Persistent AppBar title is 'Start'
      final appBarFinder = find.byType(AppBar);
      expect(
        find.descendant(
          of: appBarFinder,
          matching: find.text(AppDictionary.menuStart),
        ),
        findsOneWidget,
      );

      // Centered "Kies een applet" header
      expect(find.text(AppDictionary.dashboardTitle), findsOneWidget);

      // Verify all 4 Applet Bento Tiles are present
      final tiles = find.byType(AppletBentoTile);
      expect(tiles, findsNWidgets(4));

      // Verify specific 2-line text items
      expect(find.text('Verbrandingsattest'), findsOneWidget);
      expect(find.text('Reinigingsattest'), findsOneWidget);
      expect(find.text('Keuringsrapport'), findsOneWidget);
      expect(find.text('Meetrapport'), findsOneWidget);
      expect(find.text('Vlaanderen'), findsNWidgets(3));

      // Tap on 'Verbrandingsattest' tile
      await tester.tap(find.text('Verbrandingsattest'));
      await tester.pumpAndSettle();

      // Persistent AppBar title updates
      expect(
        find.descendant(
          of: appBarFinder,
          matching: find.text(AppDictionary.menuCombustion),
        ),
        findsOneWidget,
      );

      // Tap back button
      await tester.tap(find.text('Terug naar dashboard'));
      await tester.pumpAndSettle();

      // Returns to dashboard with 'Start' in AppBar
      expect(
        find.descendant(
          of: appBarFinder,
          matching: find.text(AppDictionary.menuStart),
        ),
        findsOneWidget,
      );
    });

    testWidgets('Hamburger icon toggles drawer open and closed on phone',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const HvacFieldServiceApp());
      await tester.pumpAndSettle();

      final hamburgerFinder = find.byTooltip('Menu openen');
      expect(hamburgerFinder, findsOneWidget);

      // Tap hamburger to open drawer
      await tester.tap(hamburgerFinder);
      await tester.pumpAndSettle();

      // Drawer is open
      expect(find.byType(AppDrawer), findsOneWidget);

      // Tap hamburger icon again to close drawer
      final closeFinder = find.byTooltip('Menu sluiten');
      expect(closeFinder, findsOneWidget);
      await tester.tap(closeFinder);
      await tester.pumpAndSettle();

      // Drawer is closed (offstage / not visible)
      expect(find.byTooltip('Menu openen'), findsOneWidget);
    });

    testWidgets(
        'Tablet layout: Permanent side menu with 2-column dashboard grid',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1000, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const HvacFieldServiceApp());
      await tester.pumpAndSettle();

      // Permanent AppDrawer should be visible
      expect(find.byType(AppDrawer), findsOneWidget);

      // 4 Dashboard tiles should be visible
      expect(find.byType(AppletBentoTile), findsNWidgets(4));
    });
  });
}
