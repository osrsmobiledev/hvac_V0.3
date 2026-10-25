import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/core/widgets/tactical_search_bar.dart';

void main() {
  testWidgets(
      'TacticalSearchBar renders M3 pill shape, morphs leading icon on focus, and clears query',
      (tester) async {
    String query = '';
    bool cleared = false;
    bool backed = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: Center(
            child: TacticalSearchBar(
              hintText: 'Zoek iets...',
              onChanged: (val) => query = val,
              onClear: () => cleared = true,
              onBack: () => backed = true,
            ),
          ),
        ),
      ),
    );

    // Initial resting state: shows search magnifying glass icon
    expect(find.byKey(const ValueKey('search_glass_icon')), findsOneWidget);
    expect(find.byKey(const ValueKey('search_back_button')), findsNothing);
    expect(find.byKey(const ValueKey('search_clear_button')), findsNothing);
    expect(find.text('Zoek iets...'), findsOneWidget);

    // Tap into SearchBar
    await tester.tap(find.byType(SearchBar));
    await tester.pumpAndSettle();

    // Leading icon morphs to back arrow '<' and trailing gets 'x' before typing
    expect(find.byKey(const ValueKey('search_back_button')), findsOneWidget);
    expect(find.byKey(const ValueKey('search_glass_icon')), findsNothing);
    expect(find.byKey(const ValueKey('search_clear_button')), findsOneWidget);

    // Enter query
    await tester.enterText(find.byType(SearchBar), 'Ketel');
    await tester.pumpAndSettle();
    expect(query, 'Ketel');

    // Trailing clear button remains present
    expect(find.byKey(const ValueKey('search_clear_button')), findsOneWidget);

    // Tap clear button
    await tester.tap(find.byKey(const ValueKey('search_clear_button')));
    await tester.pumpAndSettle();
    expect(cleared, isTrue);

    // Tap back button
    await tester.tap(find.byKey(const ValueKey('search_back_button')));
    await tester.pumpAndSettle();
    expect(backed, isTrue);
    expect(find.byKey(const ValueKey('search_glass_icon')), findsOneWidget);
    expect(find.byKey(const ValueKey('search_clear_button')), findsNothing);
  });
}
