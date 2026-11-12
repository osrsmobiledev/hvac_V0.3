import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/features/pdf_export/data/pdf_visit_data.dart';
import 'package:hvac_app/features/pdf_export/ui/pdf_preview_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('PdfPreviewDialog renders top bar with zoom controls and title',
      (WidgetTester tester) async {
    const testData = PdfVisitData(
      volgnummerAttest: 'TEST-001',
      firmaNaam: 'Test Firma',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PdfPreviewDialog(data: testData),
        ),
      ),
    );

    // Verify Title
    expect(find.text('Verbrandingsattest Vlaanderen (A4)'), findsOneWidget);

    // Verify Zoom Controls exist
    expect(find.byIcon(Icons.zoom_in_rounded), findsOneWidget);
    expect(find.byIcon(Icons.zoom_out_rounded), findsOneWidget);
    expect(find.byIcon(Icons.fit_screen_rounded), findsOneWidget);
    expect(find.byIcon(Icons.download_rounded), findsOneWidget);
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);

    // Tap zoom in and fit screen to verify no exceptions
    await tester.tap(find.byIcon(Icons.zoom_in_rounded));
    await tester.pump();

    await tester.tap(find.byIcon(Icons.fit_screen_rounded));
    await tester.pump();
  });
}
