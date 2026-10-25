import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app/localization/app_dictionary.dart';
import 'app/shell/app_shell_screen.dart';
import 'app/theme/app_theme.dart';
import 'core/database/app_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SQLite database on startup for offline draft safety
  await AppDatabase.instance.database;

  // Enforce portrait orientation app-wide across all devices (phones & tablets)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

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
