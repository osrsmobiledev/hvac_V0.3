import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/shell/app_shell_controller.dart';
import 'package:hvac_app/features/certificate_draft/ui/verbrandingsattest_screen.dart';

Widget buildTestApp() {
  final controller = AppShellController();
  controller.selectApplet(AppletType.combustion);

  return MaterialApp(
    home: Scaffold(
      body: VerbrandingsattestScreen(controller: controller),
    ),
  );
}

void main() {
  group('Floating TabNavOverlay Widget Tests', () {
    testWidgets(
        'Left arrow hidden on Tab 1, right arrow navigates to Tab 2',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // On Tab 1 (Data): Previous arrow is hidden, Next arrow is visible
      final prevArrow = find.byKey(const ValueKey('tab_nav_prev_arrow'));
      final nextArrow = find.byKey(const ValueKey('tab_nav_next_arrow'));

      expect(prevArrow, findsNothing);
      expect(nextArrow, findsOneWidget);
      expect(find.text(AppDictionary.headerMeetgegevens), findsOneWidget);

      // Tap Next arrow -> navigates to Tab 2 (Start)
      await tester.tap(nextArrow);
      await tester.pumpAndSettle();

      // On Tab 2: Both arrows are visible
      expect(prevArrow, findsOneWidget);
      expect(nextArrow, findsOneWidget);
      expect(find.text(AppDictionary.headerActivity), findsOneWidget);

      // Tap Prev arrow -> navigates back to Tab 1 (Data)
      await tester.tap(prevArrow);
      await tester.pumpAndSettle();

      // Previous arrow hidden again, back on Tab 1
      expect(prevArrow, findsNothing);
      expect(nextArrow, findsOneWidget);
      expect(find.text(AppDictionary.headerMeetgegevens), findsOneWidget);
    });
  });
}
