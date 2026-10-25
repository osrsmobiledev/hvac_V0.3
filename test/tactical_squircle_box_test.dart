import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/core/widgets/tactical_squircle_box.dart';

void main() {
  group('TacticalTileTheme Unit Tests', () {
    test('Calculates active and disabled tonal surfaces correctly', () {
      const accent = AppColors.amberGold;

      // Normal enabled
      final enabledSurface = TacticalTileTheme.tonalSurface(accent);
      expect(
        enabledSurface,
        Color.alphaBlend(accent.withValues(alpha: 0.08), AppColors.carbonCard),
      );

      // Selected enabled
      final selectedSurface = TacticalTileTheme.tonalSurface(
        accent,
        isSelected: true,
      );
      expect(
        selectedSurface,
        Color.alphaBlend(accent.withValues(alpha: 0.16), AppColors.carbonCard),
      );

      // Disabled
      final disabledSurface = TacticalTileTheme.tonalSurface(
        accent,
        isEnabled: false,
      );
      expect(disabledSurface, const Color(0xFF141414));
    });

    test('Calculates active, selected and disabled rim borders', () {
      const accent = AppColors.amberGold;
      const border = AppColors.amberGoldBorder;

      expect(TacticalTileTheme.rimBorder(border, accent), border);
      expect(
        TacticalTileTheme.rimBorder(border, accent, isSelected: true),
        accent,
      );
      expect(
        TacticalTileTheme.rimBorder(border, accent, isEnabled: false),
        Colors.white.withValues(alpha: 0.10),
      );
    });
  });

  group('TacticalSquircleBox Widget Tests', () {
    testWidgets('Renders squircle icon, accent color and responds to taps',
        (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: TacticalSquircleBox(
                icon: Icons.local_fire_department_rounded,
                accentColor: AppColors.amberGold,
                borderColor: AppColors.amberGoldBorder,
                onTap: () => tapped = true,
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.local_fire_department_rounded), findsOneWidget);

      await tester.tap(find.byType(TacticalSquircleBox));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('Disabled squircle box ignores taps and dims icon',
        (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: TacticalSquircleBox(
                icon: Icons.edit_rounded,
                accentColor: AppColors.antiqueGold,
                borderColor: AppColors.amberGoldBorder,
                isEnabled: false,
                onTap: () => tapped = true,
              ),
            ),
          ),
        ),
      );

      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.edit_rounded));
      expect(iconWidget.color, Colors.white24);

      await tester.tap(find.byType(TacticalSquircleBox));
      await tester.pumpAndSettle();

      expect(tapped, isFalse);
    });
  });
}
