// File: test/signature_pad_modal_test.dart
// Responsibility: Unit & widget tests for SignaturePadModal responsive canvas and drawing behavior.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/localization/eindbeoordeling_dictionary.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/core/widgets/signature_pad_components.dart';
import 'package:hvac_app/core/widgets/signature_pad_modal.dart';

void main() {
  Widget buildTestApp({String? Function(String?)? onResult}) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              final result = await SignaturePadModal.show(
                context,
                title: 'Handtekening Klant (Kennisname)',
              );
              onResult?.call(result);
            },
            child: const Text('Open Modal'),
          ),
        ),
      ),
    );
  }

  testWidgets(
      'SignaturePadModal renders spacious canvas with ✕ baseline indicator',
      (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.tap(find.text('Open Modal'));
    await tester.pumpAndSettle();

    // Verify modal title
    expect(find.text('Handtekening Klant (Kennisname)'), findsOneWidget);

    // Verify baseline cross indicator is visible
    expect(find.text('✕'), findsOneWidget);

    // Verify canvas area fills spacious vertical area
    final canvasFinder = find.byType(SignatureCanvasArea);
    expect(canvasFinder, findsOneWidget);
    final canvasSize = tester.getSize(canvasFinder);
    expect(canvasSize.height,
        greaterThan(300.0)); // Far more spacious than old 190px

    // Verify footer actions
    expect(find.text(EindbeoordelingDictionary.btnAnnuleren), findsOneWidget);
    expect(find.text(EindbeoordelingDictionary.btnOpslaan), findsOneWidget);
  });

  testWidgets(
      'Drawing strokes adds points, enables Clear, and Clear resets points',
      (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.tap(find.text('Open Modal'));
    await tester.pumpAndSettle();

    final canvasFinder = find.byType(SignatureCanvasArea);
    final center = tester.getCenter(canvasFinder);

    // Draw a stroke across the canvas
    final gesture = await tester.startGesture(center);
    await gesture.moveBy(const Offset(60, 20));
    await gesture.moveBy(const Offset(40, -10));
    await gesture.up();
    await tester.pump();

    // Clear icon button appears once points exist
    final clearButton = find.byTooltip(EindbeoordelingDictionary.btnWissen);
    expect(clearButton, findsOneWidget);

    // Tap clear
    await tester.tap(clearButton);
    await tester.pump();

    // Clear icon button hides after clearing
    expect(find.byTooltip(EindbeoordelingDictionary.btnWissen), findsNothing);
  });

  testWidgets('Drawing strokes and saving returns base64 PNG data string',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    String? capturedSignature;
    await tester
        .pumpWidget(buildTestApp(onResult: (s) => capturedSignature = s));
    await tester.tap(find.text('Open Modal'));
    await tester.pumpAndSettle();

    final canvasFinder = find.byType(SignatureCanvasArea);
    final center = tester.getCenter(canvasFinder);

    // Draw strokes
    final gesture = await tester.startGesture(center);
    await gesture.moveBy(const Offset(50, 30));
    await gesture.moveBy(const Offset(80, -20));
    await gesture.up();
    await tester.pump();

    // Tap Opslaan
    await tester.tap(find.text(EindbeoordelingDictionary.btnOpslaan));
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();

    // Modal closes and returns base64 PNG
    expect(find.byType(SignaturePadModal), findsNothing);
    expect(capturedSignature, isNotNull);
    expect(capturedSignature!.startsWith('data:image/png;base64,'), isTrue);
  });

  testWidgets('Tapping Annuleren closes modal without saving', (tester) async {
    String? capturedSignature;
    await tester
        .pumpWidget(buildTestApp(onResult: (s) => capturedSignature = s));
    await tester.tap(find.text('Open Modal'));
    await tester.pumpAndSettle();

    await tester.tap(find.text(EindbeoordelingDictionary.btnAnnuleren));
    await tester.pumpAndSettle();

    expect(find.byType(SignaturePadModal), findsNothing);
    expect(capturedSignature, isNull);
  });
}
