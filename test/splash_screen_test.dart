import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/splash/app_splash_screen.dart';
import 'package:hvac_app/app/splash/inward_merge_indicator.dart';

void main() {
  testWidgets('AppSplashScreen renders tactical brand glyph and animates merge',
      (WidgetTester tester) async {
    bool bootCompleted = false;

    await tester.pumpWidget(
      MaterialApp(
        home: AppSplashScreen(
          onAnimationComplete: () {
            bootCompleted = true;
          },
        ),
      ),
    );

    // Initial frame shows HVAC brand glyph and InwardMergeIndicator
    expect(find.text(AppDictionary.appBrand), findsOneWidget);
    expect(find.byType(InwardMergeIndicator), findsOneWidget);
    expect(find.byIcon(Icons.local_fire_department_rounded), findsOneWidget);
    expect(bootCompleted, isFalse);

    // Pump past the 1100ms boot animation
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    expect(bootCompleted, isTrue);
  });
}
