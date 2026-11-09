import 'package:flutter/material.dart';

/// Centralized utility to automatically find and scroll to the first
/// invalid [FormField] inside a [Form].
abstract final class FormScrollHelper {
  /// Scans the element tree under [context] for the first [FormField]
  /// with an active validation error ([FormFieldState.hasError] == true),
  /// and smoothly scrolls it into comfortable view.
  static void scrollToFirstInvalid(
    BuildContext? context, {
    double alignment = 0.2,
    Duration duration = const Duration(milliseconds: 350),
    Curve curve = Curves.easeOutCubic,
  }) {
    if (context == null) return;

    Element? firstInvalid;
    void visitor(Element element) {
      if (firstInvalid != null) return;
      if (element.widget is FormField) {
        if (element is StatefulElement && element.state is FormFieldState) {
          final formFieldState = element.state as FormFieldState;
          if (formFieldState.hasError) {
            firstInvalid = element;
            return;
          }
        }
      }
      element.visitChildren(visitor);
    }

    context.visitChildElements(visitor);

    if (firstInvalid != null && firstInvalid!.mounted) {
      Scrollable.ensureVisible(
        firstInvalid!,
        alignment: alignment,
        duration: duration,
        curve: curve,
      );
    }
  }
}
