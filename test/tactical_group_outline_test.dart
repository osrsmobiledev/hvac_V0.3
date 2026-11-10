import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/core/widgets/tactical_group_outline.dart';

void main() {
  testWidgets(
      'Renders child inside Container with transparent border when hasError is false',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TacticalGroupOutline(
            hasError: false,
            child: Text('Group Child Content'),
          ),
        ),
      ),
    );

    expect(find.text('Group Child Content'), findsOneWidget);

    final container = tester.widget<Container>(find
        .descendant(
          of: find.byType(TacticalGroupOutline),
          matching: find.byType(Container),
        )
        .first);

    final boxDecoration = container.decoration as BoxDecoration;
    expect(boxDecoration.border?.top.color, Colors.transparent);
    expect(boxDecoration.border?.top.width, 1.2);
    expect(boxDecoration.borderRadius, BorderRadius.circular(8.0));
  });

  testWidgets(
      'Applies AppColors.errorRed border when hasError is true without layout shift',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TacticalGroupOutline(
            hasError: true,
            child: Text('Group Child Content'),
          ),
        ),
      ),
    );

    final container = tester.widget<Container>(find
        .descendant(
          of: find.byType(TacticalGroupOutline),
          matching: find.byType(Container),
        )
        .first);

    final boxDecoration = container.decoration as BoxDecoration;
    expect(boxDecoration.border?.top.color, AppColors.errorRed);
    expect(boxDecoration.border?.top.width, 1.2);
  });

  testWidgets(
      'Zero layout shift: Widget dimensions remain 100% identical when toggling hasError',
      (tester) async {
    final stateHolder = ValueNotifier<bool>(false);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ValueListenableBuilder<bool>(
            valueListenable: stateHolder,
            builder: (context, hasError, _) => TacticalGroupOutline(
              hasError: hasError,
              child: const SizedBox(width: 200, height: 42),
            ),
          ),
        ),
      ),
    );

    final sizeValid = tester.getSize(find.byType(TacticalGroupOutline));

    // Toggle error state to true
    stateHolder.value = true;
    await tester.pump();

    final sizeError = tester.getSize(find.byType(TacticalGroupOutline));
    expect(sizeError, equals(sizeValid));

    // Toggle back to false
    stateHolder.value = false;
    await tester.pump();

    final sizeValidAgain = tester.getSize(find.byType(TacticalGroupOutline));
    expect(sizeValidAgain, equals(sizeValid));
  });

  testWidgets('Respects custom borderRadius, padding, and errorColor',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TacticalGroupOutline(
            hasError: true,
            borderRadius: 14.0,
            padding: EdgeInsets.all(5.0),
            borderWidth: 2.0,
            errorColor: Colors.deepOrange,
            child: Text('Custom Styling'),
          ),
        ),
      ),
    );

    final container = tester.widget<Container>(find
        .descendant(
          of: find.byType(TacticalGroupOutline),
          matching: find.byType(Container),
        )
        .first);

    final boxDecoration = container.decoration as BoxDecoration;
    expect(boxDecoration.border?.top.color, Colors.deepOrange);
    expect(boxDecoration.border?.top.width, 2.0);
    expect(boxDecoration.borderRadius, BorderRadius.circular(14.0));
    expect(container.padding, const EdgeInsets.all(5.0));
  });
}
