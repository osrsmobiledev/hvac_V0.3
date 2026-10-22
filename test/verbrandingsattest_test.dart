import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/shell/app_shell_screen.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/features/certificate_draft/domain/flue_gas_field.dart';

void main() {
  Widget buildTestApp({double width = 390, double height = 844}) {
    return MediaQuery(
      data: MediaQueryData(size: Size(width, height)),
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: const SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: AppShellScreen(),
        ),
      ),
    );
  }

  group('Slice 2.1 — 7-Tab Internal Shell & Tab 1 (Data)', () {
    testWidgets(
        'Tapping Verbrandingsattest opens the 7-tab applet with 2-line title on phones',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestApp(width: 390, height: 844));
      await tester.pumpAndSettle();

      // Tap on the Verbrandingsattest tile
      final tileFinder = find.text('Verbrandingsattest');
      expect(tileFinder, findsOneWidget);
      await tester.tap(tileFinder);
      await tester.pumpAndSettle();

      // Verify adaptive 2-line AppBar title
      expect(find.text('Verbrandingsattest'), findsOneWidget);
      expect(find.text('Vlaanderen'), findsOneWidget);

      // Verify top TabBar has all 7 tabs
      expect(find.text('Data'), findsOneWidget);
      expect(find.text('Start'), findsOneWidget);
      expect(find.text('Firma - Technicus'), findsOneWidget);
      expect(find.text('Klant'), findsOneWidget);
      expect(find.text('Stooktoestel'), findsOneWidget);
      expect(find.text('Meting'), findsOneWidget);
      expect(find.text('Eindbeoordeling'), findsOneWidget);
    });

    testWidgets('Displays 1-line centered title on wider tablet screens',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestApp(width: 800, height: 1000));
      await tester.pumpAndSettle();

      // Tap on the Verbrandingsattest tile
      final tileFinder = find.text('Verbrandingsattest');
      expect(tileFinder, findsOneWidget);
      await tester.tap(tileFinder);
      await tester.pumpAndSettle();

      // On wide screens (>= 720px), title is a single line
      expect(find.text('Verbrandingsattest Vlaanderen'), findsOneWidget);
    });

    testWidgets(
        'Tab 1 (Data) contains Meetgegevens, Rookgassen, QR button, and all 21 flue gas fields',
        (tester) async {
      tester.view.physicalSize = const Size(390, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestApp(width: 390, height: 1400));
      await tester.pumpAndSettle();

      // Open Verbrandingsattest
      await tester.tap(find.text('Verbrandingsattest'));
      await tester.pumpAndSettle();

      // Verify headers
      expect(find.text('Meetgegevens'), findsOneWidget);
      expect(find.text('Rookgassen'), findsOneWidget);

      // Verify QR button is present
      expect(find.byIcon(Icons.qr_code_scanner_rounded), findsOneWidget);

      // Verify flue gas domain list has 21 fields
      expect(FlueGasField.defaultFields.length, equals(21));

      // Verify initial fields are rendered
      expect(find.text('Brandstof'), findsOneWidget);
      expect(find.text('Datum'), findsOneWidget);
      expect(find.text('Tijd'), findsOneWidget);
      expect(find.text('Druk [hPa]'), findsOneWidget);
    });

    testWidgets(
        'Tapping Meetgegevens and Rookgassen toggles accordion collapse',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestApp(width: 390, height: 844));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Verbrandingsattest'));
      await tester.pumpAndSettle();

      // Initially expanded
      expect(find.text('Rookgassen'), findsOneWidget);
      expect(find.text('Brandstof'), findsOneWidget);

      // Tap Rookgassen header to collapse fields
      await tester.tap(find.text('Rookgassen'));
      await tester.pumpAndSettle();

      // Rookgassen header still visible, but fields are hidden
      expect(find.text('Rookgassen'), findsOneWidget);
      expect(find.text('Brandstof'), findsNothing);

      // Tap Meetgegevens header to collapse everything
      await tester.tap(find.text('Meetgegevens'));
      await tester.pumpAndSettle();

      // Now Rookgassen card itself is hidden
      expect(find.text('Rookgassen'), findsNothing);

      // Tap Meetgegevens again to re-expand
      await tester.tap(find.text('Meetgegevens'));
      await tester.pumpAndSettle();

      expect(find.text('Rookgassen'), findsOneWidget);
    });

    testWidgets('Preserves scroll position when switching tabs',
        (tester) async {
      tester.view.physicalSize = const Size(390, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestApp(width: 390, height: 600));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Verbrandingsattest'));
      await tester.pumpAndSettle();

      // Scroll down on Data tab
      final scrollFinder = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(find.text('Druk [Pa]'), 200,
          scrollable: scrollFinder);
      await tester.pumpAndSettle();
      expect(find.text('Druk [Pa]'), findsOneWidget);

      // Switch to Start tab
      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();

      // Switch back to Data tab
      await tester.tap(find.text('Data'));
      await tester.pumpAndSettle();

      // Verify still at scrolled position (Druk [Pa] is still visible)
      expect(find.text('Druk [Pa]'), findsOneWidget);
    });
  });
}
