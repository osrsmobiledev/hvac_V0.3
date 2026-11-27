import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'app_shell_controller.dart';

/// Displays the persistent AppBar title displaying a clean 1-line title
/// auto-scaled with [FittedBox] so it never wraps or cuts off on any screen.
class AppBarTitle extends StatelessWidget {
  final AppShellController controller;

  const AppBarTitle({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.activeApplet == AppletType.combustion ||
        controller.activeApplet == AppletType.cleaning) {
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          controller.appBarTitle,
          textAlign: TextAlign.center,
          maxLines: 1,
          style: const TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontWeight: FontWeight.w700,
            fontSize: 16.5,
            letterSpacing: 0.2,
          ),
        ),
      );
    }
    return Text(
      controller.appBarTitle,
      style: const TextStyle(
        fontFamily: AppTheme.fontFamily,
        fontWeight: FontWeight.w700,
        fontSize: 20,
      ),
    );
  }
}
