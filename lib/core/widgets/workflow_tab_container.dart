import 'package:flutter/material.dart';
import 'package:hvac_app/app/theme/app_theme.dart';

/// Centralized adaptive scrolling container for workflow tab views.
///
/// Features:
/// - Horizontally centers and constrains layout width to max 600px on tablets and desktop.
/// - Top-aligns content so short forms (e.g. Tab 2 'Start') or collapsed cards never float in the middle.
/// - Unifies top (12px) and bottom (32px) padding across all tabs via [AppTheme.tabViewPadding].
/// - Enforces [ScrollViewKeyboardDismissBehavior.onDrag] so keyboard dismisses fluidly on drag.
/// - Restores scroll offset across tab switches using [PageStorageKey].
class WorkflowTabContainer extends StatelessWidget {
  final String scrollKey;
  final List<Widget> children;
  final double maxWidth;

  const WorkflowTabContainer({
    super.key,
    required this.scrollKey,
    required this.children,
    this.maxWidth = 600.0,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: SizedBox.expand(
          child: SingleChildScrollView(
            key: PageStorageKey<String>(scrollKey),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: AppTheme.tabViewPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}
