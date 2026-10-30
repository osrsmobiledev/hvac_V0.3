import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/core/widgets/workflow_tab_container.dart';

void main() {
  testWidgets(
      'WorkflowTabContainer constrains to 600px width and sets onDrag keyboard dismissal',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: WorkflowTabContainer(
            scrollKey: 'test_scroll_key',
            children: [
              Text('Child Item 1'),
              Text('Child Item 2'),
            ],
          ),
        ),
      ),
    );

    // Verify ConstrainedBox with maxWidth: 600 inside WorkflowTabContainer
    final constrainedFinder = find.descendant(
      of: find.byType(WorkflowTabContainer),
      matching: find.byType(ConstrainedBox),
    );
    expect(constrainedFinder, findsWidgets);

    final constrainedBox =
        tester.widget<ConstrainedBox>(constrainedFinder.first);
    expect(constrainedBox.constraints.maxWidth, equals(600.0));

    // Verify ListView configuration
    final listFinder = find.byType(ListView);
    expect(listFinder, findsOneWidget);

    final listView = tester.widget<ListView>(listFinder);
    expect(listView.keyboardDismissBehavior,
        equals(ScrollViewKeyboardDismissBehavior.onDrag));
    expect(listView.padding, equals(AppTheme.tabViewPadding));
    expect(
        listView.key, equals(const PageStorageKey<String>('test_scroll_key')));

    // Verify children rendered
    expect(find.text('Child Item 1'), findsOneWidget);
    expect(find.text('Child Item 2'), findsOneWidget);
  });
}
