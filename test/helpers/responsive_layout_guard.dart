import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// App-agnostic helper verifying a widget renders cleanly across narrow phone
/// and tablet viewports without RenderFlex overflows or `FittedBox` text shrink.
Future<void> expectNoOverflowOrShrunkLabels(
  WidgetTester tester,
  Widget widget, {
  List<Size> sizes = const [Size(360, 800), Size(768, 1024)],
  double minTextScale = 0.90,
  Future<void> Function(WidgetTester)? afterPump,
}) async {
  for (final size in sizes) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    try {
      await tester.pumpWidget(widget);
      if (afterPump != null) {
        await afterPump(tester);
      } else {
        await tester.pumpAndSettle();
      }
      expect(
        tester.takeException(),
        isNull,
        reason: 'Unexpected layout/overflow exception at $size',
      );

      for (final element in find.byType(FittedBox).evaluate()) {
        final renderObj = element.renderObject;
        if (renderObj is! RenderFittedBox || renderObj.child == null) continue;
        final textFinder = find.descendant(
          of: find.byWidget(element.widget),
          matching: find.byType(Text),
        );
        if (textFinder.evaluate().isEmpty) continue;

        final transform = Matrix4.identity();
        renderObj.applyPaintTransform(renderObj.child!, transform);
        final scale = transform.getMaxScaleOnAxis();
        final label =
            tester.widget<Text>(textFinder.first).data ?? '<rich text>';
        expect(
          scale,
          greaterThanOrEqualTo(minTextScale),
          reason:
              'FittedBox shrunk label "$label" to ${(scale * 100).toStringAsFixed(0)}% at $size',
        );
      }
    } finally {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    }
  }
}
