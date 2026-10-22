import 'package:flutter/material.dart';
import 'app/localization/app_dictionary.dart';
import 'app/shell/app_shell_screen.dart';
import 'app/theme/app_theme.dart';

void main() {
  runApp(const HvacFieldServiceApp());
}

/// Root widget for the HVAC Field Service application.
///
/// Keeps initialization minimal: loads dark BO2 theme and hosts AppShellScreen.
class HvacFieldServiceApp extends StatelessWidget {
  const HvacFieldServiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppDictionary.appTitle,
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const AppShellScreen(),
    );
  }
}
