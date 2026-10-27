import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/data/flue_gas_field_box.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/data_tab.dart';

void main() {
  testWidgets(
      'DataTab renders Meetgegevens header, title Rookgassen, QR scanner button, and 21 fields',
      (tester) async {
    bool qrScanned = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: DataTab(
            onScanQrPressed: () => qrScanned = true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify main Bento header 'Meetgegevens'
    expect(find.text(AppDictionary.headerMeetgegevens), findsOneWidget);

    // Verify direct title 'Rookgassen' is centered without sub-accordion
    final titleWidget =
        tester.widget<Text>(find.text(AppDictionary.headerRookgassen));
    expect(titleWidget.textAlign, TextAlign.center);

    // Verify QR scan button in the header row
    final qrBtn = find.byKey(const ValueKey('qr_scan_button'));
    expect(qrBtn, findsOneWidget);

    // Tap QR scan button and verify callback triggers
    await tester.tap(qrBtn);
    await tester.pumpAndSettle();
    expect(qrScanned, isTrue);

    // Verify flue gas parameter boxes are rendered (21 fields)
    expect(find.byType(FlueGasFieldBox), findsWidgets);
    expect(find.text('Brandstof'), findsOneWidget);
    expect(find.text('Druk [hPa]'), findsOneWidget);
  });
}
