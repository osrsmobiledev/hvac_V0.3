import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/shell/app_shell_screen.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/core/database/app_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;

  setUp(() async {
    db = await AppDatabase.instance.initDatabase(
      customPath: inMemoryDatabasePath,
    );
    AppDatabase.instance.setDatabaseForTesting(db);
  });

  tearDown(() async {
    await AppDatabase.instance.close();
  });

  Widget buildTestApp({double width = 450, double height = 844}) {
    return MediaQuery(
      data: MediaQueryData(size: Size(width, height)),
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        builder: (context, child) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: child,
          );
        },
        home: const SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: AppShellScreen(),
        ),
      ),
    );
  }

  group('Keyboard and Drawer Focus Dismissal Tests', () {
    testWidgets(
        'Opening hamburger menu drawer explicitly drops active primary focus',
        (tester) async {
      tester.view.physicalSize = const Size(450, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestApp());
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 60)));
      await tester.pumpAndSettle();

      // Navigate to Verbrandingsattest
      await tester.tap(find.text('Verbrandingsattest'));
      await tester.pump();
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 100)));
      await tester.pumpAndSettle();

      // Scroll TabBar to reveal Stooktoestel tab (Tab 5)
      final stookTab = find.widgetWithText(Tab, 'Stooktoestel');
      await tester.ensureVisible(stookTab);
      await tester.pumpAndSettle();

      await tester.tap(stookTab);
      await tester.pumpAndSettle();

      // Find an active input field (boiler brand)
      final editable = find.byType(EditableText).first;
      final focusNode = tester.widget<EditableText>(editable).focusNode;

      await tester.tap(editable);
      await tester.pump();

      // Verify that the text input has focus
      expect(focusNode.hasFocus, isTrue);

      // Tap hamburger menu button
      final menuButton = find.byKey(const ValueKey('menu_button'));
      expect(menuButton, findsOneWidget);
      await tester.tap(menuButton);
      await tester.pumpAndSettle();

      // Verify text field focus is completely unfocused so keyboard does not pop up
      expect(focusNode.hasFocus, isFalse);
    });

    testWidgets(
        'Tapping outside an active input field calls global onTap and unfocuses',
        (tester) async {
      tester.view.physicalSize = const Size(450, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestApp());
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 60)));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Verbrandingsattest'));
      await tester.pump();
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 100)));
      await tester.pumpAndSettle();

      final stookTab = find.widgetWithText(Tab, 'Stooktoestel');
      await tester.ensureVisible(stookTab);
      await tester.pumpAndSettle();

      await tester.tap(stookTab);
      await tester.pumpAndSettle();

      // Focus active EditableText
      final editable = find.byType(EditableText).first;
      final focusNode = tester.widget<EditableText>(editable).focusNode;

      await tester.tap(editable);
      await tester.pump();
      expect(focusNode.hasFocus, isTrue);

      // Tap outside on a heading / label / empty space
      await tester.tap(find.text(AppDictionary.lblHeatingType));
      await tester.pump();

      // Verify input focus was cleanly dismissed via onTapOutside
      expect(focusNode.hasFocus, isFalse);
    });
  });
}
