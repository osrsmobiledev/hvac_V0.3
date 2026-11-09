import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/core/utils/form_scroll_helper.dart';

void main() {
  testWidgets('FormScrollHelper scrolls to the first invalid FormField',
      (tester) async {
    final formKey = GlobalKey<FormState>();
    final scrollController = ScrollController();
    addTearDown(scrollController.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                children: [
                  const SizedBox(height: 500),
                  TextFormField(
                    key: const ValueKey('valid_field'),
                    initialValue: 'Valid Content',
                    validator: (v) => v!.isEmpty ? 'Error' : null,
                  ),
                  const SizedBox(height: 500),
                  TextFormField(
                    key: const ValueKey('first_invalid_field'),
                    initialValue: '',
                    validator: (v) => v!.isEmpty ? 'First Required' : null,
                  ),
                  const SizedBox(height: 500),
                  TextFormField(
                    key: const ValueKey('second_invalid_field'),
                    initialValue: '',
                    validator: (v) => v!.isEmpty ? 'Second Required' : null,
                  ),
                  const SizedBox(height: 500),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // Initial scroll is at top (0.0)
    expect(scrollController.offset, 0.0);

    // Validate the form -> marks both fields invalid
    expect(formKey.currentState!.validate(), isFalse);
    await tester.pumpAndSettle();

    // Trigger helper
    FormScrollHelper.scrollToFirstInvalid(
      formKey.currentContext,
      duration: const Duration(milliseconds: 100),
    );
    await tester.pumpAndSettle();

    // Scroll offset has moved down to bring the first invalid field into view
    expect(scrollController.offset, greaterThan(200.0));
  });
}
