import 'package:flutter/material.dart';
import 'package:hvac_app/app/theme/app_theme.dart';

/// Centralized adaptive scrolling container for workflow tab views.
///
/// Features:
/// - Centers and constrains layout width to max 600px on tablets and desktop.
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
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: ListView(
          key: PageStorageKey<String>(scrollKey),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: AppTheme.tabViewPadding,
          children: children,
        ),
      ),
    );
  }
}
